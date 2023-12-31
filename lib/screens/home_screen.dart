import 'package:flutter/material.dart';
import 'package:flutter_finance_app/constants/colors.dart';
import 'package:flutter_finance_app/constants/data.dart';
import 'package:flutter_finance_app/screens/transaction_editor.dart';
import 'package:flutter_finance_app/widgets/savings_line_chart.dart';
import 'package:flutter_finance_app/widgets/transaction_item.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  OverlayEntry? editingAppBarOverlay;
  Set<String> selectedTransactions = {};
  bool isEditing = false;
  String selectedButton = '';

  void showEditingAppBar() {
    editingAppBarOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: _buildEditingAppBar(),
      ),
    );

    Overlay.of(context)?.insert(editingAppBarOverlay!);
  }

  void hideEditingAppBar() {
    editingAppBarOverlay?.remove();
    editingAppBarOverlay = null;
  }

  @override
  void dispose() {
    hideEditingAppBar(); // Assicurati di rimuovere l'OverlayEntry quando non è più necessario
    super.dispose();
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction, String dateKey) {
    final isSelected = selectedTransactions.contains(dateKey + transaction['name']);

    return TransactionItem(
      transaction: transaction,
      dateKey: dateKey,
      isSelected: isSelected,
      isEditing: isEditing,
      onLongPress: () {
        setState(() {
          isEditing = true;
          selectedTransactions.add(dateKey + transaction['name']);
        });
        showEditingAppBar();
      },
      onCheckboxChange: (bool newValue, String transactionKey) {
        setState(() {
          if(newValue) {
            selectedTransactions.add(transactionKey);
          } else {
            selectedTransactions.remove(transactionKey);
          }
        });
      },
    );
  }

  AppBar _buildNormalAppBar() {
    return AppBar(title: const Text('Home'));
  }

  Map<String, dynamic> _findTransactionByKey(String key) {
    for (var transaction in Data.transactions) {
      String transactionKey = transaction['date'] + transaction['name'];
      if (transactionKey == key) {
        Map<String, dynamic> foundTransaction = Map.from(transaction);
        foundTransaction['date'] = DateTime.parse(foundTransaction['date']);
        return foundTransaction;
      }
    }
    return {};
  }

  AppBar _buildEditingAppBar() {
    return AppBar(
      title: const Text('Seleziona transazioni'),
      actions: [
        if (selectedTransactions.length == 1)
          IconButton(icon: const Icon(Icons.edit), onPressed: () {
            if (selectedTransactions.length == 1) {
              final String transactionKey = selectedTransactions.first;
              final Map<String, dynamic> transaction = _findTransactionByKey(transactionKey);
              _navigateToTransactionEditor(isEditing: true, transaction: transaction);
              setState(() {
                isEditing = false;
                selectedTransactions.clear();
              });
            }
          }),
        IconButton(icon: const Icon(Icons.delete), onPressed: () {
          // Logica per eliminare le transazioni selezionate
        }),
        IconButton(icon: const Icon(Icons.close), onPressed: () {
          setState(() {
            isEditing = false;
            selectedTransactions.clear();
          });
          hideEditingAppBar();
        }),
      ],
    );
  }

  void _navigateToTransactionEditor({bool isEditing = false, Map<String, dynamic>? transaction}) {
    // Se siamo in modalità di modifica e abbiamo selezionato solo una transazione,
    // nascondiamo la barra di editing prima di navigare alla pagina di modifica
    if (isEditing && selectedTransactions.length == 1) {
      hideEditingAppBar();
    }

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => TransactionEditor(
        isEditing: isEditing,
        transaction: transaction,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {

    // Trasformazione dei dati in una mappa raggruppata per data
    Map<String, List<Map<String, dynamic>>> groupedTransactions = {};
    for(var transaction in Data.transactions) {
      final date = transaction['date'];
      if (!groupedTransactions.containsKey(date)) {
        groupedTransactions[date] = [];
      }
      groupedTransactions[date]!.add(transaction);
    }

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(
            top: 20,
            left: 30,
            right: 30,
            bottom: 30
        ),
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              'Balance',
              style: TextStyle(
                  fontSize: 21.0,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFA5A5A5)
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6.0),
            child: Text(
              '13,553.00 €', // Sostituisci con il valore dinamico del bilancio
              style: TextStyle(
                  fontSize: 36.0,
                  fontWeight:
                  FontWeight.w900
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 25.0, bottom: 14.0),
            child: Text(
              'Transactions History',
              style: TextStyle(fontSize: 21.0, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: groupedTransactions.entries.map<Widget>((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        entry.key, // Data delle transazioni
                        style: const TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textColor2
                        ),
                      ),
                    ),
                    ...entry.value.map((transaction) => _buildTransactionItem(transaction, transaction['date'])).toList(),
                    const SizedBox(height: 15)
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondaryColor,
        onPressed: () => _navigateToTransactionEditor(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

}


