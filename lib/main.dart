import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_finance_app/constants/colors.dart';
import 'package:flutter_finance_app/firebase_options.dart';
import 'package:flutter_finance_app/screens/profile_screen.dart';
import 'package:flutter_finance_app/screens/budget_screen.dart';
import 'package:flutter_finance_app/screens/history_screen.dart';
import 'package:flutter_finance_app/screens/login_screen.dart';
import 'package:flutter_finance_app/screens/main_scaffold_screen.dart';
import 'package:flutter_finance_app/screens/registration_screen.dart';
import 'package:flutter_finance_app/screens/charts_screen.dart';
import 'package:flutter_finance_app/screens/widget_tree.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home: const WidgetTree(),
    );
  }
}
