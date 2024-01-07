import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_finance_app/constants/colors.dart';
import 'package:flutter_finance_app/constants/data.dart';
import 'package:flutter_finance_app/constants/months.dart';
import 'package:flutter_finance_app/screens/budget_month_screen.dart';
import 'package:flutter_finance_app/widgets/savings_line_chart.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'choose_budget_period_screen.dart';


class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}


class _BudgetScreenState  extends State<BudgetScreen> with WidgetsBindingObserver {
  bool isPlanCreated = false;
  late ValueNotifier<DateTime> startDate;
  late ValueNotifier<DateTime> endDate;
  late ValueNotifier<double> initialBalance;
  late List<Map<String, double>> monthlyEarnings;
  late ValueNotifier<List<Map<String, dynamic>>> monthlyBalances;
  late ValueNotifier<List<List<Map<String, dynamic>>>> deposits;
  late ValueNotifier<List<List<Map<String, dynamic>>>> expenses;
  // late ValueNotifier<Map<String, List<dynamic>>> fixedTransactions;
  late Future<void> budgetDataFuture;

  @override
  void initState() {
    super.initState();
    deposits = ValueNotifier([]);
    expenses = ValueNotifier([]);
    monthlyBalances = ValueNotifier([]);
    startDate = ValueNotifier(DateTime.now());
    endDate = ValueNotifier(DateTime.now());
    initialBalance = ValueNotifier(0);
    /*
     fixedTransactions = ValueNotifier({
      'deposits': [],
      'expenses': []
    });
    * */
    budgetDataFuture = fetchBudgetData();
  }

  Future<void> fetchBudgetData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("Utente non autenticato");
      return;
    }

    String userId = user.uid;
    DocumentReference budgetRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('budget')
        .doc('monthlyBudget');

    try {
      DocumentSnapshot budgetSnapshot = await budgetRef.get();
      if (budgetSnapshot.exists) {
        updatePlan(budgetSnapshot.data());
        setState(() {
          isPlanCreated = true;
        });
      } else {
        setState(() {
          isPlanCreated = false;
        });
      }
      print(isPlanCreated);
    } catch (e) {
      print("Errore durante il recupero del piano di budget: $e");
      setState(() {
        isPlanCreated = false;
      });
    }
  }

  int calculateMonthsBetween(DateTime startDate, DateTime endDate) {
    // Calcola la differenza in anni e mesi
    int yearDiff = endDate.year - startDate.year;
    int monthDiff = endDate.month - startDate.month + 1;

    // Calcola il numero totale di mesi
    return yearDiff * 12 + monthDiff;
  }


  void updatePlan(var budgetData) {
    if (budgetData == null) {
      return;
    }

    startDate.value = (budgetData['startDate'] as Timestamp).toDate();
    endDate.value = (budgetData['endDate'] as Timestamp).toDate();
    initialBalance.value = budgetData['initialBalance'];
    Map<String, dynamic> monthlyTransactions = budgetData['monthlyTransactions'];
    Map<String, dynamic> fixedTransactions = budgetData['fixedTransactions'];

    int months = calculateMonthsBetween(startDate.value, endDate.value);
    print(months);

    deposits.value = List.generate(months, (_) => []);
    expenses.value = List.generate(months, (_) => []);

    // Inizializzazione degli array per bilanci e profitti
    DateTime currentMonth = startDate.value;
    monthlyBalances.value = List.generate(months, (_) {
      var balanceMap = {
        'month': '${Months.getFull(currentMonth.month - 1)} ${currentMonth.year}',
        'balance': 0.0
      };
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
      return balanceMap;
    });

    // Imposta l'initialBalance per il primo mese
    if (monthlyBalances.value.isNotEmpty) {
      monthlyBalances.value[0]['balance'] = initialBalance.value;
    }

    List<String> monthsBetween = [];
    DateTime currentDate = startDate.value;


    while (currentDate.year < endDate.value.year ||
        (currentDate.year == endDate.value.year && currentDate.month <= endDate.value.month)) {
      print("${currentDate.month} - ${currentDate.year}");
      monthsBetween.add("${Months.getFull(currentDate.month - 1)} ${currentDate.year}");
      currentDate = (currentDate.month < 12)
          ? DateTime(currentDate.year, currentDate.month + 1, currentDate.day)
          : DateTime(currentDate.year + 1, 1, currentDate.day); // Incrementa l'anno se il mese è dicembre
    }
    monthlyEarnings = monthsBetween.map((month) => {month: 0.0}).toList();


    print(monthsBetween.length);

    // Aggiorna le transazioni mensili
    int i = 0;
    var uuid = Uuid();
    currentDate = startDate.value;
    while (currentDate.isBefore(endDate.value) || currentDate.isAtSameMomentAs(endDate.value)) {
      String monthKey = '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}';

      List<dynamic>? transactions = monthlyTransactions[monthKey];
      if (transactions != null) {
        for (var transaction in transactions) {
          if (transaction['method'] == 'Deposit') {
            deposits.value[i].add(transaction);
          } else if (transaction['method'] == 'Payment') {
            expenses.value[i].add(transaction);
          }
        }
      }

      // Processo simile per le transazioni fisse
      for (var transaction in fixedTransactions['deposits']!) {
        Map<String, dynamic> newTransaction = Map.from(transaction);
        newTransaction['fixedId'] = transaction['id'];
        newTransaction['id'] = uuid.v4();
        deposits.value[i].add(newTransaction);
      }
      for (var transaction in fixedTransactions['expenses']!) {
        Map<String, dynamic> newTransaction = Map.from(transaction);
        newTransaction['fixedId'] = transaction['id'];
        newTransaction['id'] = uuid.v4();
        expenses.value[i].add(newTransaction);
      }

      i++;
      currentDate = DateTime(currentDate.year, currentDate.month + 1, 1);
    }

    // Calcola il bilancio per i mesi successivi al primo
    for (int i = 0; i < months; i++) {
      double totalDeposits = getTotal(deposits.value[i]);
      double totalExpenses = getTotal(expenses.value[i]);
      double? monthInitialBalance = monthlyBalances.value[i]['balance'];
      double newBalance = monthInitialBalance! + (totalDeposits - totalExpenses);
      monthlyBalances.value[i]['balance'] = newBalance;
    }

    // Calcola i fatturati mensili
    for (int i = 0; i < monthsBetween.length; i++) {
      double depositsTotal = getTotal(deposits.value[i]);
      double expensesTotal = getTotal(expenses.value[i]);
      monthlyEarnings[i][monthsBetween[i]] = depositsTotal - expensesTotal;
    }

    setState(() {
      isPlanCreated = true;
    });

    print("Stato BudgetScreen aggiornato!");
  }

  double getTotal(List<Map<String, dynamic>> transactions) {
    return transactions.fold(0.0, (total, current) => total + current['amount']);
  }

  Widget _buildBalanceInfo(String title, double balance, DateTime date, {int compare = 0}) {
    Color color = Colors.black;

    if (compare > 0) {
      color = Colors.green;
    } else if (compare < 0) {
      color = Colors.red;
    }

    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Text("€${balance?.toStringAsFixed(2)}",
            style: TextStyle(
                fontSize: 22,
                fontWeight:
                FontWeight.w500,
                color: color
            )),
        SizedBox(height: 5),
        Text("${date.day}/${date.month}/${date.year}", style: TextStyle(fontSize: 16, color: Colors.grey)),
      ],
    );
  }

  void addMockBudgetData() async {
    // Prendi l'ID utente
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("Utente non autenticato");
      return;
    }
    String userId = user.uid;

    // Preparazione dei dati di budget
    List<Map<String, dynamic>> octoberBudgetTransactions = Data.octoberBudgetTransactions; // Dati di ottobre
    List<Map<String, dynamic>> novemberBudgetTransactions = Data.novemberBudgetTransactions; // Dati di novembre
    List<Map<String, dynamic>> decemberBudgetTransactions = Data.decemberBudgetTransactions; // Dati di dicembre

    var uuid = Uuid();
    void addUuid(List<Map<String, dynamic>> transactions) {
      for (var transaction in transactions) {
        transaction['id'] = uuid.v4(); // Aggiunge un UUID univoco
      }
    }
    addUuid(octoberBudgetTransactions);
    addUuid(novemberBudgetTransactions);
    addUuid(decemberBudgetTransactions);

    // Aggiungi i dati al Firestore
    DocumentReference budgetRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('budget')
        .doc('monthlyBudget');

    await budgetRef.set({
      'monthlyTransactions': {
        '2023-10': octoberBudgetTransactions,
        '2023-11': novemberBudgetTransactions,
        '2023-12': decemberBudgetTransactions,
      },
    }, SetOptions(merge: true));

    print("Dati di budget di esempio aggiunti");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Center(child: Text('Budgeting', style: TextStyle(
              color: AppColors.pureBlack, fontWeight: FontWeight.w800, fontSize: 25
          ),),)
      ),
      body: FutureBuilder<void>(
        future: budgetDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'),);
          } else {
            return isPlanCreated ? _buildPlanCreatedView() : _buildPlanCreationView();
          }
        },
      ),
      floatingActionButton: isPlanCreated ? FloatingActionButton(
        backgroundColor: AppColors.secondaryColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BudgetMonthScreen(
                startDate: startDate,
                endDate: endDate,
                initialBalance: initialBalance,
                deposits: deposits,
                expenses: expenses,
                monthlyBalances: monthlyBalances,
                onDataUpdated: fetchBudgetData,
              )
            ),
          ).then((value) {
            fetchBudgetData();
          });
        },
        child: Icon(Icons.edit),
      ) : null,
    );
  }

  Widget _buildPlanCreationView() {
    DateTime now = DateTime.now();
    DateTime twelveMonthsLater = DateTime(now.year, now.month + 12, now.day);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("No budget available", style: TextStyle(fontSize: 18),),
          SizedBox(height: 20,),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                ),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 15)
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChooseBudgetPeriodScreen(
                  onDataUpdated: fetchBudgetData,
                  startDate: now,
                  endDate: twelveMonthsLater,
                  initialBalance: 0,
                )),
              ).then((value) {
                fetchBudgetData();
              });
            },
            child: Text(
              'Crea Piano',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColors.pureBlack,
                  fontSize: 16
              ),
            ),
          ),
        ],
      )
    );
  }

  int compareBalances(double balanceA, balanceB) {
    if (balanceA > balanceB) {
      return 1;
    } else if (balanceA < balanceB) {
      return -1;
    } else {
      return 0;
    }
  }

  Widget _buildPlanCreatedView() {
    final screenSize = MediaQuery.of(context).size;
    final isWideScreen = screenSize.width > 600;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(
            top: 20,
            left: 30,
            right: 30,
            bottom: 30
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBalanceInfo(
                  "Inizio",
                  monthlyBalances.value[0]['balance']!,
                  startDate.value,
                ),
                Icon(Icons.arrow_forward, size: isWideScreen ? 50 : 30),
                _buildBalanceInfo(
                    "Fine",
                    monthlyBalances.value[monthlyBalances.value.length - 1]['balance']!,
                    endDate.value,
                    compare: compareBalances(monthlyBalances.value[monthlyBalances.value.length - 1]['balance']!, monthlyBalances.value[0]['balance']!)
                ),
              ],
            ),
            SizedBox(height: 30),
            Container(
              height: 200,
              color: Colors.white,
              child: Center(child: SavingsChart(monthlyBalances: monthlyBalances.value,)),
            ),
            SizedBox(height: 30),
            Text("Risultati Mensili", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            // Placeholder per i risultati mensili
            ...monthlyEarnings.map((earnings) {
              return ListTile(
                title: Text(earnings.keys.first),
                trailing: Text(
                    "${earnings[earnings.keys.first]! >= 0 ? "+" : ""}"
                    "${earnings[earnings.keys.first]} €",
                    style: TextStyle(
                        fontSize: 16,
                        color: earnings[earnings.keys.first]! >= 0
                        ? Colors.green
                        : Colors.red)
                    ),
              );
            }),
          ],
        ),
      )
    );
  }

}
