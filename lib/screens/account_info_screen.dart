import 'package:flutter/material.dart';
import 'package:flutter_finance_app/auth/AuthMethod.dart';
import 'package:flutter_finance_app/auth/auth.dart';
import 'package:flutter_finance_app/constants/colors.dart';

class AccountInfoScreen extends StatefulWidget {
  final String ?name;
  final String ?email;
  final Function onSubmit;

  const AccountInfoScreen({
    required this.name,
    required this.email,
    required this.onSubmit,
    super.key
  });

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  String? errorMessage = '';
  bool _showEmailField = true;
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controllerName.text = widget.name!;
    _controllerEmail.text = widget.email!;

    // Determina se mostrare il campo email
    AuthMethod authMethod = Auth().getAuthMethod();
    if (authMethod != AuthMethod.emailPassword) {
      setState(() {
        _showEmailField = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit information"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Map<String, dynamic> data = {
                "name": _controllerName.text,
                "email": _controllerEmail.text
              };
              widget.onSubmit(data);
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.only(
            top: 60,
            left: 30,
            right: 30,
            bottom: 30
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _controllerName,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                decoration: InputDecoration(
                    labelText: 'FULL NAME',
                    fillColor: AppColors.backgroundColor,
                    filled: true,
                    prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: Icon(Icons.person, color: AppColors.textColor)
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 30.0)
                ),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20,),
              if (_showEmailField)
                TextFormField(
                  controller: _controllerEmail,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      labelText: 'EMAIL',
                      fillColor: AppColors.backgroundColor,
                      filled: true,
                      prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          child: Icon(Icons.email, color: AppColors.textColor)
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 30.0)
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
            ],
          ),
        )
      )
    );
  }
}
