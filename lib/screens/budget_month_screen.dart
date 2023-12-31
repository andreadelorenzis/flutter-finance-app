import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_finance_app/constants/colors.dart';
import 'package:flutter_finance_app/constants/data.dart';
import 'package:flutter_finance_app/screens/budget_screen.dart';
import 'package:flutter_finance_app/screens/main_scaffold_screen.dart';
import 'package:flutter_finance_app/screens/transaction_editor.dart';
import 'package:flutter_finance_app/widgets/transaction_item.dart';
import 'package:intl/intl.dart';

class BudgetMonthScreen extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final double initialBalance;

  BudgetMonthScreen({
    required this.startDate,
    required this.endDate,
    required this.initialBalance,
  });

  @override
  _BudgetMonthScreenState createState() => _BudgetMonthScreenState();
}

class _BudgetMonthScreenState extends State<BudgetMonthScreen> {
  PageController _pageController = PageController();
  late List<Map<String, double>> monthlyBalances;

  List<List<Map<String, dynamic>>> deposits = [];
  List<List<Map<String, dynamic>>> expenses = [];

  OverlayEntry? editingAppBarOverlay;
  Set<String> selectedTransactions = {};
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    // Inizializza i bilanci mensili
    int months = widget.endDate.month - widget.startDate.month +
        12 * (widget.endDate.year - widget.startDate.year) + 1;
    monthlyBalances = List.generate(months, (index) => {'balance': 0.0});
    monthlyBalances[0]['balance'] = widget.initialBalance; // Bilancio iniziale

    // Inizializza transazioni mensili
    deposits = List.generate(months, (index) => []);
    expenses = List.generate(months, (index) => []);
    for (int i = 0; i < Data.budgetTransactions.length; i++) {
      var monthTransactions = Data.budgetTransactions[i];
      for (var transaction in monthTransactions) {
        if (transaction['method'] == 'Deposit') {
          deposits[i].add(transaction);
        } else if (transaction['method'] == 'Payment') {
          expenses[i].add(transaction);
        }
      }
    }

    // Calcola il bilancio per i mesi successivi
    for (int i = 1; i < months; i++) {
      // Calcolo il bilancio del mese precedente
      double? monthInitialBalance = monthlyBalances[i-1]['balance'];
      double totalDeposits = getTotal(deposits[i-1]);
      double totalExpenses = getTotal(expenses[i-1]);
      double newBalance = monthInitialBalance! + (totalDeposits - totalExpenses);
      monthlyBalances[i]['balance'] = newBalance;
    }
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction, String dateKey, int pageIndex) {
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
        editingAppBarOverlay = OverlayEntry(
          builder: (context) =>
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AppBar(
                  title: const Text('Seleziona transazioni'),
                  actions: [
                    if (selectedTransactions.length == 1)
                      IconButton(icon: const Icon(Icons.edit), onPressed: () {
                        if (selectedTransactions.length == 1) {
                          final String transactionKey = selectedTransactions.first;
                          final Map<String, dynamic> transaction = _findTransactionByKey(
                              transactionKey, pageIndex);
                          _navigateToTransactionEditor(
                              isEditing: true, transaction: transaction);
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
                ),
              ),
        );

        Overlay.of(context)?.insert(editingAppBarOverlay!);
      },
      onCheckboxChange: (bool newValue, String transactionKey) {
        setState(() {
          if (newValue) {
            selectedTransactions.add(transactionKey);
          } else {
            selectedTransactions.remove(transactionKey);
          }
        });
      },
    );
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

  Map<String, dynamic> _findTransactionByKey(String key, int pageIndex) {
    List<Map<String, dynamic>> monthDeposits = deposits[pageIndex];
    List<Map<String, dynamic>> monthExpenses = expenses[pageIndex];

    // Cerco nei depositi del mese
    for (var deposit in monthDeposits) {
      String transactionKey = deposit['date'] + deposit['name'];
      if (transactionKey == key) {
        Map<String, dynamic> foundTransaction = Map.from(deposit);
        foundTransaction['date'] = DateTime.parse(foundTransaction['date']);
        return foundTransaction;
      }
    }

    // Cerco nelle spese del mese
    for (var expense in monthExpenses) {
      String transactionKey = expense['date'] + expense['name'];
      if (transactionKey == key) {
        Map<String, dynamic> foundTransaction = Map.from(expense);
        foundTransaction['date'] = DateTime.parse(foundTransaction['date']);
        return foundTransaction;
      }
    }

    return {};
  }

  void _navigateToTransactionEditor(
      {bool isEditing = false, Map<String, dynamic>? transaction}) {
    // Se siamo in modalità di modifica e abbiamo selezionato solo una transazione,
    // nascondiamo la barra di editing prima di navigare alla pagina di modifica
    if (isEditing && selectedTransactions.length == 1) {
      hideEditingAppBar();
    }

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) =>
          TransactionEditor(
            isEditing: isEditing,
            transaction: transaction,
          ),
    ));
  }

  double getTotal(List<Map<String, dynamic>> transactions) {
    return transactions.fold(0.0, (total, current) => total +
        double.parse(current['amount'].substring(1)));
  }

  double getBalanceDifference(List<Map<String, dynamic>> transactionsA, List<Map<String, dynamic>> transactionsB) {
    return getTotal(transactionsA) - getTotal(transactionsB);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial plan'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              Navigator.of(context)
                       ..pop(true)
                       ..pop(true);
            },
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: monthlyBalances.length,
        itemBuilder: (context, index) {
          DateTime monthDate = DateTime(widget.startDate.year, widget.startDate.month + index);
          String formattedDate = DateFormat('MMMM yyyy').format(monthDate);
          double balance = monthlyBalances[index]['balance'] ?? 0;
          List<Map<String, dynamic>> monthDeposits = deposits[index];
          List<Map<String, dynamic>> monthExpenses = expenses[index];

          
          return ListView(
            padding: const EdgeInsets.only(
                top: 20,
                left: 30,
                right: 30,
                bottom: 30
            ),
            shrinkWrap: true,
            children: [
              Center(
                child: Text(
                  formattedDate,
                  style: TextStyle(fontSize: 21, color: AppColors.pureBlack, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: 30,),
              Text(
                "BALANCE",
                style: TextStyle(fontSize: 21, color: AppColors.textColor2, fontWeight: FontWeight.w600),
              ),
              Padding(
                padding: EdgeInsets.only(top: 5, bottom: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${balance.toStringAsFixed(2)}€',
                      style: TextStyle(fontSize: 36, color: AppColors.pureBlack, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${getBalanceDifference(monthDeposits, monthExpenses) >= 0 ? '+' : '-'}'
                      '${getBalanceDifference(monthDeposits, monthExpenses).abs().toStringAsFixed(2)}€',
                      style: TextStyle(
                          fontSize: 25,
                          color: getBalanceDifference(monthDeposits, monthExpenses) >= 0
                              ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w700
                      ),
                    ),
                  ],
                )
              ),
              // Sezione Depositi
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Deposits", style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
                  ...monthDeposits.map<Widget>((transaction) =>
                      _buildTransactionItem(transaction, transaction['date'], index))
                      .toList(),
                  const SizedBox(height: 15),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                        'Total: €${getTotal(monthDeposits).toStringAsFixed(2)}'),
                  ),
                ],
              ),
              // Sezione Spese
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Expenses", style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
                  ...monthExpenses.map<Widget>((transaction) =>
                      _buildTransactionItem(transaction, transaction['date'], index))
                      .toList(),
                  const SizedBox(height: 15),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                        'Total: €${getTotal(monthExpenses).toStringAsFixed(2)}'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondaryColor,
        onPressed: () => _navigateToTransactionEditor(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}