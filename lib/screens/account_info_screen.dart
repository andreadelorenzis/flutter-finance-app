import 'package:flutter/material.dart';
import 'package:flutter_finance_app/constants/colors.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit information"),
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
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: 20,),
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
          ],
        ),
      )
    );
  }
}
