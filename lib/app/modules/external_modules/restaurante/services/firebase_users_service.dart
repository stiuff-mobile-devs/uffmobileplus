import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseUsersService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app("uffmobileplus"),
    databaseId: 'catraca',
  );

  Future<List<String>> getOperators() async {
  try {
    final docSnapshot = await _firestore.collection('users').doc('operadores').get();

    if (docSnapshot.exists && docSnapshot.data() != null) {
      final data = docSnapshot.data()!;
      
      if (data['emails'] != null) {
        return List<String>.from(data['emails']);
      }
    }
    return []; 
  } catch (e) {
    debugPrint('Erro ao buscar e-mails dos operadores: $e');
    return []; 
  }
}
}
