import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive/hive.dart';
import 'package:uffmobileplus/app/modules/internal_modules/user/data/models/user_data.dart';

enum UserRole { user }

class UserGoogleProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app('uffmobileplus'),
  );
   final String _userKey = "current_user";
  final String _collectionPath = "user_data";

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
        await _firestore.collection('users').doc(user.id).set(user.toJson());
      }
      await saveUserGoogleModel(user);
    } catch (e) {
      throw Exception("Erro ao criar usuario no firebase");
    }
    return user;
  }

  Future<String> saveUserGoogleModel(UserGoogleModel user) async {
    try {
      var box = Hive.isBoxOpen(_collectionPath)
          ? Hive.box<UserData>(_collectionPath)
          : await Hive.openBox<UserData>(_collectionPath);

      UserData? userData = box.get(_userKey);

      if (userData != null) {
        userData.userGoogleModel = user;
        await userData.save(); 
      } else {
        // Caso o usuário base ainda não exista, cria a instância inicial
        await box.put(_userKey, UserData(userGoogleModel: user));
      }
      return "success";
    } catch (e) {
      return "Erro ao salvar usuário Google no Hive: $e";
    }
  }

  Future<UserGoogleModel?> getUserGoogleModel() async {
    try {
      var box = Hive.isBoxOpen(_collectionPath)
          ? Hive.box<UserData>(_collectionPath)
          : await Hive.openBox<UserData>(_collectionPath);

      UserData? userData = box.get(_userKey);
      
      // Retorna apenas o modelo do Google, caso o UserData exista
      return userData?.userGoogleModel; 
    } catch (e) {
      throw Exception("Erro ao buscar usuário Google do Hive: $e");
    }
  }

  Future<String> deleteUserGoogleModel() async {
    try {
      var box = Hive.isBoxOpen(_collectionPath)
          ? Hive.box<UserData>(_collectionPath)
          : await Hive.openBox<UserData>(_collectionPath);

      UserData? userData = box.get(_userKey);

      if (userData != null) {
        userData.userGoogleModel = null;
        await userData.save(); // Salva a alteração para remover apenas este campo
        return "success";
      }

      return "Usuário não encontrado no Hive";
    } catch (e) {
      return "Erro ao deletar usuário Google do Hive: $e";
    }
  }
}
