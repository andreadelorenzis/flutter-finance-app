import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_finance_app/auth/auth.dart';
import 'package:flutter_finance_app/screens/login_screen.dart';
import 'package:flutter_finance_app/screens/registration_screen.dart';
import 'package:flutter_finance_app/screens/main_scaffold_screen.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {

  Future<void> _checkAndCreateUser(User user) async {
    try {
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email,
          'balance': 0, // o altri dati iniziali
        });
      }
    } catch (e) {
      print("Errore nella creazione dell'utente in Firestore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // Esegui la logica di controllo e creazione dell'utente qui
          return FutureBuilder(
            future: _checkAndCreateUser(snapshot.data!),
            builder: (context, asyncSnapshot) {
              // Controlla lo stato del Future per gestire il caricamento o eventuali errori
              if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();  // O una schermata di caricamento
              }
              if (asyncSnapshot.hasError) {
                return Text('Si è verificato un errore');  // Gestisci gli errori
              }
              // Se il Future è completato, mostra la MainScaffoldScreen
              return MainScaffoldScreen(
                  name: snapshot.data?.displayName,
                  email: snapshot.data?.email,
                  image: snapshot.data?.photoURL
              );
            },
          );
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}