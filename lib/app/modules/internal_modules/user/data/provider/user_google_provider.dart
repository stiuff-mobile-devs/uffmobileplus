import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive/hive.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_google_model.dart';

enum UserRole { user }

class UserGoogleProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app('uffmobileplus'),
  );
  final String _hiveBox = 'user_google_data';
  final String _hiveKey = 'current_user';

  Future<UserGoogleModel> createUserDoc(
    String email,
    String name,
    String uid,
    String urlImage,
  ) async {
    UserGoogleModel user;
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        user = UserGoogleModel.fromJson(data!);
      } else {
        user = UserGoogleModel(
          name: name,
          email: email,
          id: uid,
          urlImage: urlImage,
          createdAt: DateTime.now(),
        );
        await _createUserDocInFirebase(user);
      }

      await saveUserGoogleModel(user);
    } catch (e) {
      throw Exception("Erro ao criar usuario no firebase");
    }
    return user;
  }

  Future<void> _createUserDocInFirebase(UserGoogleModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toJson());
  }

  Future<String> saveUserGoogleModel(UserGoogleModel user) async {
    try {
      late Box<UserGoogleModel> box;

      if (Hive.isBoxOpen(_hiveBox)) {
        box = Hive.box<UserGoogleModel>(_hiveBox);
      } else {
        box = await Hive.openBox<UserGoogleModel>(_hiveBox);
      }

      await box.put(_hiveKey, user);
      return "success";
    } catch (e) {
      return "Erro ao salvar usuário Google no Hive: $e";
    }
  }

  Future<UserGoogleModel?> getUserGoogleModel() async {
    try {
      var box = await Hive.openBox<UserGoogleModel>(_hiveBox);
      return box.get(_hiveKey);
    } catch (e) {
      throw Exception("Erro ao buscar usuário Google do Hive: $e");
    }
  }

  Future<String> deleteUserGoogleModel() async {
    try {
      var box = await Hive.openBox<UserGoogleModel>(_hiveBox);
      await box.delete(_hiveKey);
      return "success";
    } catch (e) {
      return "Erro ao deletar usuário Google do Hive: $e";
    }
  }

  Future<String> clearAllUserGoogle() async {
    try {
      var box = await Hive.openBox<UserGoogleModel>(_hiveBox);
      await box.clear();
      return "success";
    } catch (e) {
      return "Erro ao limpar usuários Google do Hive: $e";
    }
  }

  Future<bool> hasUserGoogle() async {
    try {
      var box = await Hive.openBox<UserGoogleModel>(_hiveBox);
      return box.containsKey(_hiveKey);
    } catch (e) {
      return false;
    }
  }
}
