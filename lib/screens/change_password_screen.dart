import 'package:flutter/material.dart';
import 'package:flutter_finance_app/constants/colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Change password"),
          actions: [
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                Navigator.of(context)
                    .pop(true);
              },
            ),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.only(
              top: 60,
              left: 30,
              right: 30,
              bottom: 30
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                    labelText: 'OLD PASSWORD',
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
                obscureText: true,
              ),
              SizedBox(height: 20,),
              TextField(
                decoration: InputDecoration(
                    labelText: 'NEW PASSWORD',
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
                obscureText: true,
              ),
            ],
          ),
        )
    );
  }
}
