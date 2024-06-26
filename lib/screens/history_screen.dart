import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_finance_app/auth/auth.dart';
import 'package:flutter_finance_app/constants/colors.dart';
import 'package:flutter_finance_app/screens/transaction_editor.dart';
import 'package:flutter_finance_app/utils/utils.dart';
import 'package:flutter_finance_app/widgets/transaction_item.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';


class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  OverlayEntry? editingAppBarOverlay;
  Set<String> selectedTransactions = {};
  bool isEditing = false;
  String selectedButton = '';

  late Future<Map<String, dynamic>> transactionsFuture;
  late List<Map<String, dynamic>> transactions;
  late double balance;

  @override
  void initState() {
    super.initState();
    transactionsFuture = fetchHistoryData();
  }

  Future<Map<String, dynamic>> fetchHistoryData() async {
    String? userId = Auth().getCurrentUser()?.uid;

    // Ottiene il documento dell'utente per il campo 'balance'
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (!userDoc.exists) {
      throw Exception("Firestore user document not found");
    }

    double balance = (userDoc.data() as Map<String, dynamic>)['balance']?.toDouble() ?? 0.0;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .get();

    List<Map<String, dynamic>> transactions = querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    // Gestisco anche le transazioni fisse
    List<Map<String, dynamic>> augmentedTransactions = [];
    DateTime now = DateTime.now();
    var uuid = const Uuid();
    for (var transaction in transactions) {
      if (transaction['isFixed'] != null && transaction['isFixed'] == true) {
        DateTime transactionDate = (transaction['date'] as Timestamp).toDate();
        int monthDiff = Utils.calculateMonthDifference(now, transactionDate);
        String originalId = transaction['id'];

        for (int i = 0; i <= monthDiff; i++) {
          DateTime newDate = DateTime(now.year, now.month - i, transactionDate.day);
          Map<String, dynamic> newTransaction = Map<String, dynamic>.from(transaction);
          newTransaction['date'] = Timestamp.fromDate(newDate);
          newTransaction['id'] = uuid.v4();
          newTransaction['fixedId'] = originalId;
          augmentedTransactions.add(newTransaction);
        }
      } else {
        augmentedTransactions.add(transaction);
      }
    }

    // Ordina le transazioni in augmentedTransactions in base alla data
    augmentedTransactions.sort((a, b) {
      DateTime dateA = (a['date'] as Timestamp).toDate();
      DateTime dateB = (b['date'] as Timestamp).toDate();
      return dateB.compareTo(dateA);
    });

    return {
      'balance': balance,
      'transactions': augmentedTransactions,
    };
  }

  void showEditingAppBar() {
    editingAppBarOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: _buildEditingAppBar(),
      ),
    );

    Overlay.of(context).insert(editingAppBarOverlay!);
  }

  void hideEditingAppBar() {
    editingAppBarOverlay?.remove();
    editingAppBarOverlay = null;
  }

  @override
  void dispose() {
    hideEditingAppBar();
    super.dispose();
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final isSelected = selectedTransactions.contains(transaction['id']);

    return TransactionItem(
      transaction: transaction,
      isSelected: isSelected,
      isEditing: isEditing,
      onLongPress: () {
        setState(() {
          isEditing = true;
          selectedTransactions.add(transaction['id']);
        });
        showEditingAppBar();
      },
      onCheckboxChange: (bool newValue, String transactionKey) {
        setState(() {
          if(newValue) {
            selectedTransactions.add(transactionKey);
          } else {
            selectedTransactions.remove(transactionKey);
          }
        });
      },
    );
  }

  Map<String, dynamic> _findTransactionByKey(String key) {
    for (var transaction in transactions) {
      String transactionKey = transaction['id'];
      if (transactionKey == key) {
        Map<String, dynamic> foundTransaction = Map.from(transaction);
        foundTransaction['date'] = foundTransaction['date'].toDate();
        return foundTransaction;
      }
    }
    return {};
  }

  AppBar _buildEditingAppBar() {
    return AppBar(
      title: const Text('Select transactions'),
      actions: [
        if (selectedTransactions.length == 1)
          IconButton(icon: const Icon(Icons.edit), onPressed: () {
            if (selectedTransactions.length == 1) {
              final String transactionKey = selectedTransactions.first;
              final Map<String, dynamic> transaction = _findTransactionByKey(transactionKey);
              _navigateToTransactionEditor(
                  isEditing: true,
                  transaction: transaction
              );
              setState(() {
                isEditing = false;
                selectedTransactions.clear();
              });
            }
          }),
        IconButton(icon: const Icon(Icons.delete), onPressed: () {
          deleteTransactions();
        }),
        IconButton(icon: const Icon(Icons.close), onPressed: () {
          setState(() {
            isEditing = false;
            selectedTransactions.clear();
          });
          hideEditingAppBar();
        }),
      ],
    );
  }

  Future<void> _navigateToTransactionEditor({bool isEditing = false, Map<String, dynamic>? transaction}) async {
    if (isEditing && selectedTransactions.length == 1) {
      hideEditingAppBar();
    }

    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => TransactionEditor(
        isEditing: isEditing,
        isBudget: false,
        transaction: transaction,
        onSubmit: isEditing ? editTransaction : saveNewTransaction,
      ),
    ));
  }

  Future<void> saveNewTransaction(Map<String, dynamic> transactionData) async {
    String? userId = Auth().getCurrentUser()?.uid;

    // Ottieni l'importo della transazione
    double transactionAmount = transactionData['amount'];

    var userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);
    var transactionsCollectionRef = userDocRef.collection('transactions');

    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot userSnapshot = await transaction.get(userDocRef);
      double currentBalance = (userSnapshot.data() as Map<String, dynamic>)['balance']?.toDouble() ?? 0.0;

      double updatedBalance = currentBalance;

      if (transactionData['isFixed'] == null || !transactionData['isFixed']) {
        updatedBalance = transactionData['method'] == 'Payment'
            ? currentBalance - transactionAmount
            : currentBalance + transactionAmount;
      } else {
        DateTime transactionDate = (transactionData['date'] as Timestamp).toDate();
        DateTime now = DateTime.now();
        int monthDiff = Utils.calculateMonthDifference(now, transactionDate);
        for (int i = 0; i <= monthDiff; i++) {
          updatedBalance = transactionData['method'] == 'Payment'
              ? updatedBalance - transactionAmount
              : updatedBalance + transactionAmount;
        }
      }

      var uuid = const Uuid();
      String transactionId = uuid.v4();
      transactionData['id'] = transactionId;

      transaction.set(transactionsCollectionRef.doc(transactionId), transactionData);
      transaction.update(userDocRef, {'balance': updatedBalance});
    }).then((_) {
      const snackBar = SnackBar(content: Text('Transaction added.'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      transactionsFuture = fetchHistoryData();
      setState(() {});
    }).catchError((e) {
      if (kDebugMode) {
        print("Error while trying to add the transaction: $e");
      }
    });
  }
  
  Future<void> editTransaction(Map<String, dynamic> transactionData) async {
    String? userId = Auth().getCurrentUser()?.uid;

    var userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);
    var transactionsCollectionRef = userDocRef.collection('transactions');

    FirebaseFirestore.instance.runTransaction((transaction) async {
      QuerySnapshot querySnapshot;

      if (transactionData['isFixed'] == null || !transactionData['isFixed']) {
        querySnapshot = await transactionsCollectionRef.where('id', isEqualTo: transactionData['id']).get();
      } else {
        querySnapshot = await transactionsCollectionRef.where('id', isEqualTo: transactionData['fixedId']).get();
      }

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot transactionDocument = querySnapshot.docs.first;

        DocumentSnapshot userSnapshot = await transaction.get(userDocRef);
        double currentBalance = (userSnapshot.data() as Map<String, dynamic>)['balance']?.toDouble() ?? 0.0;

        // Calcola la differenza tra l'importo originale e quello aggiornato
        double originalAmount = (transactionDocument.data() as Map<String, dynamic>)['amount']?.toDouble() ?? 0.0;
        double updatedAmount = transactionData['amount'];
        double amountDifference = updatedAmount - originalAmount;

        // Aggiorna il bilancio
        double updatedBalance = currentBalance;
        if (transactionData['isFixed'] == null || !transactionData['isFixed']) {
          updatedBalance = transactionData['method'] == 'Payment'
              ? currentBalance - amountDifference
              : currentBalance + amountDifference;
        } else {
          Map<String, dynamic> data = transactionDocument.data() as Map<String, dynamic>;
          Timestamp timestamp = data['date'] as Timestamp;
          DateTime fixedTransactionDate = timestamp.toDate();
          transactionData['date'] = fixedTransactionDate;
          DateTime now = DateTime.now();
          int monthDiff = Utils.calculateMonthDifference(now, fixedTransactionDate);
          for (int i = 0; i <= monthDiff; i++) {
            updatedBalance = transactionData['method'] == 'Payment'
                ? updatedBalance - amountDifference
                : updatedBalance + amountDifference;
          }
        }

        transaction.update(userDocRef, {'balance': updatedBalance});

        // Aggiorna la transazione
        transaction.update(transactionDocument.reference, transactionData);
      }
    }).then((_) {
      const snackBar = SnackBar(content: Text('Transaction updated.'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      transactionsFuture = fetchHistoryData();
      setState(() {});
    }).catchError((e) {
      if (kDebugMode) {
        print("Error while trying to update the transaction: $e");
      }
    });
  }

  Future<void> deleteTransactions() async {
    // Verifica se ci sono transazioni fisse
    bool hasFixedTransactions = false;
    for (String transactionId in selectedTransactions) {
      var transaction = _findTransactionByKey(transactionId);
      if (transaction['isFixed'] != null && transaction['isFixed']) {
        hasFixedTransactions = true;
        break;
      }
    }

    if (hasFixedTransactions) {
      bool shouldDelete = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Warning!'),
              content: const Text("Fixed transaction will be removed for all the months. Continue?"),
              actions: <Widget>[
                ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text("No")
                ),
                ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text("Yes")
                ),
              ],
            );
          }
      );
      if (!shouldDelete) return;
    }

    String? userId = Auth().getCurrentUser()?.uid;
    var userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);
    var transactionsCollection = userDocRef.collection('transactions');

    FirebaseFirestore.instance.runTransaction((transaction) async {
      double totalAmountToRemove = 0.0;
      List<DocumentSnapshot> docsToDelete = [];

      // Calcola il totale delle transazioni da rimuovere
      for (String transactionId in selectedTransactions) {
        var transaction = _findTransactionByKey(transactionId);
        QuerySnapshot querySnapshot;

        if (transaction['isFixed'] == null || !transaction['isFixed']) {
          querySnapshot = await transactionsCollection.where('id', isEqualTo: transaction['id']).get();
        } else {
          querySnapshot = await transactionsCollection.where('id', isEqualTo: transaction['fixedId']).get();
        }

        for (var doc in querySnapshot.docs) {
          double amount = (doc.data() as Map<String, dynamic>)['amount']?.toDouble() ?? 0.0;
          if (transaction['isFixed'] == null || !transaction['isFixed']) {
            if ((doc.data() as Map<String, dynamic>)['method']?.toString() == 'Payment') {
              totalAmountToRemove -= amount;
            } else {
              totalAmountToRemove += amount;
            }
          } else {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            Timestamp timestamp = data['date'] as Timestamp;
            DateTime fixedTransactionDate = timestamp.toDate();
            DateTime now = DateTime.now();
            int monthDiff = Utils.calculateMonthDifference(now, fixedTransactionDate);
            for (int i = 0; i <= monthDiff; i++) {
              if ((doc.data() as Map<String, dynamic>)['method']?.toString() == 'Payment') {
                totalAmountToRemove -= amount;
              } else {
                totalAmountToRemove += amount;
              }
            }
          }

          docsToDelete.add(doc); // Pianifica la cancellazione
        }
      }

      // Legge il bilancio dell'utente
      DocumentSnapshot userSnapshot = await transaction.get(userDocRef);
      double currentBalance = (userSnapshot.data() as Map<String, dynamic>)['balance']?.toDouble() ?? 0.0;
      double updatedBalance = currentBalance - totalAmountToRemove;

      // Aggiorna il bilancio dell'utente
      transaction.update(userDocRef, {'balance': updatedBalance});

      // Elimina le transazioni
      for (var doc in docsToDelete) {
        transaction.delete(doc.reference);
      }
    }).then((_) {
      setState(() {
        isEditing = false;
        selectedTransactions.clear();
      });
      hideEditingAppBar();
      transactionsFuture = fetchHistoryData();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Selected transactions deleted'),
      ));
    }).catchError((e) {
      if (kDebugMode) {
        print("Error while trying to delete the transactions: $e");
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error while trying to delete transactions'),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Transactions', style: TextStyle(
            color: AppColors.pureBlack, fontWeight: FontWeight.w800, fontSize: 25
        ),),)
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.black,));
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error while trying to load transactions'));
          } else if (!snapshot.hasData || snapshot.data!['transactions'].isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 50.0, color: Colors.grey),
                  Text("No data available", style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          } else {
            transactions = snapshot.data!['transactions'];
            balance = snapshot.data!['balance'];

            // Raggruppa le transazioni per data
            Map<String, List<Map<String, dynamic>>> groupedTransactions = {};
            for(var transaction in transactions) {
              final date = transaction['date'].toDate();
              final formattedDate = DateFormat('dd MMM yyyy').format(date);
              if (!groupedTransactions.containsKey(formattedDate)) {
                groupedTransactions[formattedDate] = [];
              }
              groupedTransactions[formattedDate]!.add(transaction);
            }

            // Costruisce la lista di elementi
            return ListView(
              padding: const EdgeInsets.only(
                  top: 0,
                  left: 30,
                  right: 30,
                  bottom: 30
              ),
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    'Balance',
                    style: TextStyle(
                        fontSize: 21.0,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFA5A5A5)
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Text(
                    '$balance €',
                    style: const TextStyle(
                        fontSize: 36.0,
                        fontWeight:
                        FontWeight.w900
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 25.0, bottom: 14.0),
                  child: Text(
                    'Transactions History',
                    style: TextStyle(fontSize: 21.0, fontWeight: FontWeight.bold),
                  ),
                ),
                transactions.isNotEmpty
                  ? ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: groupedTransactions.entries.map<Widget>((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Text(
                              entry.key, // Data delle transazioni
                              style: const TextStyle(
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textColor2
                              ),
                            ),
                          ),
                          ...entry.value.map((transaction) => _buildTransactionItem(transaction)),
                          const SizedBox(height: 15)
                        ],
                      );
                    }).toList(),
                  )
                : const Center(child: Text('No transactions'),)
              ],
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondaryColor,
        onPressed: () => _navigateToTransactionEditor(),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

}


