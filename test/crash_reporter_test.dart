import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:uffmobileplus/app/data/services/crash_reporter.dart';

void main() {
  group('CrashReporter.userHash', () {
    test('é estável para o mesmo usuário', () {
      expect(
        CrashReporter.userHash('12345678900'),
        CrashReporter.userHash('12345678900'),
      );
    });

    test('muda entre usuários e não contém o valor original', () {
      final a = CrashReporter.userHash('12345678900');
      final b = CrashReporter.userHash('12345678901');
      expect(a, isNot(b));
      expect(a, isNot(contains('12345678900')));
      expect(a, matches(RegExp(r'^[0-9a-f]{64}$')));
    });
  });

  group('CrashReporter.isExpected', () {
    test('ignora falhas de conexão', () {
      expect(CrashReporter.isExpected(const SocketException('x')), isTrue);
      expect(CrashReporter.isExpected(TimeoutException('x')), isTrue);
      expect(CrashReporter.isExpected(http.ClientException('x')), isTrue);
      expect(CrashReporter.isExpected(const HandshakeException('x')), isTrue);
    });

    test('ignora login cancelado pelo usuário', () {
      expect(
        CrashReporter.isExpected(
          const GoogleSignInException(code: GoogleSignInExceptionCode.canceled),
        ),
        isTrue,
      );
      expect(
        CrashReporter.isExpected(
          PlatformException(
            code: 'authorize_failed',
            message:
                'Failed to authorize: [error: null, description: User cancelled flow]',
          ),
        ),
        isTrue,
      );
      expect(
        CrashReporter.isExpected(
          PlatformException(
            code: 'authorize_failed',
            message:
                'Failed to authorize: The operation couldn’t be completed. '
                '(org.openid.appauth.general error -3.)',
          ),
        ),
        isTrue,
      );
    });

    test('ignora Firebase sem conexão', () {
      expect(
        CrashReporter.isExpected(
          FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
        ),
        isTrue,
      );
      expect(
        CrashReporter.isExpected(
          FirebaseException(
            plugin: 'firebase_auth',
            code: 'network-request-failed',
          ),
        ),
        isTrue,
      );
    });

    test('ignora erro de rede relançado como Exception genérica', () {
      expect(
        CrashReporter.isExpected(
          Exception(
            'Erro ao buscar áreas: SocketException: Failed host lookup',
          ),
        ),
        isTrue,
      );
      expect(
        CrashReporter.isExpected(
          Exception(
            'Erro ao salvar lote no Firebase: [cloud_firestore/unavailable] '
            'The service is currently unavailable.',
          ),
        ),
        isTrue,
      );
    });

    test('relata erros reais', () {
      expect(
        CrashReporter.isExpected(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'permission-denied',
          ),
        ),
        isFalse,
      );
      expect(
        CrashReporter.isExpected(Exception('Erro ao buscar áreas: FormatException')),
        isFalse,
      );
      expect(CrashReporter.isExpected(Exception('x')), isFalse);
      expect(CrashReporter.isExpected(const FormatException('x')), isFalse);
      expect(CrashReporter.isExpected(StateError('x')), isFalse);
      expect(
        CrashReporter.isExpected(
          PlatformException(code: 'authorize_failed', message: 'outro erro'),
        ),
        isFalse,
      );
      expect(
        CrashReporter.isExpected(
          const GoogleSignInException(
            code: GoogleSignInExceptionCode.providerConfigurationError,
          ),
        ),
        isFalse,
      );
    });
  });

  group('CrashReporter.shouldReport', () {
    setUp(CrashReporter.resetRepeats);

    final t0 = DateTime(2026, 1, 1, 12);

    test('relata a primeira ocorrência', () {
      expect(CrashReporter.shouldReport('a|TypeError', t0), isTrue);
    });

    test('segura a repetição dentro do intervalo', () {
      CrashReporter.shouldReport('a|TypeError', t0);
      expect(
        CrashReporter.shouldReport(
          'a|TypeError',
          t0.add(const Duration(minutes: 4)),
        ),
        isFalse,
      );
    });

    test('volta a relatar depois do intervalo', () {
      CrashReporter.shouldReport('a|TypeError', t0);
      expect(
        CrashReporter.shouldReport(
          'a|TypeError',
          t0.add(CrashReporter.repeatWindow),
        ),
        isTrue,
      );
    });

    test('pontos ou tipos diferentes não se bloqueiam', () {
      CrashReporter.shouldReport('a|TypeError', t0);
      expect(CrashReporter.shouldReport('b|TypeError', t0), isTrue);
      expect(CrashReporter.shouldReport('a|FormatException', t0), isTrue);
    });
  });
}
