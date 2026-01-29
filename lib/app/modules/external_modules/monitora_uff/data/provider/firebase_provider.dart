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
        'isTracked': userLocation.isTracked
      });
      if (kDebugMode) {
        print("Dados adicionados com sucesso!");
      }
    } catch (e) {
      throw Exception("Erro ao adicionar dados: $e");
    }
  }

  Stream<List<UserLocationModel>> getAllUsers() {
    try {
      return collectionRef.where('isTracked', isEqualTo: true).snapshots().map((QuerySnapshot query) {
        List<UserLocationModel> users = [];
        for (var doc in query.docs) {
          users.add(
            UserLocationModel.fromJson(doc.data() as Map<String, dynamic>),
          );
        }
        return users;
      });
    } catch (e) {
      throw Exception("Erro ao buscar usuários: $e");
    }
  }

  Future<UserLocationModel> getUserLocationById(String deviceId) async {
    try {
      final DocumentSnapshot doc = await collectionRef.doc(deviceId).get();
      if (doc.exists) {
        return UserLocationModel.fromJson(doc.data() as Map<String, dynamic>);
      } else {
        throw Exception("Documento não encontrado para o ID: $deviceId");
      }
    } catch (e) {
      throw Exception("Erro ao buscar localização do usuário por id do dispositivo: $e");
    }
  }

  Future<void> updateIsTracked(String deviceId, bool isTracked) async {
    try {
      await collectionRef.doc(deviceId).update({
        'isTracked': isTracked,
      });
      if (kDebugMode) {
        print("Campo isTracked atualizado com sucesso!");
      }
    } catch (e) {
      throw Exception("Erro ao atualizar isTracked: $e");
    }
  }
}
