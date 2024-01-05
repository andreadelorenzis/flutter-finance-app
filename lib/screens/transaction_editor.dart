import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_finance_app/constants/colors.dart';
import 'package:flutter_finance_app/constants/data.dart';

class TransactionEditor extends StatefulWidget {
  final bool isEditing;
  final bool isBudget;
  final Function onSubmit;
  final Map<String, dynamic>? transaction; // Null se è una nuova transazione

  const TransactionEditor({
    Key? key,
    this.isEditing = false,
    this.isBudget = false,
    this.transaction,
    required this.onSubmit,
  }) : super(key: key);

  @override
  _TransactionEditorState createState() => _TransactionEditorState();
}

class _TransactionEditorState extends State<TransactionEditor> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late DateTime _selectedDate;
  late String _selectedType;
  String _selectedIcon = 'default_icon';
  bool _isFixed = false;
  String _transactionMethod = 'Payment';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.transaction?['name']);
    _amountController = TextEditingController(text: widget.transaction?['amount'].toString());
    if (!widget.isBudget) _selectedDate = widget.transaction?['date'] ?? DateTime.now();
    _selectedType = widget.transaction?['type'] ?? 'generic';
    _selectedIcon = widget.transaction?['icon'] ?? 'default_icon';
    if (widget.isBudget) _isFixed = widget.transaction?['isFixed'] ?? false;
    _transactionMethod = widget.transaction?['method'] ?? 'Payment';
  }

  void handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    Map<String, dynamic> transactionData = {
      'id': widget.transaction?['id'],
      'fixedId': widget.transaction?['fixedId'],
      'name': _nameController.text,
      'amount': double.parse(_amountController.text),
      'type': _selectedType,
      'method': _transactionMethod,
    };
    if (widget.isBudget) {
      transactionData['isFixed'] = _isFixed;
    } else {
      transactionData['date'] = Timestamp.fromDate(_selectedDate);
    }

    widget.onSubmit(transactionData);
    Navigator.pop(context, true);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Transaction' : 'Add Transaction'),
        leading: BackButton(),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
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
                )
                : SizedBox(),
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
                          value: 'Payment',
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
              widget.isBudget
                ? CheckboxListTile(
                  title: Text("Fixed"),
                    value: _isFixed,
                    onChanged: (bool? value) {
                    setState(() {
                    _isFixed = value!;
                    });
                    },
                )
                : SizedBox()
            ],
          ),
        ),
      )
    );
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
