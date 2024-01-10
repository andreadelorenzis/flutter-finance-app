import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_finance_app/auth/auth.dart';
import 'package:flutter_finance_app/screens/login_screen.dart';
import 'package:flutter_finance_app/screens/main_scaffold_screen.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  final Auth auth = Auth();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: auth.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return MainScaffoldScreen(
              name: snapshot.data?.displayName,
              email: snapshot.data?.email,
              image: snapshot.data?.photoURL
          );
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}