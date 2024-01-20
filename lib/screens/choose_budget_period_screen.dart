import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_finance_app/constants/colors.dart';
import 'package:flutter_finance_app/constants/months.dart';
import 'package:flutter_finance_app/utils/utils.dart';
import 'package:intl/intl.dart';
import 'budget_month_screen.dart';

class ChooseBudgetPeriodScreen extends StatefulWidget {
  final Function onDataUpdated;
  final bool isEditing;
  final DateTime startDate;
  final DateTime endDate;
  final double initialBalance;
  final ValueNotifier<List<List<Map<String, dynamic>>>> deposits;
  final ValueNotifier<List<List<Map<String, dynamic>>>> expenses;

  const ChooseBudgetPeriodScreen({
    super.key,
    required this.onDataUpdated,
    this.isEditing = false,
    required this.startDate,
    required this.endDate,
    required this.initialBalance,
    required this.deposits,
    required this.expenses
  });

  @override
  State<ChooseBudgetPeriodScreen> createState() => _ChooseBudgetPeriodScreenState();
}

class _ChooseBudgetPeriodScreenState extends State<ChooseBudgetPeriodScreen> {
  late ValueNotifier<DateTime> startDateNotifier;
  late ValueNotifier<DateTime> endDateNotifier;
  late ValueNotifier<double> initialBalanceNotifier;
  TextEditingController budgetController = TextEditingController();
  late final ValueNotifier<List<Map<String, dynamic>>> monthlyBalances;

  @override
  void initState() {
    super.initState();
    startDateNotifier = ValueNotifier(widget.startDate);
    endDateNotifier = ValueNotifier(widget.endDate);
    initialBalanceNotifier = ValueNotifier(widget.initialBalance);
    budgetController = TextEditingController(text: widget.initialBalance.toString());
    monthlyBalances = ValueNotifier([]);
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? startDateNotifier.value : endDateNotifier.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );
    if (picked != null && picked != (isStartDate ? startDateNotifier.value : endDateNotifier.value)) {
      setState(() {
        if (isStartDate) {
          startDateNotifier.value = picked;
        } else {
          endDateNotifier.value = picked;
        }
      });
    }
  }

  void _navigateToBudgetMonthScreen() async {
    if (widget.isEditing) {
      return;
    }

    double? initialBudget = double.tryParse(budgetController.text);
    if (initialBudget != null) {
      await _saveBudgetData(startDateNotifier.value, endDateNotifier.value, initialBudget);
    }

    if (!mounted) return;

    if (initialBudget != null) {
      initialBalanceNotifier.value = initialBudget;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BudgetMonthScreen(
            startDate: startDateNotifier,
            endDate: endDateNotifier,
            initialBalance: initialBalanceNotifier,
            deposits: widget.deposits,
            expenses: widget.expenses,
            monthlyBalances: monthlyBalances,
            onDataUpdated: widget.onDataUpdated,
          ),
        ),
      );
    }
  }

  int calculateMonthsBetween(DateTime startDate, DateTime endDate) {
    // Calcola la differenza in anni e mesi
    int yearDiff = endDate.year - startDate.year;
    int monthDiff = endDate.month - startDate.month + 1;

    // Calcola il numero totale di mesi
    return yearDiff * 12 + monthDiff;
  }

  Future<void> _saveBudgetData(DateTime startDate, DateTime endDate, double initialBudget) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    String userId = user.uid;
    DocumentReference budgetRef = FirebaseFirestore.instance.collection('users')
        .doc(userId).collection('budget')
        .doc('monthlyBudget');

    // Creazione di una mappa per ogni mese nel periodo
    Map<String, List<Map<String, dynamic>>> monthlyTransactions = {};
    DateTime currentMonth = DateTime(startDate.year, startDate.month);
    while (currentMonth.isBefore(endDate) || currentMonth.isAtSameMomentAs(endDate)) {
      String monthKey = '${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')}';
      monthlyTransactions[monthKey] = [];

      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
    }

    // Inizializzazione degli array per bilanci e profitti
    int months = calculateMonthsBetween(startDate, endDate);
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
      monthlyBalances.value[0]['balance'] = initialBudget;
    }

    // Inizializzazione delle transazioni fisse
    Map<String, List<dynamic>> fixedTransactions = {
      'deposits': [],
      'expenses': []
    };

    Map<String, dynamic> budgetData = {
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'initialBalance': initialBudget,
      'monthlyTransactions': monthlyTransactions,
      'fixedTransactions': fixedTransactions
    };

    await budgetRef.set(budgetData, SetOptions(merge: true));
  }

  void handleSubmit() {
    if (!widget.isEditing) {
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    double? initialBudget = double.tryParse(budgetController.text);
    if (initialBudget != null) {
      Map<String, dynamic> periodData = {
        'startDate': Timestamp.fromDate(startDateNotifier.value),
        'endDate': Timestamp.fromDate(endDateNotifier.value),
        'initialBalance': initialBudget
      };

      widget.onDataUpdated(periodData);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose budget period'),
        actions: widget.isEditing
          ? [
              IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: handleSubmit
              ),
            ]
          : []
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Form(child: Column(
              children: [
                ListTile(
                  title: Text('Start date: ${DateFormat('dd/MM/yyyy').format(startDateNotifier.value)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context, true),
                ),
                ListTile(
                  title: Text('End date: ${DateFormat('dd/MM/yyyy').format(endDateNotifier.value)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context, false),
                ),
                const SizedBox(height: 20,),
                TextFormField(
                  controller: budgetController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid initial balance';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      labelText: 'Initial balance',
                      fillColor: AppColors.backgroundColor,
                      filled: true,
                      prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          child: Icon(Icons.monetization_on, color: AppColors.textColor)
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 30.0)
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 20,),
                !widget.isEditing
                    ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40)
                      ),
                      onPressed: _navigateToBudgetMonthScreen,
                      child: const Text(
                        'Generate',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.pureBlack,
                            fontSize: 16
                        ),
                      ),
                      )
                    : const SizedBox()
              ],
            ))
          ],
        ),
      ),
    );
  }
}
