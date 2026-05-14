import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uffmobileplus/app/data/services/external_modules_services.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/data/models/cdc_chat_room_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/data/repository/cdc_repository.dart';

class CdcController extends GetxController {
  final ExternalModulesServices _externalModulesServices =
      Get.find<ExternalModulesServices>();
  final CdcRepository _repository = CdcRepository();

  CdcController();

  final RxBool isLoading = false.obs;
  final RxList<CdcChatRoomModel> chatRooms = <CdcChatRoomModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadChatRooms();
  }

  Future<void> loadChatRooms() async {
    try {
      isLoading.value = true;

      await _externalModulesServices.initialize();
      final String userCourse = _externalModulesServices.getUserCourse();

      final List<CdcChatRoomModel> rooms = await _repository
          .getAvailableChatRooms(userCourse: userCourse);

      chatRooms.assignAll(rooms);
    } catch (e) {
      chatRooms.clear();
      Get.snackbar('Erro', 'Nao foi possivel carregar as salas de chat.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openChatRoom(CdcChatRoomModel room) async {
    final Uri uri = Uri.tryParse(room.link) ?? Uri();
    if (uri.host.isEmpty) {
      Get.snackbar('Link invalido', 'Esta sala nao possui um link valido.');
      return;
    }

    final bool opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!opened) {
      Get.snackbar('Erro', 'Nao foi possivel abrir o link da sala.');
    }
  }
}
