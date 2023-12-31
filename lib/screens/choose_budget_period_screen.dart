import 'package:flutter/material.dart';
import 'budget_month_screen.dart';

class ChooseBudgetPeriodScreen extends StatefulWidget {
  const ChooseBudgetPeriodScreen({super.key});

  @override
  _ChooseBudgetPeriodScreenState createState() => _ChooseBudgetPeriodScreenState();
}

class _ChooseBudgetPeriodScreenState extends State<ChooseBudgetPeriodScreen> {
  DateTime? startDate;
  DateTime? endDate;
  TextEditingController budgetController = TextEditingController();

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? startDate ?? DateTime.now() : endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != (isStartDate ? startDate : endDate)) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  void _navigateToBudgetMonthScreen() {
    double? initialBudget = double.tryParse(budgetController.text);
    if (startDate != null && endDate != null && initialBudget != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BudgetMonthScreen(
            startDate: startDate!,
            endDate: endDate!,
            initialBalance: initialBudget
          ),
        ),
      );
    } else {
      // Qui puoi mostrare un errore se le date o il bilancio non sono validi
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Scegli Periodo Budget'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ListTile(
              title: Text('Data Inizio: ${startDate?.toString() ?? 'Non selezionato'}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, true),
            ),
            ListTile(
              title: Text('Data Fine: ${endDate?.toString() ?? 'Non selezionato'}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, false),
            ),
            TextField(
              controller: budgetController,
              decoration: InputDecoration(labelText: 'Valore Bilancio Iniziale'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            ElevatedButton(
              onPressed: _navigateToBudgetMonthScreen,
              child: Text('Avanti'),
            ),
          ],
        ),
      ),
    );
  }
}
