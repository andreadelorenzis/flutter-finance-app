import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_finance_app/auth/auth.dart';
import 'package:flutter_finance_app/constants/colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String? errorMessage = '';
  bool _loading = false;
  final emailController = TextEditingController();

  Widget _errorMessage() {
    return Text(errorMessage == '' ? '' : 'Humm ? $errorMessage');
  }

  Future<void> resetPassword() async {
    try {
      Auth().resetPassword(email: emailController.text.trim());
      const snackBar = SnackBar(
        content: Text('Password reset email sent.')
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
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
      appBar: AppBar(title: const Text('Reset Password'),),
      body: Center(
        child: Stack(
          children: <Widget>[
            // Immagine di sfondo
            Positioned(
                top: -20,
                left: 0,
                right: 0,
                child: Image.asset(
                  "assets/images/vector1.png",
                  fit: BoxFit.contain,
                )
            ),
            // Contenuti della schermata
            Center(
                child: SizedBox(
                    width: 400,
                    child: SingleChildScrollView(
                        child: Padding(
                            padding: const EdgeInsets.only(
                                top: 50,
                                left: 25,
                                right: 25,
                                bottom: 25
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  const SizedBox(height: 20),
                                  _errorMessage(),
                                  const Text("Receive an email to reset your password", textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: emailController,
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
                                  const SizedBox(height: 20),
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
                        )
                    )
                )
            )
          ],
        ),
      ),
    );
  }
}
