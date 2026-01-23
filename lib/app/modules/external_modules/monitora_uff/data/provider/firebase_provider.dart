import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uffmobileplus/app/modules/external_modules/monitora_uff/models/user_location_model.dart';

class FirebaseProvider {
  Future<void> adicionarDados(UserLocationModel userLocation) async {
    // 1. Instanciar o Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // 2. Referenciar a coleção e adicionar dados
    try {
      await firestore.collection('locations').doc(userLocation.id).set({
        'lat': userLocation.lat,
        'lng': userLocation.long,
        'timestamp': userLocation.timestamp,
      });
      print("Dados adicionados com sucesso!");
    } catch (e) {
      throw Exception("Erro ao adicionar dados: $e");
    }
  }

  Future<List<UserLocationModel>> buscarTodos() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      QuerySnapshot snapshot = await firestore.collection('locations').get();

      // Para debugar
      for (var doc in snapshot.docs) {
        print(doc.data());
      }
      
      return snapshot.docs
          .map(
            (doc) =>
                UserLocationModel.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception("Erro ao buscar dados: $e");
    }
  }
}
