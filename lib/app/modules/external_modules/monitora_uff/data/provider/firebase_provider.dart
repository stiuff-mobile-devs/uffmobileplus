import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/models/user_model.dart';

class FirebaseProvider {
  final String firebaseAppName = 'tracking';

  CollectionReference get collectionRef => FirebaseFirestore.instanceFor(
    app: Firebase.app(firebaseAppName),
  ).collection('usuarios');

  Future<void> adicionarDados(UserModel userLocation) async {
    // 1. Instanciar o Firestore com o app específico
    FirebaseFirestore firestore = FirebaseFirestore.instanceFor(
      app: Firebase.app(firebaseAppName),
    );

    // 2. Referenciar a coleção e adicionar dados
    try {
      await firestore.collection('usuarios').doc(userLocation.email).set({
        'email': userLocation.email,
        'lat': userLocation.lat,
        'lng': userLocation.lng,
        'timestamp': userLocation.timestamp,
        'nome': userLocation.nome,
        'isTracked': userLocation.isTracked,
      });
      if (kDebugMode) {
        print("Dados adicionados com sucesso!");
      }
    } catch (e) {
      throw Exception("Erro ao adicionar dados: $e");
    }
  }

  Future<void> setUser(UserModel user) async {
    FirebaseFirestore firestore = FirebaseFirestore.instanceFor(
      app: Firebase.app(firebaseAppName),
    );

    try {
      await firestore.collection('usuarios').doc(user.email).set(user.toMap());

      // TODO: um print é o melhor aqui?
      if (kDebugMode) print("Usuário criado com sucesso!");
    } catch (e) {
      throw Exception("Erro ao criar usuário!");
    }
  }

  Stream<List<UserModel>> streamAllUsers() {
    return collectionRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Stream<List<UserModel>> getAllTrackedUsers() {
    try {
      return collectionRef.where('isTracked', isEqualTo: true).snapshots().map((
        QuerySnapshot query,
      ) {
        List<UserModel> users = [];
        for (var doc in query.docs) {
          users.add(UserModel.fromMap(doc.data() as Map<String, dynamic>));
        }
        return users;
      });
    } catch (e) {
      throw Exception("Erro ao buscar usuários: $e");
    }
  }

  Future<UserModel?> getUserLocationById(String email) async {
    try {
      final DocumentSnapshot doc = await collectionRef.doc(email).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        //throw Exception("Documento não encontrado para o email: $email");
        return null;
      }
    } catch (e) {
      throw Exception(
        "Erro ao buscar localização do usuário por id do dispositivo: $e",
      );
    }
  }

  Future<void> updateIsTracked(String email, bool isTracked) async {
    try {
      await collectionRef.doc(email).update({'isTracked': isTracked});
      if (kDebugMode) {
        print("Campo isTracked atualizado com sucesso!");
      }
    } catch (e) {
      throw Exception("Erro ao atualizar isTracked: $e");
    }
  }

  Future<void> updateLocationAndTimestamp({
    required String email,
    required String nome,
    required String funcao,
    required double lat,
    required double lng,
    required DateTime timestamp,
  }) async {
    try {
      await collectionRef.doc(email).update({
        'email': email,
        'nome': nome,
        'funcao': funcao,
        'lat': lat,
        'lng': lng,
        'timestamp': timestamp,
      });
      if (kDebugMode) print("Dados atualizados no firestore com sucesso!");
    } catch (e) {
      throw Exception("Erro ao atualizar coordenadas e timestamp: $e");
    }
  }

  Future<bool> doesDocumentExist(String email) async {
    try {
      final DocumentSnapshot doc = await collectionRef.doc(email).get();
      return doc.exists;
    } catch (e) {
      throw Exception("Erro ao verificar existência do documento: $e");
    }
  }

  Future<void> deleteUserByEmail(String email) async {
    try {
      await collectionRef.doc(email).delete();
      if (kDebugMode) {
        print("Usuário deletado com sucesso!");
      }
    } catch (e) {
      throw Exception("Erro ao deletar usuário: $e");
    }
  }
}
