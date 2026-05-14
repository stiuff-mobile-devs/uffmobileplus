import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uffmobileplus/app/modules/external_modules/cdc/data/models/cdc_chat_room_model.dart';

class CdcProvider {
  final String firebaseAppName = 'uffmobileplus';
  final String firestoreDatabaseId = 'centralcomunicacao';

  Future<List<CdcChatRoomModel>> getChatRooms() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instanceFor(
      app: Firebase.app(firebaseAppName),
      databaseId: firestoreDatabaseId,
    );

    final QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
        .collection('chats')
        .get();

    return snapshot.docs
        .map((doc) => CdcChatRoomModel.fromMap(id: doc.id, map: doc.data()))
        .where((room) => room.hasRequiredFields())
        .toList();
  }
}
