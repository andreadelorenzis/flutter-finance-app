import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_finance_app/auth/auth.dart';
import 'package:flutter_finance_app/constants/colors.dart';
import 'package:flutter_finance_app/screens/login_screen.dart';
import 'package:flutter_finance_app/screens/main_scaffold_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  String? errorMessage = '';


  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> createUserWithEmailAndPassword() async {
    try {
      UserCredential userCredential = await Auth().createUserWithEmailAndPassword(
          email: _controllerEmail.text,
          password: _controllerPassword.text
      );
      User? user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(_controllerName.text);
        await user.reload();
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      UserCredential userCredential = await Auth().signInWithGoogle();
      User? user = userCredential.user;
      print(userCredential.user?.displayName);
      print(userCredential.user?.email);
      print(userCredential.user?.uid);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _errorMessage() {
    return Text(errorMessage == '' ? '' : 'Humm ? $errorMessage');
  }

  handleSubmitWithCredentials() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await createUserWithEmailAndPassword();
    setState(() => _loading = false);
  }

  handleSubmitWithGoogle() async {
    setState(() => _loading = true);
    await signInWithGoogle();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isWideScreen = screenSize.width > 600;

    return Scaffold(
        body: Center(
          child: Stack(
            children: <Widget>[
              // Immagine di sfondo
              !isWideScreen ? Positioned(
                  top: -20,
                  left: 0,
                  right: 0,
                  child: Image.asset(
                    "assets/images/vector1.png",
                    fit: BoxFit.contain,
                  )
              ) : SizedBox(),
              // Contenuti della schermata
              Center(
                  child: Container(
                      width: 400,
                      child: SingleChildScrollView(
                          child: Padding(
                              padding: EdgeInsets.only(
                                  top: !isWideScreen ? 130 : 0,
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
                                    const Text("Sign Up", textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 20),
                                    ElevatedButton.icon(
                                      icon: !_loading
                                          ? Padding(
                                        padding: const EdgeInsets.only(right: 10),
                                        child: Image.asset('assets/images/google.png', height: 24.0),
                                      )
                                          : SizedBox(),
                                      // Assicurati di avere questa immagine in assets
                                      label: _loading
                                          ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.black,
                                          strokeWidth: 2,
                                        ),
                                      )
                                          : const Text(
                                        'Sign up with Google',
                                        style: TextStyle(
                                            color: AppColors.pureBlack,
                                            fontSize: 17
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.backgroundColor,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10)
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 16)
                                      ),
                                      onPressed: handleSubmitWithGoogle,
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                        'OR',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textColor
                                        ),
                                        textAlign: TextAlign.center),
                                    const SizedBox(height: 20),
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
                                      keyboardType: TextInputType.emailAddress,
                                    ),
                                    const SizedBox(height: 20),
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
                                    const SizedBox(height: 20),
                                    TextFormField(
                                      controller: _controllerPassword,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your password';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'PASSWORD',
                                        fillColor: AppColors.backgroundColor,
                                        filled: true,
                                        prefixIcon: const Padding(
                                            padding: EdgeInsets.only(left: 20, right: 20),
                                            child: Icon(Icons.lock, color: AppColors.textColor)
                                        ),
                                        suffixIcon: Padding(
                                          padding: EdgeInsets.only(left: 20, right: 12),
                                          child: IconButton(
                                            icon: const Icon(Icons.visibility, color: AppColors.textColor),
                                            onPressed: () {
                                              // Logica per mostrare/nascondere la password
                                            },
                                          ),
                                        ),
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                            borderSide: BorderSide.none
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0), // Padding attorno al testo
                                      ),
                                      obscureText: true, // Nasconde la password
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
                                        onPressed: handleSubmitWithCredentials,
                                        /*
                                      onPressed: () {
                                        // Se l'autenticazione ha successo:
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => const MainScaffoldScreen(initialIndex: 0,)),
                                        );
                                      },
                                      */
                                        child: _loading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text(
                                              'SIGN UP',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  color: AppColors.pureBlack,
                                                  fontSize: 16
                                              ),
                                            )
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "Already have an account? ",
                                          style: TextStyle(
                                              fontSize: 17
                                          ),
                                        ),
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.all(0.0),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).push(MaterialPageRoute(
                                                builder: (context) => LoginScreen()
                                            ));
                                          },
                                          child: const Text(
                                            "Log in",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                color: AppColors.pureBlack,
                                                fontSize: 17
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              )
                          )
                      )
                  )
              )
            ],
          ),
        )
    );
  }
}
