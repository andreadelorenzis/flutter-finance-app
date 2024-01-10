import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_finance_app/constants/colors.dart';
import 'package:flutter_finance_app/screens/profile_screen.dart';
import 'package:flutter_finance_app/screens/charts_screen.dart';
import 'package:flutter_finance_app/screens/budget_screen.dart';
import 'package:flutter_finance_app/screens/history_screen.dart';
import 'package:flutter_finance_app/screens/widget_tree.dart';

import '../auth/auth.dart';

class MainScaffoldScreen extends StatefulWidget {
  final int initialIndex;
  final String ?name;
  final String ?email;
  final String ?image;

  const MainScaffoldScreen({
    super.key,
    required this.name,
    required this.email,
    required this.image,
    this.initialIndex = 0
  });

  @override
  State<MainScaffoldScreen> createState() => _MainScaffoldScreenState();
}

class _MainScaffoldScreenState extends State<MainScaffoldScreen> {
  late int _selectedIndex = 0;
  final User? user = Auth().currentUser;
  late List<Widget> _widgetOptions;
  late ValueNotifier<String?> nameNotifier;
  late ValueNotifier<String?> emailNotifier;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    nameNotifier = ValueNotifier(widget.name);
    emailNotifier = ValueNotifier(widget.email);
    _widgetOptions = <Widget>[
      const HistoryScreen(),
      const ChartsScreen(),
      const BudgetScreen(),
      ProfileScreen(
        name: nameNotifier,
        email: emailNotifier,
        onUpdateName: updateUserName,
        onUpdateEmail: updateUserEmail,
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void updateUserName(String newName) {
    nameNotifier.value = newName;
  }

  void updateUserEmail(String newEmail) {
    emailNotifier.value = newEmail;
  }

  Future<void> signOut() async {
    await Auth().signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const WidgetTree()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      appBar: isWideScreen ? AppBar(
        title: const Text('Budget Buddy'),
      ) : null,
      drawer: isWideScreen ? Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    accountName: Text(widget.name ?? ''),
                    accountEmail: Text(widget.email ?? ''),
                    currentAccountPicture: CircleAvatar(
                      radius: 40,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: widget.image != null
                                ? NetworkImage(widget.image!) as ImageProvider
                                : const AssetImage("assets/images/avatar.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    decoration: const BoxDecoration(
                        color: AppColors.primaryColor
                    ),
                  ),
                  ListTile(
                    leading: const ImageIcon(AssetImage("assets/images/list.png")),
                    title: const Text('History'),
                    onTap: () {
                      _onItemTapped(0);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const ImageIcon(AssetImage("assets/images/pie-chart.png")),
                    title: const Text('Charts'),
                    onTap: () {
                      _onItemTapped(1);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const ImageIcon(AssetImage("assets/images/calculator.png")),
                    title: const Text('Budget'),
                    onTap: () {
                      _onItemTapped(2);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const ImageIcon(AssetImage("assets/images/Person.png")),
                    title: const Text('Person'),
                    onTap: () {
                      _onItemTapped(3);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.pop(context);
                  signOut();
                },
              ),
            )
          ],
        )
      ) : null,
      bottomNavigationBar: !isWideScreen ? BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage("assets/images/list.png")),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage("assets/images/pie-chart.png")),
            label: 'Charts',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage("assets/images/calculator.png")),
            label: 'Budget',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage("assets/images/Person.png")),
            label: 'Person',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black
      ) : null,
    );
  }
}
