import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_finance_app/screens/profile_screen.dart';
import 'package:flutter_finance_app/screens/charts_screen.dart';
import 'package:flutter_finance_app/screens/budget_screen.dart';
import 'package:flutter_finance_app/screens/history_screen.dart';

import '../auth/auth.dart';

class MainScaffoldScreen extends StatefulWidget {
  final int initialIndex;
  final String ?name;
  final String ?email;

  const MainScaffoldScreen({
    Key? key,
    required this.name,
    required this.email,
    this.initialIndex = 0
  }) : super(key: key);

  @override
  _MainScaffoldScreenState createState() => _MainScaffoldScreenState();
}

class _MainScaffoldScreenState extends State<MainScaffoldScreen> {
  late int _selectedIndex = 0;
  final User? user = Auth().currentUser;
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _widgetOptions = <Widget>[
      HistoryScreen(),
      ChartsScreen(),
      BudgetScreen(),
      ProfileScreen(name: widget.name, email: widget.email,),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
      ),
    );
  }
}
