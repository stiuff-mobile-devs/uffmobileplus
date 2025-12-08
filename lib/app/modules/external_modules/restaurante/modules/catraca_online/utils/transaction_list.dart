import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca_online/controller/catraca_online_controller.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca_online/data/model/operator_transaction.dart';
import 'package:uffmobileplus/app/modules/external_modules/restaurante/modules/catraca_online/data/model/operator_transaction_offline.dart';

class TransactionList extends StatefulWidget {
  final List<OperatorTransactionModel> operatorTransactions;
  final List<OperatorTransactionOffline> operatorTransactionsOffline;
  final List<OperatorTransactionOffline> operatorTransactionsFromFirebase;

  const TransactionList(
    this.operatorTransactions,
    this.operatorTransactionsOffline,
    this.operatorTransactionsFromFirebase, {
    super.key,
  });

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  bool showOfflineLocal = true;
  bool showFirebase = true;
  bool showOnline = true;

  Widget _buildHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildOfflineRow(
    OperatorTransactionOffline tx, {
    Color textColor = Colors.orange,
    bool showFirebaseIcon = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(
            child: Text(
              DateFormat('dd/MM/yy HH:mm').format(tx.entryTime),
              style: TextStyle(color: textColor),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Text(
              tx.idUffUser ?? '',
              style: TextStyle(color: textColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (showFirebaseIcon)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(Icons.cloud, color: textColor, size: 20.0),
            ),
        ],
      ),
    );
  }

  Widget _buildOnlineRow(OperatorTransactionModel tx) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(
            child: Text(
              DateFormat('dd/MM/yy HH:mm').format(tx.date!),
              style: const TextStyle(color: Colors.green),
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Text(
              tx.name ?? '',
              style: const TextStyle(color: Colors.green),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text("R\$ ${tx.value}", style: const TextStyle(color: Colors.green)),
          const Icon(
            Icons.keyboard_arrow_right,
            color: Colors.green,
            size: 20.0,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final CatracaOnlineController controller =
        Get.find<CatracaOnlineController>();

    final offlineList = widget.operatorTransactionsOffline;
    final firebaseList = widget.operatorTransactionsFromFirebase;
    final onlineList = widget.operatorTransactions;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilterChip(
                  label: const Text('Offline Local'),
                  selected: showOfflineLocal,
                  selectedColor: Colors.orange.shade200,
                  onSelected: (v) => setState(() => showOfflineLocal = v),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Firebase'),
                  selected: showFirebase,
                  selectedColor: Colors.green.shade200,
                  onSelected: (v) => setState(() => showFirebase = v),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Online'),
                  selected: showOnline,
                  selectedColor: Colors.green.shade200,
                  onSelected: (v) => setState(() => showOnline = v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // If nothing selected show message
          if (!showOfflineLocal && !showFirebase && !showOnline)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Text(
                "Nenhuma fonte selecionada. Ative pelo menos uma opção.",
                style: TextStyle(color: Colors.white),
              ),
            ),

          // Offline saved (local) - orange
          if (showOfflineLocal) ...[
            _buildHeader("Últimas Transações (Offline Local)", Colors.orange),
            if (offlineList.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: Text(
                  "Nenhuma transação offline local.",
                  style: TextStyle(color: Colors.orange),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: offlineList.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final tx = offlineList[index];
                  return GestureDetector(
                    onTap: () {},
                    child: _buildOfflineRow(tx, textColor: Colors.orange),
                  );
                },
              ),
            const SizedBox(height: 12),
          ],

          if (showFirebase) ...[
            _buildHeader("Últimas Transações (Firebase)", Colors.green),
            if (firebaseList.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: Text(
                  "Nenhuma transação no Firebase.",
                  style: TextStyle(color: Colors.green),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: firebaseList.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final tx = firebaseList[index];
                  return GestureDetector(
                    onTap: () {},
                    child: _buildOfflineRow(
                      tx,
                      textColor: Colors.green,
                      showFirebaseIcon: false,
                    ),
                  );
                },
              ),
            const SizedBox(height: 12),
          ],

          // Online transactions - green
          if (showOnline) ...[
            _buildHeader("Últimas Transações (Online)", Colors.green),
            if (onlineList.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: Text(
                  "Nenhuma transação online.",
                  style: TextStyle(color: Colors.green),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: onlineList.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final tx = onlineList[index];
                  return GestureDetector(
                    onTap: () {
                      controller.goToDetalhado(tx);
                    },
                    child: _buildOnlineRow(tx),
                  );
                },
              ),
            const SizedBox(height: 18),
          ],
        ],
      ),
    );
  }
}
