import 'package:flutter/material.dart';
import 'package:flutter_finance_app/constants/colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Immagine di sfondo
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/images/vector1.png",
              fit: BoxFit.contain,
            )
          ),
          // Contenuti della schermata
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 130,
                  left: 25,
                  right: 25,
                  bottom: 25
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 20),
                    const Text("Sign In", textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: Image.asset('assets/images/google.png', height: 24.0),
                      // Assicurati di avere questa immagine in assets
                      label: const Text('Sign in with Google'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.backgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16)
                      ),
                      onPressed: () {
                        // Logica per il login con Google
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text('OR', textAlign: TextAlign.center),
                    const TextField(
                      decoration: InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const TextField(
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          child: const Text('Forgot Password?'),
                          onPressed: () {
                            // Logica per la password dimenticata
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
                        onPressed: () {
                          // Logica per il login
                        },
                        child: const Text(
                            'SIGN IN',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        )
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? "),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(0.0),
                          ),
                          onPressed: () {
                            // Logica per la registrazione
                          },
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              fontWeight: FontWeight.w900
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                )
              )
            )
          )
        ],
      )
    );
  }
}