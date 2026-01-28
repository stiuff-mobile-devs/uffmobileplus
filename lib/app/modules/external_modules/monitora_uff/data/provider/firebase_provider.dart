import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/models/user_location_model.dart';

class FirebaseProvider {
  final String firebaseAppName = 'tracking';

  CollectionReference get collectionRef => FirebaseFirestore.instanceFor(
    app: Firebase.app(firebaseAppName),
  ).collection('locations');

  Future<void> adicionarDados(UserLocationModel userLocation) async {
    // 1. Instanciar o Firestore com o app específico
    FirebaseFirestore firestore = FirebaseFirestore.instanceFor(
      app: Firebase.app(firebaseAppName),
    );

    // 2. Referenciar a coleção e adicionar dados
    try {
      await firestore.collection('locations').doc(userLocation.id).set({
        'id': userLocation.id,
        'lat': userLocation.lat,
        'lng': userLocation.lng,
        'timestamp': userLocation.timestamp,
        'iduff': userLocation.iduff,
        'nome': userLocation.nome,
      });
      if (kDebugMode) {
        print("Dados adicionados com sucesso!");
      }
    } catch (e) {
      throw Exception("Erro ao adicionar dados: $e");
    }
  }

  Stream<List<UserLocationModel>> getAllUsers() {
    return collectionRef.snapshots().map((QuerySnapshot query) {
      List<UserLocationModel> users = [];
      for (var doc in query.docs) {
        users.add(
          UserLocationModel.fromJson(doc.data() as Map<String, dynamic>),
        );
      }
      return users;
    });
  }
}
