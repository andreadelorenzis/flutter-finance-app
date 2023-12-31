import 'package:flutter/material.dart';
import 'package:flutter_finance_app/constants/colors.dart';
import 'package:flutter_finance_app/screens/account_info_screen.dart';
import 'package:flutter_finance_app/screens/change_password_screen.dart';
import 'package:flutter_finance_app/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  Widget menuButton({
    required String text,
    required String ?text2,
    required IconData icon,
    required VoidCallback onPressed
}) {
    return TextButton(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.primaryColor,
            size: 30
          ),
          SizedBox(width: 25,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.pureBlack),),
              text2 != null ? Text(text2!, style: TextStyle(fontSize: 13, color: AppColors.textColor2),) : SizedBox()
            ],
          )
        ],
      ),
    );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(
            top: 20,
            left: 30,
            right: 30,
            bottom: 30
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    'Tom Hillson',
                    style: TextStyle(fontSize: 27, fontWeight: FontWeight.w700, color: AppColors.pureBlack),
                  ),
                  Text(
                    'tomhill@gmail.com',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textColor2),
                  )
                ],
              ),
            ),
            SizedBox(height: 30,),
            menuButton(
              text: 'Account information',
              text2: 'Change your account information',
              icon: Icons.person,
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AccountInfoScreen()
                ));
              }
            ),
            SizedBox(height: 10,),
            menuButton(
                text: 'Password',
                text2: 'Change your password',
                icon: Icons.lock,
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ChangePasswordScreen()
                  ));
                }
            ),
            SizedBox(height: 10,),
            menuButton(
                text: 'Logout',
                text2: null,
                icon: Icons.logout,
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => LoginScreen()
                  ));
                }
            )
          ],
        ),
      )
    );
  }
}

