import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import 'package:uffmobileplus/app/modules/external_modules/busuff/data/model/busuff_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/busuff/data/model/route_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/busuff/data/provider/busuff_api.dart';
import 'package:uffmobileplus/app/modules/external_modules/busuff/data/provider/busuff_preferences.dart';
import 'package:uffmobileplus/app/modules/external_modules/busuff/utils/bus_status.dart';
import 'package:uffmobileplus/app/modules/external_modules/busuff/utils/busuff_routes.dart';
import 'package:uffmobileplus/app/utils/ui_components/app_popups.dart';

class BusuffController extends GetxController {
  BusuffController();

  final MapController mapController = MapController();
  final BusuffApiClient _api = BusuffApiClient();
  final BusuffPreferences _preferences = BusuffPreferences();

  final List<MunicipioModel> municipios = busuffMunicipios;
  final Rx<MunicipioModel> municipio = busuffMunicipios.first.obs;
  final RxInt routeIndex = 0.obs;

  /// Última posição de cada ônibus, por placa.
  final RxMap<String, BusuffModel> positions = <String, BusuffModel>{}.obs;
  final Rxn<LatLng> userPosition = Rxn<LatLng>();

  /// Relógio usado no "atualizado há X"; avança a cada consulta à API.
  final Rx<DateTime> now = DateTime.now().obs;

  static const Duration _pollInterval = Duration(seconds: 5);
  static const LocationSettings _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 15,
  );

  Timer? _pollTimer;
  StreamSubscription<Position>? _positionStream;
  bool _mapReady = false;
  bool _locating = false;

  RouteModel get route => municipio.value.routes[routeIndex.value];
  BusuffModel? get bus => route.isTracked ? positions[route.plate] : null;
  BusStatus get busStatus => busStatusOf(bus, now.value);

  String routeLabel(RouteModel r) => r.number == null
      ? 'busuff_rota_unica'.tr
      : 'busuff_rota_n'.trParams({'n': '${r.number}'});

  @override
  void onReady() {
    super.onReady();
    _restoreSelection();
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    _positionStream?.cancel();
    mapController.dispose();
    super.onClose();
  }

  // ---------------- SELEÇÃO ----------------

  Future<void> _restoreSelection() async {
    final (savedId, savedRoute) = await _preferences.load();
    final saved = municipios.firstWhereOrNull((m) => m.id == savedId);
    if (saved != null) {
      municipio.value = saved;
      routeIndex.value = savedRoute.clamp(0, saved.routes.length - 1);
    }
    _onSelectionChanged(save: false);
  }

  Future<void> chooseMunicipio() async {
    final chosen = await AppPopups.choose<MunicipioModel>(
      title: 'busuff_escolha_municipio'.tr,
      message: 'busuff_lembrar_escolha'.tr,
      icon: Icons.location_city_rounded,
      selected: municipio.value,
      options: municipios
          .map(
            (m) => PopupOption(
              value: m,
              label: m.name,
              description: _municipioDescription(m),
              icon: m.isTracked
                  ? Icons.sensors_rounded
                  : Icons.map_outlined,
            ),
          )
          .toList(),
    );
    if (chosen == null || chosen == municipio.value) return;
    municipio.value = chosen;
    routeIndex.value = 0;
    _onSelectionChanged();
  }

  String _municipioDescription(MunicipioModel m) {
    final count = '${m.routes.length}';
    if (m.isTracked) return 'busuff_desc_ao_vivo'.trParams({'n': count});
    if (!m.routes.any((r) => r.hasItinerary)) {
      return 'busuff_desc_sem_itinerario'.tr;
    }
    return m.routes.length > 1
        ? 'busuff_desc_itinerarios'.trParams({'n': count})
        : 'busuff_desc_itinerario'.tr;
  }

  void selectRoute(int index) {
    if (index == routeIndex.value) return;
    routeIndex.value = index;
    _onSelectionChanged();
  }

  /// [save] é false só na abertura da tela, quando a seleção vem das
  /// preferências; é também o único momento em que pedimos a permissão de
  /// localização sem o usuário tocar no botão.
  void _onSelectionChanged({bool save = true}) {
    if (save) _preferences.save(municipio.value.id, routeIndex.value);
    if (municipio.value.isTracked) {
      _startPolling();
      _startLocation(askPermission: !save);
      _fitRoute();
    } else {
      _pollTimer?.cancel();
      _pollTimer = null;
      _mapReady = false; // o mapa sai da tela
    }
  }

  // ---------------- POSIÇÃO DOS ÔNIBUS ----------------

  void _startPolling() {
    if (_pollTimer != null) return;
    _fetchPositions();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _fetchPositions());
  }

  Future<void> _fetchPositions() async {
    final plates = municipio.value.routes
        .where((r) => r.isTracked)
        .map((r) => r.plate!)
        .toSet();
    final result = await _api.getLastPositions(plates);
    // Em caso de falha mantém a última posição; o status mostra a idade dela.
    if (result != null) positions.assignAll(result);
    now.value = DateTime.now();
  }

  // ---------------- MAPA ----------------

  void onMapReady() {
    _mapReady = true;
    _fitRoute();
  }

  void _fitRoute() {
    final points = [...route.polyline, ...route.dashedPolyline];
    if (!_mapReady || points.isEmpty) return;
    mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        // Folga para os botões à direita e o cartão da rota embaixo.
        padding: const EdgeInsets.fromLTRB(40, 40, 80, 200),
      ),
    );
  }

  void _moveTo(LatLng target) {
    if (!_mapReady) return;
    mapController.move(target, mapController.camera.zoom);
  }

  void centerOnBus() {
    final b = bus;
    // Sem sinal o marcador não aparece, então não há para onde centralizar.
    if (b == null || busStatus == BusStatus.noSignal) {
      AppPopups.info(
        'busuff_sem_posicao_msg'.tr,
        title: 'busuff_sem_posicao_titulo'.tr,
      );
      return;
    }
    _moveTo(LatLng(b.latitude!, b.longitude!));
  }

  Future<void> centerOnUser() async {
    final position = userPosition.value;
    if (position != null) {
      _moveTo(position);
      return;
    }
    await _startLocation(askPermission: true, fromButton: true);
  }

  // ---------------- LOCALIZAÇÃO DO USUÁRIO ----------------

  /// Liga o ponto do usuário no mapa. O mapa funciona sem ele: sem serviço
  /// ou sem permissão, só avisamos quando o usuário tocou no botão.
  Future<void> _startLocation({
    required bool askPermission,
    bool fromButton = false,
  }) async {
    if (_positionStream != null || _locating) return;
    _locating = true;
    try {
      await _listenToLocation(askPermission, fromButton);
    } finally {
      _locating = false;
    }
  }

  Future<void> _listenToLocation(bool askPermission, bool fromButton) async {

    if (!await Geolocator.isLocationServiceEnabled()) {
      if (fromButton) {
        AppPopups.show(
          'busuff_localizacao_desligada_msg'.tr,
          title: 'busuff_localizacao_desligada_titulo'.tr,
          type: PopupType.warning,
          actionLabel: 'busuff_ativar'.tr,
          onAction: () => Geolocator.openLocationSettings(),
        );
      }
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied && askPermission) {
      final accepted = await AppPopups.confirm(
        title: 'busuff_permissao_titulo'.tr,
        message: 'busuff_permissao_msg'.tr,
        icon: Icons.my_location_rounded,
        confirmText: 'busuff_permitir'.tr,
        cancelText: 'busuff_agora_nao'.tr,
      );
      if (accepted) permission = await Geolocator.requestPermission();
    }

    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      if (fromButton) {
        AppPopups.show(
          'busuff_sem_permissao_msg'.tr,
          title: 'busuff_sem_permissao_titulo'.tr,
          type: PopupType.warning,
          actionLabel: 'busuff_abrir_ajustes'.tr,
          onAction: () => Geolocator.openAppSettings(),
        );
      }
      return;
    }

    try {
      final p = await Geolocator.getCurrentPosition(
        locationSettings: _locationSettings,
      );
      userPosition.value = LatLng(p.latitude, p.longitude);
      if (fromButton) _moveTo(userPosition.value!);
    } catch (e) {
      debugPrint('busuff: erro ao obter a localização: $e');
    }

    _positionStream =
        Geolocator.getPositionStream(locationSettings: _locationSettings)
            .listen(
              (p) => userPosition.value = LatLng(p.latitude, p.longitude),
              onError: (e) => debugPrint('busuff: erro na localização: $e'),
            );
  }
}
