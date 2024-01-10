import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_finance_app/auth/AuthMethod.dart';
import 'package:flutter_finance_app/auth/auth.dart';
import 'package:flutter_finance_app/constants/colors.dart';
import 'package:flutter_finance_app/screens/account_info_screen.dart';
import 'package:flutter_finance_app/screens/change_password_screen.dart';
import 'package:flutter_finance_app/screens/widget_tree.dart';

class ProfileScreen extends StatefulWidget {
  final ValueNotifier<String?> name;
  final ValueNotifier<String?> email;
  final Function onUpdateName;
  final Function onUpdateEmail;

  const ProfileScreen({
    required this.name,
    required this.email,
    required this.onUpdateName,
    required this.onUpdateEmail,
    super.key
  });

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
          const SizedBox(width: 25,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.pureBlack),),
              text2 != null ? Text(text2, style: const TextStyle(fontSize: 13, color: AppColors.textColor2),) : const SizedBox()
            ],
          )
        ],
      ),
    );
}

  Future<void> signOut() async {
    await Auth().signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const WidgetTree()),
          (Route<dynamic> route) => false,
    );
  }

  Future<void> updateUsername(String newName) async {
    try {
      await Auth().updateDisplayName(newName);
      const snackBar = SnackBar(content: Text('Information updated.'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      widget.onUpdateName(newName);
    } catch (error) {
      final snackBar = SnackBar(content: Text('Failed to update username: $error'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> updateEmail(String newEmail) async {
    try {
      await Auth().updateEmail(newEmail);
      const snackBar = SnackBar(content: Text('Please, go and verify your new email.'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      widget.onUpdateEmail(newEmail);
    } catch (error) {
      final snackBar = SnackBar(content: Text('Failed to update email. Error: $error'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.name,
        builder: (context, name, _) {
          return ValueListenableBuilder(
              valueListenable: widget.email,
              builder: (context, email, _) {
                return Scaffold(
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
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  widget.name.value ?? '',
                                  style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w700, color: AppColors.pureBlack),
                                ),
                                Text(
                                  widget.email.value ?? '',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textColor2),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 30,),
                          menuButton(
                              text: 'Account information',
                              text2: 'Change your account information',
                              icon: Icons.person,
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => AccountInfoScreen(
                                      name: widget.name.value,
                                      email: widget.email.value,
                                      onSubmit: (Map<String, dynamic> data) async {
                                        User? user = Auth().getCurrentUser();
                                        if (data["name"] != user?.displayName) {
                                          await updateUsername(data["name"]);
                                        }
                                        AuthMethod authMethod = Auth().getAuthMethod();
                                        if (authMethod == AuthMethod.emailPassword) {
                                          if (data["email"] != user?.email) {
                                            await updateEmail(data["email"]);
                                          }
                                        }
                                      },
                                    )
                                ));
                              }
                          ),
                          const SizedBox(height: 10,),
                          menuButton(
                              text: 'Password',
                              text2: 'Change your password',
                              icon: Icons.lock,
                              onPressed: () {
                                AuthMethod authMethod = Auth().getAuthMethod();
                                if (authMethod == AuthMethod.google) {
                                  final snackBar = SnackBar(content: Text("Users signed in with Google can't change the password."));
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                } else {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => ChangePasswordScreen(email: widget.email.value)
                                  ));
                                }
                              }
                          ),
                          const SizedBox(height: 10,),
                          menuButton(
                              text: 'Logout',
                              text2: null,
                              icon: Icons.logout,
                              onPressed: () {
                                signOut();
                              }
                          )
                        ],
                      ),
                    )
                );
              }
          );
        }
    );
  }
}

