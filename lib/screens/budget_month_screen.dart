import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_finance_app/auth/auth.dart';
import 'package:flutter_finance_app/constants/colors.dart';
import 'package:flutter_finance_app/screens/choose_budget_period_screen.dart';
import 'package:flutter_finance_app/screens/transaction_editor.dart';
import 'package:flutter_finance_app/widgets/transaction_item.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class BudgetMonthScreen extends StatefulWidget {
  final ValueNotifier<DateTime> startDate;
  final ValueNotifier<DateTime> endDate;
  final ValueNotifier<double> initialBalance;
  final Function onDataUpdated;
  final ValueNotifier<List<Map<String, dynamic>>> monthlyBalances;
  final ValueNotifier<List<List<Map<String, dynamic>>>> deposits;
  final ValueNotifier<List<List<Map<String, dynamic>>>> expenses;

  const BudgetMonthScreen({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.initialBalance,
    required this.deposits,
    required this.expenses,
    required this.monthlyBalances,
    required this.onDataUpdated,
  });

  @override
  State<BudgetMonthScreen> createState() => _BudgetMonthScreenState();
}

class _BudgetMonthScreenState extends State<BudgetMonthScreen> {
  final PageController _pageController = PageController();
  late Future<void> budgetDataFuture;
  int _currentPageIndex = 0;

  OverlayEntry? editingAppBarOverlay;
  Set<String> selectedTransactions = {};
  bool isEditing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.page?.round() != _pageController.page) {
        setState(() {
          isEditing = false;
          selectedTransactions.clear();
        });
        hideEditingAppBar();
      }
      int nextPage = _pageController.page!.round();
      if (_currentPageIndex != nextPage) {
        setState(() {
          _currentPageIndex = nextPage;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(() {});
    hideEditingAppBar();
    super.dispose();
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction, int pageIndex) {
    final isSelected = selectedTransactions.contains(transaction['id']);

    return TransactionItem(
      transaction: transaction,
      isSelected: isSelected,
      isEditing: isEditing,
      onLongPress: () {
        setState(() {
          isEditing = true;
          selectedTransactions.add(transaction['id']);
        });
        editingAppBarOverlay = OverlayEntry(
          builder: (context) =>
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AppBar(
                  title: const Text('Select transactions'),
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
                      deleteTransactions();
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

        Overlay.of(context).insert(editingAppBarOverlay!);
      },
      onCheckboxChange: (bool newValue, String transactionId) {
        setState(() {
          if (newValue) {
            selectedTransactions.add(transactionId);
          } else {
            selectedTransactions.remove(transactionId);
          }
        });
      },
    );
  }


  void hideEditingAppBar() {
    editingAppBarOverlay?.remove();
    editingAppBarOverlay = null;
  }


  Map<String, dynamic> _findTransactionByKey(String key, int pageIndex) {
    List<Map<String, dynamic>> monthDeposits = widget.deposits.value[pageIndex];
    List<Map<String, dynamic>> monthExpenses = widget.expenses.value[pageIndex];

    // Cerco nei depositi del mese
    for (var deposit in monthDeposits) {
      String transactionKey = deposit['id'];
      if (transactionKey == key) {
        Map<String, dynamic> foundTransaction = Map.from(deposit);
        return foundTransaction;
      }
    }

    // Cerco nelle spese del mese
    for (var expense in monthExpenses) {
      String transactionKey = expense['id'];
      if (transactionKey == key) {
        Map<String, dynamic> foundTransaction = Map.from(expense);
        return foundTransaction;
      }
    }

    return {};
  }

  void _navigateToTransactionEditor({bool isEditing = false, Map<String, dynamic>? transaction}) {
    if (isEditing && selectedTransactions.length == 1) {
      hideEditingAppBar();
    }

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) =>
          TransactionEditor(
            isEditing: isEditing,
            isBudget: true,
            transaction: transaction,
            onSubmit: isEditing ? editBudgetTransaction : saveNewBudgetTransaction,
          ),
    ));
  }

  double getTotal(List<Map<String, dynamic>> transactions) {
    return transactions.fold(0.0, (total, current) {
      return total + (current['amount']);
    });
  }

  double getBalanceDifference(List<Map<String, dynamic>> transactionsA, List<Map<String, dynamic>> transactionsB) {
    return getTotal(transactionsA) - getTotal(transactionsB);
  }

  Future<void> saveNewBudgetTransaction(Map<String, dynamic> transactionData) async {
    String? userId = Auth().getCurrentUser()?.uid;
    DocumentReference budgetRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('budget')
        .doc('monthlyBudget');

    try {
      var uuid = const Uuid();

      if (!transactionData['isFixed']) {
        // Genera un id univoco per la transazione
        String transactionId = uuid.v4();
        transactionData['id'] = transactionId;

        // Calcola il mese e l'anno in base a startDate e pageIndex
        int pageIndex = _pageController.page!.round();
        DateTime monthDate = DateTime(widget.startDate.value.year, widget.startDate.value.month + pageIndex);
        String monthKey = '${monthDate.year}-${monthDate.month.toString().padLeft(2, '0')}';

        // Aggiorna Firestore
        await budgetRef.update({
          'monthlyTransactions.$monthKey': FieldValue.arrayUnion([transactionData])
        });

      } else {
        // Aggiunge la transazione a fixedTransactions
        String transactionId = uuid.v4();
        transactionData['id'] = transactionId;

        String transactionType = transactionData['method'] == 'Deposit'
            ? 'deposits' : 'expenses';

        await budgetRef.update({
          'fixedTransactions.$transactionType': FieldValue.arrayUnion([transactionData])
        });
      }
      setState(() {isLoading = true;});
      await widget.onDataUpdated();
      setState(() {isLoading = false;});
    } catch (e) {
      if (kDebugMode) {
        print("Error occurred while trying to add transaction: $e");
      }
    }
  }

  Future<void> editBudgetTransaction(Map<String, dynamic> transactionData) async {
    String? userId = Auth().getCurrentUser()?.uid;

    DocumentReference budgetRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('budget')
        .doc('monthlyBudget');

    try {
      // Calcola il mese e l'anno in base a startDate e pageIndex
      int pageIndex = _pageController.page!.round();
      DateTime monthDate = DateTime(widget.startDate.value.year, widget.startDate.value.month + pageIndex);
      String monthKey = '${monthDate.year}-${monthDate.month.toString().padLeft(2, '0')}';

      DocumentSnapshot snapshot = await budgetRef.get();
      if (snapshot.exists) {
        Map<String, dynamic> budgetData = snapshot.data() as Map<String, dynamic>;

        if (!transactionData['isFixed']) {
          List<dynamic> monthTransactions = budgetData['monthlyTransactions'][monthKey];

          // Trova e aggiorna la transazione specifica
          for (int i = 0; i < monthTransactions.length; i++) {
            if (monthTransactions[i]['id'] == transactionData['id']) {
              monthTransactions[i] = transactionData;
              break;
            }
          }

          // Aggiorna le transazioni del mese su Firestore
          await budgetRef.update({
            'monthlyTransactions.$monthKey': monthTransactions
          });
        } else {
          String transactionType = transactionData['method'] == 'Deposit' ? 'deposits' : 'expenses';
          List<dynamic> fixedTransactions = budgetData['fixedTransactions'][transactionType];

          // Aggiorna la transazione fissa
          for (int i = 0; i < fixedTransactions.length; i++) {
            if (fixedTransactions[i]['id'] == transactionData['fixedId']) {
              fixedTransactions[i] = transactionData;
              break;
            }
          }
          // Aggiorna Firestore
          await budgetRef.update({
            'fixedTransactions.$transactionType': fixedTransactions
          });
        }

        setState(() {isLoading = true;});
        await widget.onDataUpdated();
        setState(() {isLoading = false;});
      }
    } catch (e) {
      if (kDebugMode) {
        print("An error occurred trying to update the transaction: $e");
      }
    }
  }

  Future<void> deleteTransactions() async {
    String? userId = Auth().getCurrentUser()?.uid;
    int pageIndex = _pageController.page!.round();

    DocumentReference budgetRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('budget')
        .doc('monthlyBudget');

    bool hasFixedTransactions = false;
    for (String transactionId in selectedTransactions) {
      var transaction = _findTransactionByKey(transactionId, pageIndex);
      if (transaction['isFixed']) {
        hasFixedTransactions = true;
        break;
      }
    }

    if (hasFixedTransactions) {
      bool shoudlDelete = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Warning!'),
              content: const Text("Fixed transaction will be removed for all the months. Continue?"),
              actions: <Widget>[
                ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text("No")
                ),
                ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text("Yes")
                ),
              ],
            );
          }
      );

      if (!shoudlDelete) return;
    }

    try {
      DocumentSnapshot snapshot = await budgetRef.get();
      if (snapshot.exists) {
        Map<String, dynamic> budgetData = snapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> monthlyTransactions = budgetData['monthlyTransactions'];
        Map<String, dynamic> fixedTransactions = budgetData['fixedTransactions'];

        List<dynamic> fixedDepositsToRemove = [];
        List<dynamic> fixedExpensesToRemove = [];

        for (String transactionId in selectedTransactions) {
          var transaction = _findTransactionByKey(transactionId, pageIndex);
          bool isFixed = transaction['isFixed'];
          if(isFixed) {
            String fixedId = transaction['fixedId'];
            if (fixedTransactions['deposits'].any((t) => t['id'] == fixedId)) {
              fixedDepositsToRemove.add(fixedTransactions['deposits'].firstWhere((t) => t['id'] == fixedId));
            } else if (fixedTransactions['expenses'].any((t) => t['id'] == fixedId)) {
              fixedExpensesToRemove.add(fixedTransactions['expenses'].firstWhere((t) => t['id'] == fixedId));
            }
          } else {
            monthlyTransactions.forEach((monthKey, transactions) {
              monthlyTransactions[monthKey] = (transactions as List)
                  .where((transaction) => !selectedTransactions.contains(transaction['id']))
                  .toList();
            });
          }
        }
        fixedTransactions['deposits'].removeWhere((t) => fixedDepositsToRemove.contains(t));
        fixedTransactions['expenses'].removeWhere((t) => fixedExpensesToRemove.contains(t));

        // Aggiorna Firestore
        await budgetRef.update({
          'monthlyTransactions': monthlyTransactions,
          'fixedTransactions': fixedTransactions
        });

        // Aggiornamento locale e ricarica dei dati
        setState(() {isLoading = true;});
        await widget.onDataUpdated();
        setState(() {isLoading = false;});
        setState(() {
          isEditing = false;
          selectedTransactions.clear();
        });
        hideEditingAppBar();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error while trying to remove transactions: $e");
      }
    }
  }

  Future<void> changeBudgetPeriodFuture(Map<String, dynamic> periodData) async {
    String? userId = Auth().getCurrentUser()?.uid;

    DocumentReference budgetRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('budget')
        .doc('monthlyBudget');

    return FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(budgetRef);

      if (!snapshot.exists) {
        throw Exception("Firestore budget document not found");
      }

      // Ottieni i dati attuali del budget
      Map<String, dynamic> currentData = snapshot.data() as Map<String, dynamic>;
      Map<String, dynamic> originalMonthlyTransactions = Map.from(currentData['monthlyTransactions']);

      // Prepara i nuovi dati del budget
      transaction.update(budgetRef, {
        'startDate': periodData['startDate'],
        'endDate': periodData['endDate'],
        'initialBalance': periodData['initialBalance'],
      });

      // Ricostruisce la struttura dei mesi
      DateTime startDate = (periodData['startDate'] as Timestamp).toDate();
      DateTime endDate = (periodData['endDate'] as Timestamp).toDate();
      Map<String, dynamic> newMonthlyTransactions = {};

      for (DateTime date = startDate;
      date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
      date = DateTime(date.year, date.month + 1, 1)) {
        String monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
        newMonthlyTransactions[monthKey] = originalMonthlyTransactions.containsKey(monthKey)
            ? originalMonthlyTransactions[monthKey]
            : [];
      }

      // Aggiorna le transazioni mensili
      transaction.update(budgetRef, {
        'monthlyTransactions': newMonthlyTransactions
      });
    }).catchError((error) {
      if (kDebugMode) {
        print("Error while trying to update budget period: $error");
      }
    });
  }

  void handleBudgetPeriodChange(Map<String, dynamic> periodData) async {
    await changeBudgetPeriodFuture(periodData);
    widget.startDate.value = periodData['startDate'].toDate();
    widget.endDate.value = periodData['endDate'].toDate();
    widget.initialBalance.value = periodData['initialBalance'];
    setState(() {isLoading = true;});
    await widget.onDataUpdated();
    setState(() {isLoading = false;});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial plan'),
        actions: [
          IconButton(
          icon: const Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChooseBudgetPeriodScreen(
                  onDataUpdated: handleBudgetPeriodChange,
                  startDate: widget.startDate.value,
                  endDate: widget.endDate.value,
                  initialBalance: widget.initialBalance.value,
                  isEditing: true,
                  deposits: widget.deposits,
                  expenses: widget.expenses,
                ))
              );
            }
          ),
        ],
      ),
      body: !isLoading ? ValueListenableBuilder<DateTime>(
        valueListenable: widget.startDate,
        builder: (context, startDate, _) {
          return ValueListenableBuilder(
              valueListenable: widget.endDate,
              builder: (context, endDate, _) {
                return ValueListenableBuilder(
                    valueListenable: widget.initialBalance,
                    builder: (context, initialBalance, _) {
                      return ValueListenableBuilder<List<Map<String, dynamic>>>(
                        valueListenable: widget.monthlyBalances,
                        builder: (context, monthlyBalances, _) {
                          return PageView.builder(
                            controller: _pageController,
                            itemCount: monthlyBalances.length,
                            itemBuilder: (context, index) {
                              DateTime monthDate = DateTime(widget.startDate.value.year, widget.startDate.value.month + index);
                              String formattedDate = DateFormat('MMMM yyyy').format(monthDate);
                              double balance = monthlyBalances[index]['balance'] ?? 0;

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
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                            onPressed: () {
                                              if (_pageController.page! > 0) {
                                                _pageController.previousPage(
                                                  duration: const Duration(milliseconds: 300),
                                                  curve: Curves.easeInOut,
                                                );
                                              }
                                            },
                                            icon: Icon(
                                                Icons.arrow_left,
                                                color: _currentPageIndex > 0 ? Colors.black : Colors.grey[400],
                                                size: 30
                                            )
                                        ),
                                        Text(
                                          formattedDate,
                                          style: const TextStyle(fontSize: 21, color: AppColors.pureBlack, fontWeight: FontWeight.w600),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            if (_pageController.page! < monthlyBalances.length - 1) {
                                              _pageController.nextPage(
                                                duration: const Duration(milliseconds: 300),
                                                curve: Curves.easeInOut,
                                              );
                                            }
                                          },
                                            icon: Icon(
                                                Icons.arrow_right,
                                                color: _currentPageIndex < monthlyBalances.length - 1 ? Colors.black : Colors.grey[400],
                                                size: 30
                                            )
                                        ),
                                      ],
                                    )
                                  ),
                                  const SizedBox(height: 30,),
                                  const Text(
                                    "BALANCE",
                                    style: TextStyle(fontSize: 21, color: AppColors.textColor2, fontWeight: FontWeight.w600),
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.only(top: 5, bottom: 40),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${balance.toStringAsFixed(2)}€',
                                            style: const TextStyle(fontSize: 36, color: AppColors.pureBlack, fontWeight: FontWeight.w700),
                                          ),
                                          ValueListenableBuilder<List<List<Map<String, dynamic>>>>(
                                            valueListenable: widget.deposits,
                                            builder: (context, deposits, _) {
                                              return ValueListenableBuilder<List<List<Map<String, dynamic>>>>(
                                                valueListenable: widget.expenses,
                                                builder: (context, expenses, _) {
                                                  if (deposits.isEmpty || expenses.isEmpty) {
                                                    return const Text("0.0€", style: TextStyle(
                                                        fontSize: 25,
                                                        color: AppColors.black,
                                                        fontWeight: FontWeight.w700
                                                    ),);
                                                  }
                                                  
                                                  double difference = getBalanceDifference(deposits[index], expenses[index]);
                                                  return Text(
                                                    '${difference >= 0 ? '+' : '-'}${difference.abs().toStringAsFixed(2)}€',
                                                    style: TextStyle(
                                                        fontSize: 25,
                                                        color: difference >= 0 ? Colors.green : Colors.red,
                                                        fontWeight: FontWeight.w700
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ],
                                      )
                                  ),
                                  // Sezioni Depositi e Spese
                                  buildDepositsSection(index),
                                  buildExpensesSection(index),
                                ],
                              );
                            },
                          );
                        },
                      );
                    }
                );
              }
          );
        },
      ) : const Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondaryColor,
        onPressed: () => _navigateToTransactionEditor(),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget buildDepositsSection(int index) {
    return ValueListenableBuilder<List<List<Map<String, dynamic>>>>(
      valueListenable: widget.deposits,
      builder: (context, deposits, _) {
        if (deposits.isEmpty) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Deposits", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 15),
              Align(
                alignment: Alignment.bottomRight,
                child: Text('Total: €0'),
              ),
            ],
          );
        }

        List<Map<String, dynamic>> monthDeposits = deposits[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text("Deposits", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ...monthDeposits.map<Widget>((transaction) => _buildTransactionItem(transaction, index)),
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.bottomRight,
              child: Text('Total: €${getTotal(monthDeposits).toStringAsFixed(2)}'),
            ),
          ],
        );
      },
    );
  }

  Widget buildExpensesSection(int index) {
    return ValueListenableBuilder<List<List<Map<String, dynamic>>>>(
      valueListenable: widget.expenses,
      builder: (context, expenses, _) {
        if (expenses.isEmpty) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Expenses", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 15),
              Align(
                alignment: Alignment.bottomRight,
                child: Text('Total: €0'),
              ),
            ],
          );
        }

        List<Map<String, dynamic>> monthExpenses = expenses[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text("Expenses", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ...monthExpenses.map<Widget>((transaction) => _buildTransactionItem(transaction, index)),
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.bottomRight,
              child: Text('Total: €${getTotal(monthExpenses).toStringAsFixed(2)}'),
            ),
          ],
        );
      },
    );
  }

}