import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive/hive.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/data/model/operator_transaction_offline.dart';

class CatracaOnlineProvider {
  final String _collectionPath = "operator_transactions";
  final String _collectionPathFirebase = "meals";
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app("uffmobileplus"),
    databaseId: 'catraca',
  );

  Future<String> saveOperatorTransactionsOffline(
    OperatorTransactionOffline operatorTransactionOffline,
  ) async {
    try {
      var box = await Hive.openBox<OperatorTransactionOffline>(_collectionPath);
      await box.put(operatorTransactionOffline.id, operatorTransactionOffline);
      return "success";
    } catch (e) {
      return "Erro ao salvar dados do usuário no Hive: $e";
    }
  }

  Future<List<OperatorTransactionOffline>>
  getOperatorTransactionsOffline() async {
    try {
      var box = await Hive.openBox<OperatorTransactionOffline>(_collectionPath);
      return box.values.toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<OperatorTransactionOffline>> getOperatorTransactionsFromFirebase(
    String iduffOperator,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionPathFirebase)
          .where('idUffOperator', isEqualTo: iduffOperator)
          .get();
      return snapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              return OperatorTransactionOffline.fromJson(
                Map<String, dynamic>.from(data),
              );
            } catch (e) {
              // ignora documentos com formato inválido
              return null;
            }
          })
          .where((t) => t != null)
          .cast<OperatorTransactionOffline>()
          .toList();
    } catch (e) {
      // Em caso de erro, retorna lista vazia
      return [];
    }
  }

  Future<String> saveOperatorTransactionToFirebase(
    OperatorTransactionOffline operatorTransactionOffline,
  ) async {
    try {
      final Map<String, dynamic> data = operatorTransactionOffline.toJson();

      final docRef = _firestore
          .collection(_collectionPathFirebase)
          .doc(operatorTransactionOffline.id);

      await docRef.set(data, SetOptions(merge: true));
      return "success";
    } catch (e) {
      throw Exception("Erro ao salvar no Firebase: $e");
    }
  }

  Future<String> deleteOperatorTransactionOffline(String id) async {
    try {
      var box = await Hive.openBox<OperatorTransactionOffline>(_collectionPath);
      await box.delete(id);
      return "success";
    } catch (e) {
      return "Erro ao deletar transação offline: $e";
    }
  }
}
