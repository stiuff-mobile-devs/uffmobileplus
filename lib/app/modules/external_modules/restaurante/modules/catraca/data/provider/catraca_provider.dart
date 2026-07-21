import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/data/model/operator_transaction_offline.dart';

class CatracaOnlineProvider {
  final String _collectionPath = "operator_transactions";
  final String _collectionPathFirebase =
      "meals_test"; // para testes user meals_test
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app("catraca"),
  );

  Future<void> saveOperatorTransactionsOffline(
    OperatorTransactionOffline operatorTransactionOffline,
  ) async {
    try {
      final box = Hive.isBoxOpen(_collectionPath)
          ? Hive.box<OperatorTransactionOffline>(_collectionPath)
          : await Hive.openBox<OperatorTransactionOffline>(_collectionPath);

      await box.put(operatorTransactionOffline.id, operatorTransactionOffline);
    } catch (e) {
      throw Exception("Erro ao salvar dados do usuário no Hive: $e");
    }
  }

  Future<void> saveOperatorTransactionsOfflineBatch(
    List<OperatorTransactionOffline> transactions,
  ) async {
    try {
      if (transactions.isEmpty) return;

      final box = Hive.isBoxOpen(_collectionPath)
          ? Hive.box<OperatorTransactionOffline>(_collectionPath)
          : await Hive.openBox<OperatorTransactionOffline>(_collectionPath);

      final Map<String, OperatorTransactionOffline> transactionsMap = {
        for (var tx in transactions) tx.id: tx,
      };

      // Salva tudo no disco em uma única operação!
      await box.putAll(transactionsMap);
    } catch (e) {
      throw Exception("Erro ao salvar lote de transações no Hive: $e");
    }
  }

  Future<List<OperatorTransactionOffline>>
  getOperatorTransactionsOffline() async {
    try {
      final box = Hive.isBoxOpen(_collectionPath)
          ? Hive.box<OperatorTransactionOffline>(_collectionPath)
          : await Hive.openBox<OperatorTransactionOffline>(_collectionPath);
      return box.values.toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<OperatorTransactionOffline>> getOperatorTransactionsFromFirebase(
    String operatorEmail,
  ) async {
    try {
      final now = DateTime.now();
      final limite24Horas = now.subtract(const Duration(hours: 24));

      final snapshot = await _firestore
          .collection(_collectionPathFirebase)
          .where('idOperator', isEqualTo: operatorEmail)
          .where('entryTime', isGreaterThan: Timestamp.fromDate(limite24Horas))
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
              debugPrint('Erro ao converter documento individual: $e');
              return null;
            }
          })
          .where((t) => t != null)
          .cast<OperatorTransactionOffline>()
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar transações do Firebase: $e');
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
      final box = Hive.isBoxOpen(_collectionPath)
          ? Hive.box<OperatorTransactionOffline>(_collectionPath)
          : await Hive.openBox<OperatorTransactionOffline>(_collectionPath);
      await box.delete(id);
      return "success";
    } catch (e) {
      debugPrint("Erro ao deletar transação offline: $e");
      return "Erro ao deletar transação offline: $e";
    }
  }

  Future<void> cleanMore24hTransactionsOffline() async {
    try {
      final box = Hive.isBoxOpen(_collectionPath)
          ? Hive.box<OperatorTransactionOffline>(_collectionPath)
          : await Hive.openBox<OperatorTransactionOffline>(_collectionPath);
      DateTime now = DateTime.now();
      DateTime limite24Horas = now.subtract(const Duration(hours: 24));

      //  Filtra apenas as chaves das transações com mais de 24 horas
      List<dynamic> keysToDelete = box.keys.where((key) {
        OperatorTransactionOffline? transaction = box.get(key);
        if (transaction != null) {
          return transaction.entryTime.isBefore(limite24Horas);
        }
        return false;
      }).toList();

      // Processa uma a uma antes de deletar
      for (var key in keysToDelete) {
        OperatorTransactionOffline? transaction = box.get(key);

        if (transaction != null) {
          String transactionId = transaction.id;

          // Consulta o Firebase para ver se o ID já existe lá
          DocumentSnapshot<Map<String, dynamic>> docSnapshot = await _firestore
              .collection(_collectionPathFirebase)
              .doc(transactionId)
              .get();

          if (!docSnapshot.exists) {
            try {
              // Se NÃO estiver no Firebase, faz o upload antes de apagar do Hive
              await saveOperatorTransactionToFirebase(transaction);
            } catch (e) {
              debugPrint(
                "Erro ao salvar transação no Firebase antes de deletar do Hive: $e",
              );
              continue; // Pula para a próxima transação sem deletar esta
            }
          }

          // 3. Agora que está garantido no Firebase (ou já existia), deleta do Hive
          await box.delete(key);
        }
      }
    } catch (e) {
      throw Exception("Erro ao sincronizar e limpar transações offline: $e");
    }
  }

  Future<bool> isTransactionDuplicated(
    String idUffUser,
    DateTime dateTimeToCheck,
  ) async {
    try {
      int inicioAlmoco = 10; // 10:00
      int fimAlmoco = 15; // 14:59
      int inicioJanta = 16; // 16:00
      int fimJanta = 20; // 19:59

      final box = Hive.isBoxOpen(_collectionPath)
          ? Hive.box<OperatorTransactionOffline>(_collectionPath)
          : await Hive.openBox<OperatorTransactionOffline>(_collectionPath);
      //Descobre em qual turno a tentativa atual se encaixa
      int horaAtual = dateTimeToCheck.hour;
      bool noAlmoco =
          horaAtual >= inicioAlmoco && horaAtual < fimAlmoco; // 10:00 às 14:59
      bool naJanta =
          horaAtual >= inicioJanta && horaAtual < fimJanta; // 16:00 às 19:59

      // Se não estiver no horário de nenhum turno, não há o que duplicar
      if (!noAlmoco && !naJanta) {
        return false;
      }

      // Varre o Hive procurando se o ID já passou HOJE neste mesmo turno
      bool existeDuplicado = box.values.any((transaction) {
        // Verifica se é o mesmo IdUff do usuário
        if (transaction.idUser == idUffUser) {
          DateTime dataRegistro = transaction.entryTime;

          bool mesmoDia =
              dataRegistro.year == dateTimeToCheck.year &&
              dataRegistro.month == dateTimeToCheck.month &&
              dataRegistro.day == dateTimeToCheck.day;

          if (mesmoDia) {
            int horaRegistro = dataRegistro.hour;

            // Se a tentativa é no Almoço, verifica se ele já almoçou hoje
            if (noAlmoco) {
              return horaRegistro >= inicioAlmoco && horaRegistro < fimAlmoco;
            }

            // Se a tentativa é na Janta, verifica se ele já jantou hoje
            if (naJanta) {
              return horaRegistro >= inicioJanta && horaRegistro < fimJanta;
            }
          }
        }
        return false;
      });
      return existeDuplicado;
    } catch (e) {
      throw Exception("Erro ao verificar duplicidade no RU: $e");
    }
  }
}
