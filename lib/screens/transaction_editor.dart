import 'package:flutter/material.dart';
import 'package:flutter_finance_app/constants/colors.dart';
import 'package:flutter_finance_app/constants/data.dart';

class TransactionEditor extends StatefulWidget {
  final bool isEditing;
  final Map<String, dynamic>? transaction; // Null se è una nuova transazione

  const TransactionEditor({
    Key? key,
    this.isEditing = false,
    this.transaction,
  }) : super(key: key);

  @override
  _TransactionEditorState createState() => _TransactionEditorState();
}

class _TransactionEditorState extends State<TransactionEditor> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late DateTime _selectedDate;
  late String _selectedType;
  String _selectedIcon = 'default_icon';
  bool _isFixed = false;
  String _transactionMethod = 'Expense';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.transaction?['name']);
    _amountController = TextEditingController(text: widget.transaction?['amount'].toString());
    _selectedDate = widget.transaction?['date'] ?? DateTime.now();
    _selectedType = widget.transaction?['type'] ?? 'subscription';
    _selectedIcon = widget.transaction?['icon'] ?? 'default_icon';
    _isFixed = widget.transaction?['isFixed'] ?? false;
    _transactionMethod = widget.transaction?['method'] ?? 'Expense';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Transaction' : 'Add Transaction'),
        leading: BackButton(),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              // Salva la transazione
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 20,
          left: 30,
          right: 30,
          bottom: 30
        ),
        child: Column(
          children: [
            ListTile(
              title: Text("${_selectedDate.toLocal()}".split(' ')[0]),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2025),
                );
                if (picked != null && picked != _selectedDate) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
              trailing: const Icon(Icons.calendar_today),
            ),
            if(!widget.isEditing)
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio(
                        value: 'Deposit',
                        groupValue: _transactionMethod,
                        onChanged: (String? value) {
                          setState(() {
                            _transactionMethod = value!;
                          });
                        },
                      ),
                      Text('Deposit')
                    ],
                  ),
                  Row(
                    children: [
                      Radio(
                        value: 'Expense',
                        groupValue: _transactionMethod,
                        onChanged: (String? value) {
                          setState(() {
                            _transactionMethod = value!;
                          });
                        },
                      ),
                      Text("Withdrawal")
                    ],
                  )
                ],
              ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name of Transaction',
                fillColor: AppColors.backgroundColor,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount (€)',
                fillColor: AppColors.backgroundColor,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    flex: 2,
                    child: Padding(
                        padding: EdgeInsets.only(top: 15, right: 20),
                        child: Text("Transaction Type:", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: DropdownButton<String>(
                      value: _selectedType,
                      items: Data.transactionTypes.keys.map((String key) {
                        return DropdownMenuItem<String>(
                          value: key,
                          child: Text(capitalize(key), style: TextStyle(color: AppColors.pureBlack)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedType = newValue!;
                        });
                      },
                    ),
                  )
                ],
              ),
            ),
            CheckboxListTile(
              title: Text("Fixed"),
              value: _isFixed,
              onChanged: (bool? value) {
                setState(() {
                  _isFixed = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
