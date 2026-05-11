import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectionsController extends GetxController {
  ConnectionsController();

  final RxBool isLoading = false.obs;

  final RxBool isInternetConnected = false.obs;
  final RxBool isUmmConnected = false.obs;
  final RxBool isSctmConnected = false.obs;
  final RxBool isSaciConnected = false.obs;

  StreamSubscription<InternetStatus>? _connectionSubscription;

  Timer? _timer;
  int secondsRefresh = 10;

  @override
  void onInit() {
    super.onInit();
    _startInternetMonitoring();
    refreshConnectionsForTest();
    _startTimer(secondsRefresh);
  }

  void _startInternetMonitoring() {
    // Escuta as mudanças de status da internet
    _connectionSubscription = InternetConnection().onStatusChange.listen((
      InternetStatus status,
    ) {
      switch (status) {
        case InternetStatus.connected:
          isInternetConnected.value = true;
          break;
        case InternetStatus.disconnected:
          isInternetConnected.value = false;
          break;
      }
    });
  }

  void refreshConnectionsForTest() {
    _testUmmConnection();
    _testSctmConnection();
    _testSaciConnection();
  }

  void _startTimer(int secondsRefresh) {
    _timer = Timer.periodic(Duration(seconds: secondsRefresh), (timer) {
      debugPrint('Atualizando conexões...');
      refreshConnectionsForTest();
    });
  }

  void _testUmmConnection() {
    // Simula um teste de conexão com a UMM
    isUmmConnected.value = !isUmmConnected.value; // Alterna o status para teste
  }

  void _testSctmConnection() {
    // Simula um teste de conexão com o SCTM
    isSctmConnected.value =
        !isSctmConnected.value; // Alterna o status para teste
  }

  void _testSaciConnection() {
    // Simula um teste de conexão com o SACI
    isSaciConnected.value =
        !isSaciConnected.value; // Alterna o status para teste
  }

  @override
  void onClose() {
    _connectionSubscription?.cancel();
    _timer?.cancel();
    super.onClose();
  }
}
