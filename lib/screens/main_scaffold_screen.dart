import 'package:flutter/material.dart';
import 'package:flutter_finance_app/screens/profile_screen.dart';
import 'package:flutter_finance_app/screens/stocks_screen.dart';
import 'package:flutter_finance_app/screens/budget_screen.dart';
import 'package:flutter_finance_app/screens/home_screen.dart';

class MainScaffoldScreen extends StatefulWidget {

  final int initialIndex;
  const MainScaffoldScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _MainScaffoldScreenState createState() => _MainScaffoldScreenState();
}

class _MainScaffoldScreenState extends State<MainScaffoldScreen> {
  late int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    BudgetScreen(),
    StocksScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome, Tom!'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Gestisci le notifiche qui
            },
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage("assets/images/Home.png")),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage("assets/images/Dashboard.png")),
            label: 'Budget',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage("assets/images/graph.png")),
            label: 'Stocks',
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
