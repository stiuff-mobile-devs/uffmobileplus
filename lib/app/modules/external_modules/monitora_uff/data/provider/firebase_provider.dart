import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/models/user_location_model.dart';

class FirebaseProvider {
  final CollectionReference collectionRef = FirebaseFirestore.instance
    .collection('locations');

  Future<void> adicionarDados(UserLocationModel userLocation) async {
    // 1. Instanciar o Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // 2. Referenciar a coleção e adicionar dados
    try {
      await firestore.collection('locations').doc(userLocation.id).set({
        'id': userLocation.id,
        'lat': userLocation.lat,
        'lng': userLocation.lng,
        'timestamp': userLocation.timestamp,
      });
      print("Dados adicionados com sucesso!");
    } catch (e) {
      throw Exception("Erro ao adicionar dados: $e");
    }
  }

  Stream<List<UserLocationModel>> getAllUsers() {
    return collectionRef.snapshots().map((QuerySnapshot query) {
      List<UserLocationModel> users = [];
      for (var doc in query.docs) {
        users.add(UserLocationModel.fromJson(doc.data() as Map<String, dynamic>));
      }
      return users;
    });
  }
}
