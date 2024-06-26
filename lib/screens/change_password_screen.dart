import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_finance_app/auth/auth.dart';
import 'package:flutter_finance_app/constants/colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String ?email;

  const ChangePasswordScreen({
    required this.email,
    super.key
  });

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controllerEmail = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controllerEmail.text = widget.email!;
  }

  Future<void> resetPassword() async {
    try {
      Auth().resetPassword(email: _controllerEmail.text.trim());
      const snackBar = SnackBar(
          content: Text('Password reset email sent.')
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } on FirebaseAuthException catch (e) {
      var snackBar = SnackBar(content: Text(e.message ?? ""));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    resetPassword();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Change password"),
        ),
        body: Center(
          child: Container(
              padding: const EdgeInsets.only(
                  top: 80,
                  left: 30,
                  right: 30,
                  bottom: 30
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                                child: Icon(Icons.lock, color: AppColors.textColor)
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide.none
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 30.0)
                        ),
                        keyboardType: TextInputType.emailAddress
                    ),
                    const SizedBox(height: 20,),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16)
                        ),
                        onPressed: handleSubmit,
                        child: _loading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                            : const Text(
                          'REQUEST CODE',
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: AppColors.pureBlack,
                              fontSize: 16
                          ),
                        )
                    ),
                  ],
                ),
              )
          ),
        )
    );
  }
}
