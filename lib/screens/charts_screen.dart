import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_finance_app/constants/colors.dart';
import 'package:flutter_finance_app/constants/data.dart';
import 'package:flutter_finance_app/widgets/expense_pie_chart.dart';
import 'package:intl/intl.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ChartsScreenState();

}

class _ChartsScreenState extends State<ChartsScreen> with TickerProviderStateMixin  {
  TabController? _tabController;
  late final PageController _pageController;
  late Future<List<Map<String, dynamic>>> transactionsFuture;
  late List<Map<String, dynamic>> transactions;
  late Map<String, Map<String, double>> categorizedTransactions;
  String selectedOption = 'Expenses';
  int numberOfMonths = 12;
  int tabPaginationInterval = 12;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: numberOfMonths, vsync: this, initialIndex: numberOfMonths - 1);
    _pageController = PageController(initialPage: 0);
    transactionsFuture = _loadTransactions();
    categorizedTransactions = {};
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _loadTransactions() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    String userId = user.uid;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .get();

    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
  
  void addMoreMonths() {
    setState(() {
      numberOfMonths += tabPaginationInterval;
      int currentIndex = _tabController?.index ?? numberOfMonths;
      _tabController?.dispose();
      _tabController = TabController(length: numberOfMonths, vsync: this, initialIndex: currentIndex + tabPaginationInterval);
    });
  }

  void organizeTransactions(List<Map<String, dynamic>> transactions) {
    categorizedTransactions.clear();
    for (var transaction in transactions) {
      if ((selectedOption == 'Expenses' && transaction['method'] == 'Payment') ||
          (selectedOption == 'Deposits' && transaction['method'] == 'Deposit')) {
        DateTime date = (transaction['date'] as Timestamp).toDate();
        String monthKey = "${date.year}-${date.month}";
        String category = transaction['type'];
        double amount = transaction['amount'];

        categorizedTransactions.putIfAbsent(monthKey, () => {});
        var currentAmount = categorizedTransactions[monthKey]![category] ?? 0;
        categorizedTransactions[monthKey]![category] = currentAmount + amount;
      }
    }
  }

  Widget appBarEmptyTransactionsTitle() {
    return const Center(child: Text('Transactions', style: TextStyle(
        color: AppColors.pureBlack, fontWeight: FontWeight.w800, fontSize: 25
    ),),);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedOption,
                underline: Container(),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w800),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedOption = newValue ?? 'Expenses';
                  });
                },
                selectedItemBuilder: (BuildContext context) {
                  return <String>['Expenses', 'Deposits'].map<Widget>((String value) {
                    return Align(
                      alignment: Alignment.center,
                      child: Text(
                        selectedOption,
                        style: const TextStyle(
                          fontSize: 25,
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    );
                  }).toList();
                },
                items: <String>['Expenses', 'Deposits'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            )
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: TabBar(
            controller: _tabController,
            labelStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold
            ),
            tabAlignment: TabAlignment.start,
            padding: EdgeInsets.zero,
            tabs: List.generate(numberOfMonths, (index) {
              DateTime month = DateTime.now().subtract(Duration(days: 30 * index));
              DateTime now = DateTime.now();
              String formattedDate = DateFormat('MMM yyyy').format(month);

              // Logica per 'This month' e 'Last month'
              if (month.year == now.year && month.month == now.month) {
                formattedDate = 'This month';
              } else if ((month.year == now.year && month.month == now.month - 1)) {
                formattedDate = 'Last month';
              } else if ((month.year == now.year - 1) && (month.month == 12 && now.month == 1)) {
                formattedDate = 'Last month'; // caso di gennaio
              }

              return GestureDetector(
                onTap: () {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeIn,
                  );
                },
                child: Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      index == numberOfMonths - 1
                        ? Padding(padding: const EdgeInsets.only(right: 20), child: IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: addMoreMonths,
                          ) ,)
                        : const SizedBox(),
                      Text(formattedDate)
                    ],
                  ),
                ),
              );
            }).reversed.toList(),
            isScrollable: true,
          )
        )
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.black,));
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error while trying to load transactions'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {

          }

          transactions = snapshot.data!;
          organizeTransactions(transactions);

          return PageView.builder(
            controller: _pageController,
            itemCount: numberOfMonths,
            reverse: true,
            onPageChanged: (index) {
              _tabController?.animateTo((numberOfMonths-1) - index);
            },
            itemBuilder: (context, index) {
              DateTime monthToShow = DateTime.now().subtract(Duration(days: 30 * index));
              String monthKey = "${monthToShow.year}-${monthToShow.month}";

              // Calcolo dei totali e delle percentuali per le categorie
              Map<String, double> categories = categorizedTransactions[monthKey] ?? {};

              if (categories.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bar_chart, size: 50.0, color: Colors.grey),
                      Text("No data available", style: TextStyle(fontSize: 18),),
                    ],
                  ),
                );
              }

              double totalAmount = categories.values.fold(0, (a, b) => a + b);

              List<Widget> categoryWidgets = categories.entries.map((entry) {
                double percentage = (entry.value / totalAmount) * 100;
                Widget icon = Data.transactionTypes[entry.key]?['icon'] ?? const SizedBox();
                Color color = Data.transactionTypes[entry.key]?['color'] ?? Colors.grey;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: color.withOpacity(0.25),
                        child: icon,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${entry.key}    €${entry.value.toStringAsFixed(2)}'),
                                Text('${percentage.toStringAsFixed(1)}%'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList();

              return SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.only(
                      top: 20,
                      left: 30,
                      right: 30,
                      bottom: 30
                  ),
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      Center(child: PieChartSample2(
                        categories: categorizedTransactions[monthKey] ?? {},
                      )),
                      const SizedBox(height: 20,),
                      const Divider(),
                      const SizedBox(height: 20,),
                      Column(children: categoryWidgets,),
                    ],
                  ),
                ),
              );
            },
          );
        },
      )
    );
  }
}

