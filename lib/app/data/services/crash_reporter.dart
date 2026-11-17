import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:crypto/crypto.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

/// Ponto único de relato de erros ao Firebase Crashlytics.
///
/// Estático (como o `FirebaseService`) porque precisa funcionar antes do
/// `runApp` e em isolates de segundo plano, onde não há bindings do GetX.
///
/// - Em debug a coleta fica desligada: os erros só aparecem no console.
///   Para testar o envio, rode com `--dart-define=CRASHLYTICS_DEBUG=true`.
/// - Nunca lança: falhar ao relatar um erro não pode derrubar o app.
/// - Não envia dados pessoais: o usuário é identificado por um hash
///   ([userHash]) e os `reason` devem ser textos fixos, sem valores únicos.
class CrashReporter {
  CrashReporter._();

  static const bool _forceInDebug = bool.fromEnvironment('CRASHLYTICS_DEBUG');

  /// Se a coleta está ligada neste build.
  static bool get enabled => !kDebugMode || _forceInDebug;

  static String? _lastRoute;

  /// Intervalo mínimo entre dois relatos do mesmo erro no mesmo ponto.
  /// Evita que polling, timers e novas tentativas inundem o console: o
  /// número de usuários afetados continua certo, só o de eventos cai.
  static const Duration repeatWindow = Duration(minutes: 5);

  static final Map<String, DateTime> _lastReported = {};

  static FirebaseCrashlytics get _crashlytics => FirebaseCrashlytics.instance;

  /// Liga a coleta e instala os handlers globais. Chame depois de
  /// inicializar o Firebase, no `main()` e em cada isolate de segundo plano.
  static Future<void> init() async {
    try {
      await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
    } catch (e) {
      debugPrint('CrashReporter: não foi possível iniciar o Crashlytics: $e');
      return;
    }
    if (!enabled) return;

    // Erros dentro do framework (build, layout, gestos...).
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      _run(() => _crashlytics.recordFlutterFatalError(details));
    };

    // Erros assíncronos que ninguém tratou.
    PlatformDispatcher.instance.onError = (error, stack) {
      _run(() => _crashlytics.recordError(error, stack, fatal: true));
      return true;
    };

    // Erros fora do contexto do Flutter neste isolate.
    Isolate.current.addErrorListener(
      RawReceivePort((dynamic pair) {
        final list = pair as List<dynamic>;
        final stack = list.last == null
            ? null
            : StackTrace.fromString(list.last.toString());
        _run(() => _crashlytics.recordError(list.first, stack, fatal: true));
      }).sendPort,
    );
  }

  /// Relata um erro tratado (não fatal). Use nos `catch` em que o erro
  /// indica um problema real, junto com o tratamento que já existe:
  ///
  /// ```dart
  /// } catch (e, s) {
  ///   CrashReporter.recordError(e, s, reason: 'buscar grupos GDI');
  ///   return [];
  /// }
  /// ```
  ///
  /// [reason] é um texto fixo dizendo o que se tentava fazer. Não coloque
  /// nele ids, e-mails, tokens ou URLs.
  static void recordError(Object error, StackTrace? stack, {String? reason}) {
    if (!enabled) {
      debugPrint('CrashReporter (não enviado em debug): ${reason ?? ''} $error');
      return;
    }
    if (isExpected(error)) {
      // Sem internet, servidor fora do ar ou login cancelado: não é bug do
      // app. Fica só o tipo no log, para contexto de um erro seguinte.
      log('${reason ?? 'erro'} (esperado): ${error.runtimeType}');
      return;
    }
    if (!shouldReport('${reason ?? ''}|${error.runtimeType}', DateTime.now())) {
      return;
    }
    _run(() => _crashlytics.recordError(error, stack, reason: reason));
  }

  /// Se um erro identificado por [key] (ponto + tipo) pode ser relatado
  /// agora, ou se o mesmo já foi relatado dentro de [repeatWindow].
  @visibleForTesting
  static bool shouldReport(String key, DateTime now) {
    final last = _lastReported[key];
    if (last != null && now.difference(last) < repeatWindow) return false;
    _lastReported[key] = now;
    return true;
  }

  @visibleForTesting
  static void resetRepeats() => _lastReported.clear();

  /// Breadcrumb: mensagem que vai junto do próximo relatório. Não coloque
  /// dados pessoais, tokens ou URLs com query.
  static void log(String message) {
    if (!enabled) return;
    _run(() => _crashlytics.log(message));
  }

  /// Associa os próximos relatórios ao usuário.
  ///
  /// [seed] é o iduff ou, sem ele, o uid do Google. Só o hash é enviado.
  /// Com [seed] nulo ou vazio o identificador é limpo (usuário anônimo).
  static void setUser({
    String? seed,
    required String loginMethod,
    String? profileType,
    String? bondId,
    String? bond,
    String? course,
  }) {
    if (!enabled) return;
    final hasSeed = seed != null && seed.isNotEmpty;
    _run(() => _crashlytics.setUserIdentifier(hasSeed ? userHash(seed) : ''));
    _setKey('login', loginMethod);
    _setKey('perfil', profileType ?? '');
    _setKey('vinculo_id', bondId ?? '');
    _setKey('vinculo', bond ?? '');
    _setKey('curso', course ?? '');
  }

  /// Remove o usuário dos próximos relatórios (logout).
  static void clearUser() {
    setUser(loginMethod: 'nenhum');
    log('logout');
  }

  /// Para o `routingCallback` do `GetMaterialApp`: registra cada troca de
  /// tela no log e a tela atual nas chaves.
  static void onRouting(Routing? routing) {
    if (!enabled || routing == null) return;
    final current = routing.current;
    if (current.isEmpty || current == _lastRoute) return;
    log('rota: ${_lastRoute ?? '-'} -> $current');
    _lastRoute = current;
    _setKey('rota_atual', current);
    _setKey('idioma', Get.locale?.toString() ?? '');
  }

  /// Hash usado como identificador do usuário. Para achar no console os
  /// erros de um usuário, calcule este mesmo hash a partir do iduff dele.
  @visibleForTesting
  static String userHash(String seed) =>
      sha256.convert(utf8.encode('uffmobileplus:$seed')).toString();

  /// Erros que não indicam bug do app e não devem virar issue.
  @visibleForTesting
  static bool isExpected(Object error) {
    if (error is SocketException ||
        error is HandshakeException ||
        error is TimeoutException ||
        error is http.ClientException) {
      return true;
    }
    // Firebase (Firestore, Auth...) sem conexão.
    if (error is FirebaseException && _firebaseOfflineCodes.contains(error.code)) {
      return true;
    }
    // Erro de rede relançado como `Exception('...: $e')`, que perde o tipo
    // original. Só vale para `Exception`, nunca para `Error` (bug de código).
    if (error is Exception) {
      final text = error.toString();
      if (_wrappedNetworkMarkers.any(text.contains)) return true;
    }
    if (error is GoogleSignInException &&
        error.code == GoogleSignInExceptionCode.canceled) {
      return true;
    }
    // Login IdUFF cancelado pelo usuário (Android e iOS).
    if (error is PlatformException && error.code == 'authorize_failed') {
      final message = error.message ?? '';
      return message.contains('User cancelled flow') ||
          message.contains('org.openid.appauth.general error -3');
    }
    return false;
  }

  static const Set<String> _firebaseOfflineCodes = {
    'unavailable',
    'network-request-failed',
    'deadline-exceeded',
  };

  static const List<String> _wrappedNetworkMarkers = [
    'SocketException',
    'TimeoutException',
    'HandshakeException',
    'ClientException',
    'Failed host lookup',
    '[cloud_firestore/unavailable]',
    'network-request-failed',
  ];

  static void _setKey(String key, Object value) {
    _run(() => _crashlytics.setCustomKey(key, value));
  }

  static void _run(Future<void> Function() action) {
    try {
      unawaited(
        action().catchError((Object e) {
          debugPrint('CrashReporter: falha ao enviar: $e');
        }),
      );
    } catch (e) {
      debugPrint('CrashReporter: falha ao enviar: $e');
    }
  }
}
