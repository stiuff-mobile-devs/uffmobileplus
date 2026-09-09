import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uffmobileplus/app/config/secrets.dart';
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';
import 'package:uffmobileplus/app/modules/external_modules/sos/data/provider/sos_provider.dart';
import 'package:uffmobileplus/app/modules/external_modules/sos/data/repository/sos_repository.dart';
import 'package:uffmobileplus/app/modules/external_modules/sos/data/services/sos_background_service.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/utils/ui_components/custom_alert_dialog.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class SosController extends GetxController {
  final ExternalModulesServices _externalModulesServices =
      Get.find<ExternalModulesServices>();

  final SosRepository _repository = Get.find<SosRepository>();

  final FlutterBackgroundService _service = FlutterBackgroundService();

  final RxBool isLoading = false.obs;
  final RxBool isTracking = false.obs;
  bool _isPermissionGranted = false;
  bool _isUserLoaded = false;
  String? _matricula;
  String? _nome;
  String? _email;
  String? _dispatchIncidentId;
  StreamSubscription? _sosStoppedSub;

  @override
  void onInit() {
    super.onInit();
    _inicializarTudo();
  }

  Future<void> _inicializarTudo() async {
    try {
      await _externalModulesServices.initialize();
      _matricula = _externalModulesServices.getUserMatricula();
      _nome = _externalModulesServices.getUserName();
      _email = await _externalModulesServices.getEmail();

      if (_matricula == null ||
          _matricula!.isEmpty ||
          _nome == null ||
          _nome!.isEmpty ||
          _email == null ||
          _email!.isEmpty) {
        _mostrarDialogoBloqueio(
          "erro".tr,
          "nao_foi_possivel_carregar_dados".tr,
        );
        return;
      }

      _isUserLoaded = true;
    } catch (e) {
      _mostrarDialogoBloqueio("erro".tr, "nao_foi_possivel_carregar_dados".tr);
      return;
    }
    await _verificarPermissoesGPS();
  }

  Future<void> _setPlatformSpecifics() async {
    await _service.configure(
      iosConfiguration: IosConfiguration(),
      androidConfiguration: AndroidConfiguration(
        onStart: onSosStart,
        isForegroundMode: true,
        autoStart: false,
        autoStartOnBoot: false,
        initialNotificationTitle: 'sos_notificacao_titulo'.tr,
        initialNotificationContent: 'sos_notificacao_descricao'.tr,
      ),
    );
  }

  Future<void> _verificarPermissoesGPS() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _mostrarDialogoBloqueio("gps_desligado".tr, "gps_desligado_msg".tr);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          _mostrarDialogoBloqueio(
            "permissao_negada".tr,
            "permissao_negada_msg".tr,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _mostrarDialogoBloqueio(
          "permissao_bloqueada".tr,
          "permissao_bloqueada_msg".tr,
          abrirConfiguracoes: true,
        );
        return;
      }

      _isPermissionGranted = true;
    } catch (e) {
      _mostrarDialogoBloqueio("erro".tr, "falha_ao_verificar_gps".tr);
    }
  }

  void _mostrarDialogoBloqueio(
    String titulo,
    String mensagem, {
    bool abrirConfiguracoes = false,
    DialogType tipo = DialogType.warning,
  }) {
    if (Get.context == null) return;

    customAlertDialog(
      Get.context!,
      title: titulo,
      desc: mensagem,
      dialogType: tipo,
      dismissOnBackKeyPress: false,
      dismissOnTouchOutside: false,
      autoDismiss: true,
      btnConfirmText: abrirConfiguracoes ? "configuracoes".tr : "voltar".tr,
      btnConfirmColor: AppColors.darkBlue(),
      onConfirm: () {
        if (abrirConfiguracoes) {
          Geolocator.openAppSettings();
        }
        Get.back();
      },
    ).show();
  }

  Future<void> sendSos() async {
    if (!_isUserLoaded) return;
    if (!_isPermissionGranted) {
      await _verificarPermissoesGPS();
      if (!_isPermissionGranted) return;
    }
    if (isTracking.value) return;

    isLoading.value = true;

    try {
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 10));

      final SosDispatchResult? startResult = await _sendStartDispatch(position);
      _dispatchIncidentId = startResult?.incidentId;

      // Abre o Google Meet se o servidor retornar link
      final String? meetLink = startResult?.meetLink;
      if (meetLink != null && meetLink.isNotEmpty) {
        final Uri meetUri = Uri.parse(meetLink);
        if (await canLaunchUrl(meetUri)) {
          await launchUrl(meetUri, mode: LaunchMode.externalApplication);
        }
      }

      // Inicia o background service — responsável por todo GPS + HTTP enquanto
      // o app estiver em segundo plano (ex: usuário abriu o Google Meet)
      try {
        await _startBackgroundService();
      } catch (e) {
        // Non-fatal: SOS já foi enviado ao servidor, background não iniciou
      }

      isTracking.value = true;

      Get.snackbar(
        'sos'.tr,
        'sos_sucesso_envio'.tr,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white, size: 30),
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(10),
      );
    } catch (e) {
      Get.snackbar(
        "erro".tr,
        "sos_falha_envio".tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(10),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<SosDispatchResult?> _sendStartDispatch(Position position) async {
    final String matricula = _matricula!;
    final String nome = _nome!;
    final String email = _email!;

    return _repository.sendDispatch(
      incidentId: _dispatchIncidentId,
      action: 'start',
      pointType: 'fixed',
      status: 'active',
      nome: nome,
      matricula: matricula,
      email: email,
      lat: position.latitude,
      lng: position.longitude,
    );
  }

  Future<void> _startBackgroundService() async {
    await _setPlatformSpecifics();
    await _service.startService();

    final String matricula = _matricula!;
    final String nome = _nome!;
    final String email = _email!;

    // Envia configuração para o isolate do background service
    _service.invoke('sosConfig', {
      'incidentId': _dispatchIncidentId,
      'apiUrl': Secrets.sosApiUrl,
      'matricula': matricula,
      'nome': nome,
      'email': email,
    });

    // Escuta o sinal de parada iniciado pelo servidor
    _sosStoppedSub?.cancel();
    _sosStoppedSub = _service.on('sosStopped').listen((_) {
      isTracking.value = false;
      _dispatchIncidentId = null;
      _sosStoppedSub?.cancel();
      _sosStoppedSub = null;
    });
  }

  Future<void> stopSosTracking() async {
    _sosStoppedSub?.cancel();
    _sosStoppedSub = null;

    // Manda o background service enviar o stop para a API e encerrar
    try {
      _service.invoke('stopSos');
    } catch (e) {
      // ignore
    }

    _dispatchIncidentId = null;
    isTracking.value = false;
  }

  @override
  void onClose() {
    _sosStoppedSub?.cancel();
    super.onClose();
  }
}
