import 'package:app_links/app_links.dart';
import 'package:get/get.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  
  factory DeepLinkService() {
    return _instance;
  }
  
  DeepLinkService._internal();
  
  late final AppLinks _appLinks;
  bool _isInitialized = false;
  String? _pendingRoute;
  Map<String, String>? _pendingArguments;
  String? _lastHandledUri;
  DateTime? _lastHandledAt;
  
  /// Domínio base do Firebase Hosting
  static const String domain = 'https://uff-mobile-plus.web.app';
  
  /// Mapa de rotas para módulos
  /// Key: path do URL → Value: rota da aplicação
  static const Map<String, String> deepLinkRouteMap = {
    
    // Rotas principais
    'splash': Routes.SPLASH,
    'login': Routes.LOGIN,
    'home': Routes.HOME,
    'settings': Routes.SETTINGS,
    'about': Routes.ABOUT,
    'profile': Routes.CHOOSE_PROFILE,
    
    // Restaurante
    'restaurante': Routes.RESTAURANT_MODULES,
    'restaurante/cardapio': Routes.BANDEJAPP,
    'restaurante/pagamento': Routes.PAY_RESTAURANT,
    'restaurante/recarga': Routes.RECHARGE_CARD,
    'restaurante/saldo': Routes.BALANCE_STATEMENT,
    'restaurante/sos': Routes.SOS,
    
    // Carteirinha Digital
    'carteirinha': Routes.CARTEIRINHA_DIGITAL,
    
    // Plano de Estudos
    'plano-estudos': Routes.STUDY_PLAN,
    
    // Rádio
    'radio': Routes.RADIO,
    
    // Histórico
    'historico': Routes.HISTORICO,
    
    // Periódicos
    'periodicos': Routes.PAPERS,
    
    // Unitevê
    'uniteve': Routes.UNITEVE,
    'uniteve/historia': Routes.UNITEVE_HISTORIA,
    'uniteve/contato': Routes.UNITEVE_CONTATO,
    
    // Monitora UFF
    'monitora': Routes.MONITORA_UFF,
    'monitora/formulario': Routes.MONITORA_UFF_FORM,
    
    // Repositório Institucional
    'repositorio': Routes.REPOSITORIO_INSTITUCIONAL,
    
    // Internacional
    'internacional': Routes.INTERNACIONAL,
    
    // Central de Atendimento
    'central-atendimento': Routes.CENTRAL_DE_ATENDIMENTO,
    
    // Busuff
    'busuff': Routes.BUSUFF,
    
    // CDC
    'cdc': Routes.CDC,
  };
  
  /// Inicializa o serviço de deep linking
  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    _appLinks = AppLinks();
    
    // Ouve links recebidos enquanto o app está rodando
    _appLinks.uriLinkStream.listen(
      (uri) => _handleDeepLink(uri),
      onError: (err) => print('❌ Erro ao processar deep link: $err'),
    );
    
    // Verifica se há um link inicial (app aberto via link)
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      _handleDeepLink(initialLink);
    }

  }
  
  /// Processa o deep link e navega para a rota apropriada
  void _handleDeepLink(Uri uri) {
    final uriAsString = uri.toString();
    if (_isDuplicatedEvent(uriAsString)) {
      print('ℹ️ Deep link duplicado ignorado: $uriAsString');
      return;
    }

    print('🔗 Deep link recebido: $uriAsString');

    // Valida o domínio
    if (!_isValidDomain(uri)) {
      print('❌ Domínio inválido: ${uri.host}');
      return;
    }
    
    // Extrai o path e remove barras extras
    String path = uri.path.replaceFirst('/', '').trim();
    
    // Trata argumentos de query (parâmetros)
    final queryParams = uri.queryParameters;
    
    // Encontra a rota correspondente
    String? targetRoute = _getRouteFromPath(path);
    
    if (targetRoute != null) {
      print('✅ Navegando para: $targetRoute');

      _navigateOrQueue(targetRoute, queryParams.isEmpty ? null : queryParams);
    } else {
      print('⚠️ Rota não mapeada para path: $path');
      // Navega para home como fallback
      Get.offNamed(Routes.HOME);
    }
  }

  void _navigateOrQueue(String route, Map<String, String>? arguments) {
    final navReady = Get.key.currentState != null;
    final currentRoute = Get.currentRoute;

    // No cold start, o main usa essa rota como initialRoute.
    if (!navReady || currentRoute.isEmpty || currentRoute == Routes.SPLASH) {
      _pendingRoute = route;
      _pendingArguments = arguments;
      print('⏳ Deep link pendente aguardando inicialização da app.');
      return;
    }

    Get.toNamed(route, arguments: arguments);
  }

  String? takeStartupRoute() {
    final route = _pendingRoute;
    _pendingRoute = null;
    _pendingArguments = null;
    return route;
  }

  bool consumePendingNavigation() {
    final route = _pendingRoute;
    if (route == null) return false;
    if (Get.key.currentState == null) return false;

    final arguments = _pendingArguments;
    _pendingRoute = null;
    _pendingArguments = null;

    print('🚀 Consumindo navegação pendente para: $route');
    Get.offAllNamed(route, arguments: arguments);
    return true;
  }

  bool _isDuplicatedEvent(String uri) {
    final now = DateTime.now();
    final isSameAsLast = _lastHandledUri == uri;
    final isCloseInTime = _lastHandledAt != null &&
        now.difference(_lastHandledAt!).inMilliseconds < 1500;

    _lastHandledUri = uri;
    _lastHandledAt = now;

    return isSameAsLast && isCloseInTime;
  }
  
  /// Valida se o domínio é seguro
  bool _isValidDomain(Uri uri) {
    // Seus domínios autorizados (pode aceitar múltiplos)
    const List<String> validHosts = [
      'uff-mobile-plus.web.app',
      'uff-mobile-plus.firebaseapp.com',
    ];
    
    return validHosts.contains(uri.host);
  }
  
  /// Mapeia o path do URL para uma rota do app
  String? _getRouteFromPath(String path) {
    if (path.isEmpty) return Routes.HOME;
    return deepLinkRouteMap[path];
  }
  
  /// Gera uma URL de deep link (útil para logs, testes, etc)
  static String generateDeepLink(String path, {Map<String, String>? params}) {
    final uri = Uri.https('uff-mobile-plus.web.app', '/$path', params);
    return uri.toString();
  }
}
