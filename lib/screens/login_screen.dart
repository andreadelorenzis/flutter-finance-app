import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_finance_app/auth/auth.dart';
import 'package:flutter_finance_app/constants/colors.dart';
import 'package:flutter_finance_app/screens/forgot_password_screen.dart';
import 'package:flutter_finance_app/screens/main_scaffold_screen.dart';
import 'package:flutter_finance_app/screens/registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      UserCredential userCredential = await Auth().signInWithEmailAndPassword(
          email: _controllerEmail.text,
          password: _controllerPassword.text
      );
      User? user = userCredential.user;
      if (user != null) {
        if (mounted) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => MainScaffoldScreen(
                name: user?.displayName, email: user.email, image: user.photoURL
            ),
          ));
        }
      }
    } on FirebaseAuthException catch (e) {
      var snackBar = SnackBar(content: Text(e.message ?? ""));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      UserCredential userCredential = await Auth().signInWithGoogle();
      if (kDebugMode) {
        print(userCredential.user?.displayName);
        print(userCredential.user?.email);
        print(userCredential.user?.uid);
      }

      User? user = userCredential.user;
      if (user != null) {
        await _checkAndCreateUser(user);
      }
    } on FirebaseAuthException catch (e) {
      var snackBar = SnackBar(content: Text(e.message ?? ""));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  Future<void> _checkAndCreateUser(User user) async {
    try {
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email,
          'balance': 0,
        });
      }
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => MainScaffoldScreen(
              name: user?.displayName, email: user.email, image: user.photoURL
          ),
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error while trying to create user in Firestore: $e");
      }
    }
  }

  handleSubmitWithCredentials() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await signInWithEmailAndPassword();
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
              ) : const SizedBox(),
              // Contenuti della schermata
              Center(
                  child: SizedBox(
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
                                    const Text("Sign In", textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 20),
                                    ElevatedButton.icon(
                                      icon: !_loading
                                        ? Padding(
                                          padding: const EdgeInsets.only(right: 10),
                                          child: Image.asset('assets/images/google.png', height: 24.0),
                                        )
                                        : const SizedBox(),
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
                                          'Sign in with Google',
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
                                          padding: const EdgeInsets.only(left: 20, right: 12),
                                          child: IconButton(
                                            icon: Icon(
                                                _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                                color: AppColors.textColor),
                                            onPressed: () {
                                              setState(() {
                                                _passwordVisible = !_passwordVisible;
                                              });
                                            },
                                          ),
                                        ),
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                            borderSide: BorderSide.none
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0), // Padding attorno al testo
                                      ),
                                      obscureText: !_passwordVisible, // Nasconde la password
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          child: const Text(
                                            'Forgot Password?',
                                            style: TextStyle(
                                                color: AppColors.pureBlack,
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).push(MaterialPageRoute(
                                              builder: (context) => const ForgotPasswordScreen(),
                                            ));
                                          },
                                        ),
                                      ],
                                    ),
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.secondaryColor,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10)
                                            ),
                                            padding: const EdgeInsets.symmetric(vertical: 16)
                                        ),
                                        onPressed: handleSubmitWithCredentials,
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
                                              'SIGN IN',
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
                                          "Don't have an account? ",
                                          style: TextStyle(
                                              fontSize: 17
                                          ),
                                        ),
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.all(0.0),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pushReplacement(MaterialPageRoute(
                                              builder: (context) => const RegistrationScreen(),
                                            ));
                                          },
                                          child: const Text(
                                            "Sign Up",
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
