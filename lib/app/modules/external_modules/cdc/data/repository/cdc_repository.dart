import 'package:uffmobileplus/app/modules/external_modules/cdc/data/models/cdc_chat_room_model.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/data/provider/cdc_provider.dart';

class CdcRepository {
  final CdcProvider _provider = CdcProvider();

  Future<List<CdcChatRoomModel>> getAvailableChatRooms({
    required String userCourse,
  }) async {
    final List<CdcChatRoomModel> rooms = await _provider.getChatRooms();

    return rooms.where((room) => room.isVisibleForCourse(userCourse)).toList();
  }
}
