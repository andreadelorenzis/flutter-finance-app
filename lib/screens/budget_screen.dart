import 'package:flutter/material.dart';
import 'package:flutter_finance_app/constants/data.dart';
import 'package:flutter_finance_app/constants/months.dart';
import 'package:flutter_finance_app/widgets/savings_line_chart.dart';
import 'package:intl/intl.dart';
import 'choose_budget_period_screen.dart';


class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}


class _BudgetScreenState  extends State<BudgetScreen> with WidgetsBindingObserver {
  // bool isPlanCreated = true;
  bool isPlanCreated = true;
  late DateTime startDate;
  late DateTime endDate;
  late double initialBalance;
  late List<Map<String, dynamic>> monthlyBalances;
  late List<Map<String, double>> monthlyEarnings;
  List<List<Map<String, dynamic>>> deposits = [];
  List<List<Map<String, dynamic>>> expenses = [];

  @override
  void initState() {
    updatePlanCreated();
  }

  void updatePlanCreated() {
    startDate = DateTime.parse(Data.budgetInfo['startDate']);
    endDate = DateTime.parse(Data.budgetInfo['endDate']);
    initialBalance = Data.budgetInfo['initialBalance'];

    var startMonth = startDate.month;
    var endMonth = endDate.month;
    List<String> monthsBetween = [];
    DateTime currentDate = startDate;
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      monthsBetween.add("${Months.get(currentDate.month-1)} ${currentDate.year}");
      currentDate = DateTime(currentDate.year, currentDate.month + 1, 1);
    }

    int months = endDate.month - startDate.month +
        12 * (endDate.year - startDate.year) + 1;

    monthlyBalances = List.generate(months, (index) => {
      'month': Months.get(index),
      'balance': 0.0
    });
    monthlyBalances[0]['balance'] = this.initialBalance;

    monthlyEarnings = monthsBetween
        .map((month) => {month: 0.0})
        .toList();

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

    // Calcola i fatturati mensili
    for (int i = 0; i < monthsBetween.length; i++) {
      double depositsTotal = getTotal(deposits[i]);
      double expensesTotal = getTotal(expenses[i]);
      monthlyEarnings[i][monthsBetween[i]] = depositsTotal - expensesTotal;
    }

    setState(() {
      isPlanCreated = true;
    });
  }

  double getTotal(List<Map<String, dynamic>> transactions) {
    return transactions.fold(0.0, (total, current) => total +
        double.parse(current['amount'].substring(1)));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isPlanCreated ? _buildPlanCreatedView() : _buildPlanCreationView(),
      floatingActionButton: isPlanCreated ? FloatingActionButton(
        onPressed: () {
          // Aggiungi qui la logica per "Modifica"
        },
        child: Icon(Icons.edit),
      ) : null,
    );
  }

  Widget _buildPlanCreationView() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChooseBudgetPeriodScreen()),
          ).then((value) {
            if(value != null && value) {
              updatePlanCreated();
            }
          });
        },
        child: Text('Crea Piano'),
      ),
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
            Text("Financial Plan", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBalanceInfo(
                  "Inizio",
                  monthlyBalances[0]['balance']!,
                  startDate,
                ),
                Icon(Icons.arrow_forward, size: 30),
                _buildBalanceInfo(
                    "Fine",
                    monthlyBalances[monthlyBalances.length - 1]['balance']!,
                    endDate,
                    compare: compareBalances(monthlyBalances[monthlyBalances.length - 1]['balance']!, monthlyBalances[0]['balance']!)
                ),
              ],
            ),
            SizedBox(height: 30),
            Container(
              height: 200,
              color: Colors.grey[300],
              child: Center(child: SavingsChart(monthlyBalances: monthlyBalances,)),
            ),
            SizedBox(height: 30),
            Text("Risultati Mensili", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            // Placeholder per i risultati mensili
            ...monthlyEarnings.map((earnings) {
              return ListTile(
                title: Text(earnings.keys.first),
                trailing: Text(
                    "${earnings[earnings.keys.first]! >= 0 ? "+" : "-"}"
                    "${earnings[earnings.keys.first]}€",
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
