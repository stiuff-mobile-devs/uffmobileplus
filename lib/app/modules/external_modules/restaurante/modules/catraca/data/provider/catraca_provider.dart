import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/data/model/area.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/data/model/operator_transaction_offline.dart';
import 'package:uffmobileplus/app/data/services/crash_reporter.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca/utils/meal_shift.dart';

class CatracaOnlineProvider {
  final String _collectionPath = "operator_transactions";
  final String _areasBox = "catraca_areas";
  final String _areasKey = "last_areas";
  final String _collectionPathFirebase =
      "meals_test"; // para testes user meals_test
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app("catraca"),
  );

  /// Guarda a última lista de áreas do SCTM (JSON simples, sem adapter).
  Future<void> saveAreas(List<AreaModel> areas) async {
    try {
      final box = Hive.isBoxOpen(_areasBox)
          ? Hive.box<String>(_areasBox)
          : await Hive.openBox<String>(_areasBox);
      await box.put(
        _areasKey,
        jsonEncode([
          for (final a in areas) {'id': a.id, 'nome': a.nome},
        ]),
      );
    } catch (e) {
      // Sem a lista salva a contingência usa a fixa; não é erro grave.
      debugPrint('Erro ao salvar áreas da catraca: $e');
    }
  }

  Future<List<AreaModel>> getSavedAreas() async {
    try {
      final box = Hive.isBoxOpen(_areasBox)
          ? Hive.box<String>(_areasBox)
          : await Hive.openBox<String>(_areasBox);
      final raw = box.get(_areasKey);
      if (raw == null || raw.isEmpty) return [];
      return (jsonDecode(raw) as List)
          .whereType<Map>()
          .map((m) => AreaModel.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    } catch (e) {
      debugPrint('Erro ao ler áreas salvas da catraca: $e');
      return [];
    }
  }

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
    } catch (e, s) {
      CrashReporter.recordError(e, s, reason: 'ler transações offline da catraca no hive');
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

 Future<void> saveOperatorTransactionsToFirebaseBatch(
  List<OperatorTransactionOffline> transactions,
) async {
  try {
    final WriteBatch batch = _firestore.batch();
    List<String> allIds = transactions.map((tx) => tx.id).toList();
    Set<String> existingIds = {};

    // Descobre quem JÁ EXISTE no Firebase (de 30 em 30)
    for (int i = 0; i < allIds.length; i += 30) {
      int end = (i + 30 < allIds.length) ? i + 30 : allIds.length;
      List<String> chunkIds = allIds.sublist(i, end);

      final querySnapshot = await _firestore
          .collection(_collectionPathFirebase)
          .where(FieldPath.documentId, whereIn: chunkIds)
          .get();

      for (var doc in querySnapshot.docs) {
        existingIds.add(doc.id); // Guarda os IDs que já estão na nuvem
      }
    }

    int itemsAddedToBatch = 0;
    
    // Adiciona ao lote APENAS os dados inexistentes no Firebase
    for (var tx in transactions) {
      if (!existingIds.contains(tx.id)) {
        final docRef = _firestore.collection(_collectionPathFirebase).doc(tx.id);
        
        batch.set(docRef, tx.toJson()); 
        itemsAddedToBatch++;
      } else {
        debugPrint("Transação ${tx.id} preservada: já existe no Firebase.");
      }
    }

    // Se houver itens para salvar, executa o commit do lote
    if (itemsAddedToBatch > 0) {
      await batch.commit();
    }

  } catch (e) {
    throw Exception("Erro ao salvar lote no Firebase: $e");
  }
}

  Future<String> deleteOperatorTransactionOffline(String id) async {
    try {
      final box = Hive.isBoxOpen(_collectionPath)
          ? Hive.box<OperatorTransactionOffline>(_collectionPath)
          : await Hive.openBox<OperatorTransactionOffline>(_collectionPath);
      await box.delete(id);
      return "success";
    } catch (e, s) {
      CrashReporter.recordError(e, s, reason: 'remover transação offline da catraca do hive');
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

    // Separa as antigas em já sincronizadas (podem sair direto) e pendentes
    // (precisam chegar ao Firebase antes de sair do aparelho).
    List<dynamic> syncedKeys = [];
    Map<dynamic, OperatorTransactionOffline> pending = {};

    for (var key in box.keys) {
      OperatorTransactionOffline? transaction = box.get(key);
      if (transaction != null && transaction.entryTime.isBefore(limite24Horas)) {
        if (transaction.isSynced == true) {
          syncedKeys.add(key);
        } else {
          pending[key] = transaction;
        }
      }
    }

    // Já estão no Firebase: apaga sem reenviar (reenviar custava 1 leitura
    // por documento na checagem de existência).
    if (syncedKeys.isNotEmpty) {
      await box.deleteAll(syncedKeys);
      debugPrint('${syncedKeys.length} transações antigas já sincronizadas foram limpas do Hive.');
    }

    if (pending.isEmpty) return;

    // Pendentes: envia em lotes de 400 (o Firestore aceita até 500 escritas
    // por commit) e só apaga cada lote depois de enviado.
    const int batchSize = 400;
    final keys = pending.keys.toList();
    for (int i = 0; i < keys.length; i += batchSize) {
      final chunkKeys =
          keys.sublist(i, i + batchSize < keys.length ? i + batchSize : keys.length);
      try {
        await saveOperatorTransactionsToFirebaseBatch(
          chunkKeys.map((k) => pending[k]!).toList(),
        );
        await box.deleteAll(chunkKeys);
        debugPrint('${chunkKeys.length} transações antigas foram sincronizadas e limpas do Hive.');
      } catch (e, s) {
        CrashReporter.recordError(e, s, reason: 'sincronizar transações antigas da catraca antes da limpeza');
        debugPrint("Sem internet ou erro no Firebase. Lote mantido no Hive para evitar perda de dados: $e");
      }
    }

  } catch (e, s) {
    CrashReporter.recordError(e, s, reason: 'limpar transações offline antigas da catraca');
    debugPrint("Erro geral ao limpar transações offline: $e");
  }
}

  Future<bool> isTransactionDuplicated(
    String idUffUser,
    DateTime dateTimeToCheck,
  ) async {
    try {
      final box = Hive.isBoxOpen(_collectionPath)
          ? Hive.box<OperatorTransactionOffline>(_collectionPath)
          : await Hive.openBox<OperatorTransactionOffline>(_collectionPath);
      // Mesmo usuário já passou hoje neste mesmo turno (regra em
      // `isSameMealShift`; fora das janelas nunca é duplicado).
      return box.values.any(
        (transaction) =>
            transaction.idUser == idUffUser &&
            isSameMealShift(transaction.entryTime, dateTimeToCheck),
      );
    } catch (e) {
      throw Exception("Erro ao verificar duplicidade no RU: $e");
    }
  }
}
