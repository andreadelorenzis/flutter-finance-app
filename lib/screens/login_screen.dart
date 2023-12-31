import 'package:flutter/material.dart';
import 'package:flutter_finance_app/constants/colors.dart';
import 'package:flutter_finance_app/screens/main_scaffold_screen.dart';
import 'package:flutter_finance_app/screens/registration_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final screenSize = MediaQuery.of(context).size;
    final isWideScreen = screenSize.width > 600;

    return Scaffold(
      body: Center(
        child: isWideScreen
            ? Card(
                elevation: 10.0,
                color: Colors.white,
                child: Container(
                  width: 400,
                    child: Stack(
                      children: <Widget>[
                        // Immagine di sfondo
                        Positioned(
                            top: -50,
                            left: 0,
                            right: 0,
                            child: Image.asset(
                              "assets/images/vector1.png",
                              fit: BoxFit.contain,
                            )
                        ),
                        // Contenuti della schermata
                        Center(
                            child: Container(
                                width: 400,
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
                                              icon: Padding(
                                                padding: const EdgeInsets.only(right: 10),
                                                child: Image.asset('assets/images/google.png', height: 24.0),
                                              ),
                                              // Assicurati di avere questa immagine in assets
                                              label: const Text(
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
                                              onPressed: () {
                                                // Logica per il login con Google
                                              },
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
                                            TextField(
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
                                            TextField(
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
                                                  // Se l'autenticazione ha successo:
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => const MainScaffoldScreen(initialIndex: 0)),
                                                  );
                                                },
                                                child: const Text(
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
                                                    Navigator.pushNamed(context, 'register');
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
                                        )
                                    )
                                )
                            )
                        )
                      ],
                    ),
                )
            )
            : Stack(
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
                child: Container(
                    width: 400,
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
                                  icon: Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Image.asset('assets/images/google.png', height: 24.0),
                                  ),
                                  // Assicurati di avere questa immagine in assets
                                  label: const Text(
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
                                  onPressed: () {
                                    // Logica per il login con Google
                                  },
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
                                TextField(
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
                                TextField(
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
                                      // Se l'autenticazione ha successo:
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => const MainScaffoldScreen(initialIndex: 0,)),
                                      );
                                    },
                                    child: const Text(
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
                                        Navigator.pushNamed(context, '/register');
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