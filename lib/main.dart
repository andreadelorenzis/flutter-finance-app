import 'package:flutter/material.dart';
import 'package:flutter_finance_app/constants/colors.dart';
import 'package:flutter_finance_app/screens/profile_screen.dart';
import 'package:flutter_finance_app/screens/budget_screen.dart';
import 'package:flutter_finance_app/screens/home_screen.dart';
import 'package:flutter_finance_app/screens/login_screen.dart';
import 'package:flutter_finance_app/screens/main_scaffold_screen.dart';
import 'package:flutter_finance_app/screens/registration_screen.dart';
import 'package:flutter_finance_app/screens/stocks_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login Screen',
      theme: ThemeData(
        textTheme: const TextTheme(
          titleMedium: TextStyle(color: Colors.red)
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: AppColors.textColor)
        )
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MainScaffoldScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
      },
    );
  }
}
