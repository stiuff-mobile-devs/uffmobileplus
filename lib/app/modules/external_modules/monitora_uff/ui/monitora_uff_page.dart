import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/controller/tracking_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/controller/permissions_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/controller/user_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/models/user_model.dart';
import 'package:uffmobileplus/app/utils/color_pallete.dart';
import 'package:uffmobileplus/app/routes/app_routes.dart';


class MonitoraUFFPage extends StatelessWidget {
  const MonitoraUFFPage({super.key});

  UserController get userCtrl => Get.find<UserController>();
  PermissionsController get permissionsCtrl =>
      Get.find<PermissionsController>();
  TrackingController get trackingCtrl => Get.find<TrackingController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _appBar(), body: _body(context));
  }

  AppBar _appBar() {
    return AppBar(
      title: const Text('Monitora UFF'),
      centerTitle: true,
      elevation: 8,
      foregroundColor: Colors.white,
      flexibleSpace: Container(
        decoration: BoxDecoration(gradient: AppColors.appBarBottomGradient()),
      ),
      leading: IconButton(onPressed: Get.back, icon: Icon(Icons.arrow_back)),
    );
  }

  Widget _centralizeButton() {
    return Obx(
      () => permissionsCtrl.arePermissionsGranted() && userCtrl.isMonitor()
          ? Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                heroTag: "btnCentralizeMap",
                backgroundColor: AppColors.lightBlue(),
                onPressed: trackingCtrl.centerMapOnCurrentLocation,
                child: Icon(Icons.my_location, color: AppColors.darkBlue()),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _body(BuildContext context) {
    return Obx(() {
      if (userCtrl.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (userCtrl.isAdmin()) {
        return _adminDashboard(context);
      } else if (userCtrl.isMonitor()) {
        return _monitorPage();
      }

      return _unauthorizedPage();
    });
  }

  /// Usuário verá essa tela apenas se todas as permissões necessárias já tiverem
  /// sido concedidas.
  Widget mapa() {
    return FlutterMap(
      mapController: trackingCtrl.mapController,
      options: MapOptions(
        initialCenter: LatLng(
          trackingCtrl.position.latitude,
          trackingCtrl.position.longitude,
        ),
      ),
      children: [
        tile(),
        firebaseMarkers(),
        toggleButton(),
        _centralizeButton(),
      ],
    );
  }

  /// Usuário verá essa tela apenas se algumas das permissões necessárias
  /// ainda não tiver sido concedida.
  Widget permissionScreen() {
    return Container(
      decoration: BoxDecoration(gradient: AppColors.appBarBottomGradient()),
      child: Obx(
        () => Align(
          alignment: Alignment.center,
          child: IntrinsicWidth(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.darkBlue(),
                        ),
                        onPressed:
                            permissionsCtrl.requestNotificationPermission,
                        child: const Text("Permitir notificação"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      permissionsCtrl.hasNotificationPermission.value
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.darkBlue(),
                        ),
                        onPressed: permissionsCtrl.requestWhenInUsePermission,
                        child: const Text("Permitir localização (durante uso)"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      permissionsCtrl.hasWhenInUseLocationPermission.value
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.darkBlue(),
                        ),
                        onPressed: permissionsCtrl.requestAlwaysPermission,
                        child: const Text("Permitir localização (sempre)"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      permissionsCtrl.hasAlwaysLocationPermission.value
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget tile() {
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'br.uff.sti.uffmobileplus',
    );
  }

  Widget firebaseMarkers() {
    return Obx(
      () => MarkerLayer(
        markers: trackingCtrl.firebaseUsers
            .map(
              (user) => Marker(
                point: LatLng(user.lat ?? 0.0, user.lng ?? 0.0), // TODO: encontrar uma solução melhor.
                child: GestureDetector(
                  onTap: () => Get.dialog(popUp(user)),
                  child: Icon(
                    Icons.location_pin,
                    color: trackingCtrl.setMarkerColor(user),
                    size: 50,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget popUp(UserModel user) {
    return AlertDialog(
      backgroundColor: AppColors.darkBlue(),
      title: Text(
        "Monitor",
        style: TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.nome ?? user.email,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Última atualização: ${user.timestamp}",
            style: TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      )
    );
  }

  Widget toggleButton() {
    return userCtrl.isMonitor()
        ? Positioned(
            top: 16,
            right: 16,
            child: Obx(
              () => FloatingActionButton(
                heroTag: "btnToggleTracking",
                onPressed: trackingCtrl.toggleService,
                backgroundColor: trackingCtrl.isTrackingEnabled.value
                    ? Colors.green
                    : Colors.red,
                child: Icon(
                  trackingCtrl.isTrackingEnabled.value
                      ? Icons.location_on
                      : Icons.location_off,
                  color: Colors.white,
                ),
              ),
            ),
          )
        : Container();
  }

  Widget _adminDashboard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: AppColors.darkBlueToBlackGradient()),
      child: PersistentTabView(
        context,
        screens: [mapa(), _adminPage()],
        items: [
          PersistentBottomNavBarItem(
            icon: Icon(Icons.map, color: Colors.white),
          ),
          PersistentBottomNavBarItem(
            icon: Icon(
              Icons.admin_panel_settings_outlined,
              color: Colors.white,
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
      ),
    );
  }

  Widget _adminPage() {
    return Container(
      decoration: BoxDecoration(gradient: AppColors.darkBlueToBlackGradient()),
      child: Column(
        children: [
          Expanded(child: _usersList()),
          _addNewUserButton(),
        ],
      ),
    );
  }


  Widget _usersList() {
    return Obx(
      () => ListView(
        children: userCtrl.allFirebaseUsers
            .map(
              (user) => Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.nome ?? user.email,
                            style: TextStyle(color: AppColors.darkBlue()),
                          ),
                          Text(
                            user.funcao,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.mediumBlue(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.toNamed(Routes.MONITORA_UFF_FORM, arguments: user), 
                      child: Icon(Icons.edit, color: Colors.blueAccent),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        Get.dialog(_deleteUserPopUp(user.email));
                      },
                      child: Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _deleteUserPopUp(String email) {
    return AlertDialog(
      title: Text("Atenção"),
      content: Text("Deseja mesmo remover esse usuário?"),
      actions: [
        TextButton(
          onPressed: () {
            userCtrl.deleteUser(email);
            Get.back();
          },
          child: const Text("Deletar"),
        ),
        TextButton(onPressed: Get.back, child: const Text("Cancelar")),
      ],
    );
  }

  Widget _addNewUserButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.toNamed(Routes.MONITORA_UFF_FORM), 
          child: Center(
            child: Icon(Icons.add, size: 32, color: AppColors.darkBlue()),
          ),
        ),
      ),
    );
  }

  Widget _monitorPage() {
    return Obx(
      () =>
          permissionsCtrl.arePermissionsGranted() ? mapa() : permissionScreen(),
    );
  }

  Widget _unauthorizedPage() {
    return Center(
      child: Text("Você não tem permissão para utilizar este serviço."),
    );
  }
}
