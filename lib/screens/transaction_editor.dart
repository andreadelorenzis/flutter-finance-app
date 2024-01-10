import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_finance_app/auth/auth.dart';
import 'package:flutter_finance_app/constants/colors.dart';
import 'package:flutter_finance_app/constants/data.dart';

class TransactionEditor extends StatefulWidget {
  final bool isEditing;
  final bool isBudget;
  final Function onSubmit;
  final Map<String, dynamic>? transaction;

  const TransactionEditor({
    super.key,
    this.isEditing = false,
    this.isBudget = false,
    this.transaction,
    required this.onSubmit,
  });

  @override
  State<TransactionEditor> createState() => _TransactionEditorState();
}

class _TransactionEditorState extends State<TransactionEditor> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late DateTime _selectedDate;
  late String _selectedType;
  bool _isFixed = false;
  String _transactionMethod = 'Payment';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.transaction?['name']);
    _amountController = TextEditingController(text: widget.transaction?['amount'].toString());
    if (!widget.isBudget) _selectedDate = widget.transaction?['date'] ?? DateTime.now();
    _selectedType = widget.transaction?['type'] ?? 'generic';
    _isFixed = widget.transaction?['isFixed'] ?? false;
    _transactionMethod = widget.transaction?['method'] ?? 'Payment';
  }

  void handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    User? user = Auth().getCurrentUser();

    Map<String, dynamic> transactionData = {
      'id': widget.transaction?['id'],
      'fixedId': widget.transaction?['fixedId'],
      'name': _nameController.text,
      'amount': double.parse(_amountController.text),
      'type': _selectedType,
      'method': _transactionMethod,
      'isFixed': _isFixed
    };
    if (!widget.isBudget) {
      transactionData['date'] = Timestamp.fromDate(_selectedDate);
    }

    widget.onSubmit(transactionData);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = _isFixed ? Colors.grey : Colors.black;
    IconData iconData = _isFixed ? Icons.lock : Icons.calendar_today;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Transaction' : 'Add Transaction'),
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: handleSubmit
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.only(
              top: 20,
              left: 30,
              right: 30,
              bottom: 30
          ),
          child: Column(
            children: [
              !widget.isBudget
                ? ListTile(
                  title: Text(
                    "${_selectedDate.toLocal()}".split(' ')[0],
                    style: TextStyle(color: textColor),
                  ),
                  onTap: !_isFixed ? () async {
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
                  } : null,
                  trailing: Icon(iconData, color: textColor),
                )
                : const SizedBox(),
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
                        const Text('Deposit')
                      ],
                    ),
                    Row(
                      children: [
                        Radio(
                          value: 'Payment',
                          groupValue: _transactionMethod,
                          onChanged: (String? value) {
                            setState(() {
                              _transactionMethod = value!;
                            });
                          },
                        ),
                        const Text("Withdrawal")
                      ],
                    )
                  ],
                ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Insert transaction name';
                  }
                  return null;
                },
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
              TextFormField(
                controller: _amountController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Insert transaction value';
                  }
                  return null;
                },
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
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
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
                            child: Text(capitalize(key), style: const TextStyle(color: AppColors.pureBlack)),
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
                title: const Text("Fixed"),
                  value: _isFixed,
                  onChanged: (bool? value) {
                  setState(() {
                    _isFixed = value!;
                    });
                  },
              )
            ],
          ),
        ),
      )
    );
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
