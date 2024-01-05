import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_finance_app/constants/colors.dart';
import 'package:flutter_finance_app/constants/data.dart';
import 'package:flutter_finance_app/screens/transaction_editor.dart';
import 'package:flutter_finance_app/widgets/savings_line_chart.dart';
import 'package:flutter_finance_app/widgets/transaction_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_finance_app/auth/auth.dart';
import 'package:uuid/uuid.dart';


class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
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
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Utente non autenticato');
    }

    String userId = user.uid;

    // Ottiene il documento dell'utente per il campo 'balance'
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (!userDoc.exists) {
      throw Exception("Documento utente non trovato.");
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

    return {
      'balance': balance,
      'transactions': transactions,
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

    Overlay.of(context)?.insert(editingAppBarOverlay!);
  }

  void hideEditingAppBar() {
    editingAppBarOverlay?.remove();
    editingAppBarOverlay = null;
  }

  @override
  void dispose() {
    hideEditingAppBar(); // Assicurati di rimuovere l'OverlayEntry quando non è più necessario
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

  AppBar _buildNormalAppBar() {
    return AppBar(title: const Text('Home'));
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
      title: const Text('Seleziona transazioni'),
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
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }
    String userId = user.uid;

    // Ottieni l'importo della transazione
    double transactionAmount = transactionData['amount'];

    var userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);
    var transactionsCollectionRef = userDocRef.collection('transactions');

    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot userSnapshot = await transaction.get(userDocRef);
      double currentBalance = (userSnapshot.data() as Map<String, dynamic>)['balance']?.toDouble() ?? 0.0;

      double updatedBalance = transactionData['method'] == 'Payment'
          ? currentBalance - transactionAmount
          : currentBalance + transactionAmount;

      var uuid = Uuid();
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
      print("Errore nell'aggiunta della transazione: $e");
    });
  }
  
  Future<void> editTransaction(Map<String, dynamic> transactionData) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }
    String userId = user.uid;

    var userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);
    var transactionsCollectionRef = userDocRef.collection('transactions');

    FirebaseFirestore.instance.runTransaction((transaction) async {
      QuerySnapshot querySnapshot = await transactionsCollectionRef.where('id', isEqualTo: transactionData['id']).get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot transactionDocument = querySnapshot.docs.first;

        DocumentSnapshot userSnapshot = await transaction.get(userDocRef);
        double currentBalance = (userSnapshot.data() as Map<String, dynamic>)['balance']?.toDouble() ?? 0.0;

        // Calcola la differenza tra l'importo originale e quello aggiornato
        double originalAmount = (transactionDocument.data() as Map<String, dynamic>)['amount']?.toDouble() ?? 0.0;
        double updatedAmount = transactionData['amount'];
        double amountDifference = updatedAmount - originalAmount;

        print(originalAmount);
        print(updatedAmount);
        print(amountDifference);

        // Aggiorna il bilancio
        double updatedBalance = transactionData['method'] == 'Payment'
            ? currentBalance - amountDifference
            : currentBalance + amountDifference;
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
      print("Errore nell'aggiornamento della transazione: $e");
    });
  }

  Future<void> deleteTransactions() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("Utente non autenticato");
      return;
    }
    String userId = user.uid;

    var userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);
    var transactionsCollection = userDocRef.collection('transactions');

    FirebaseFirestore.instance.runTransaction((transaction) async {
      double totalAmountToRemove = 0.0;
      List<DocumentSnapshot> docsToDelete = [];

      // Calcola il totale delle transazioni da rimuovere
      for (String transactionId in selectedTransactions) {
        QuerySnapshot querySnapshot = await transactionsCollection.where('id', isEqualTo: transactionId).get();
        for (var doc in querySnapshot.docs) {
          double amount = (doc.data() as Map<String, dynamic>)['amount']?.toDouble() ?? 0.0;
          if ((doc.data() as Map<String, dynamic>)['method']?.toString() == 'Payment') {
            totalAmountToRemove -= amount;
          } else {
            totalAmountToRemove += amount;
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Transazioni selezionate eliminate.'),
      ));
    }).catchError((e) {
      print("Errore nell'eliminazione delle transazioni: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Errore nell\'eliminazione delle transazioni.'),
      ));
    });
  }


  Future<void> addMockTransactionsToFirestore() async {

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    String userId = user.uid;
    CollectionReference transactionsCollection = FirebaseFirestore.instance.collection('users').doc(userId).collection('transactions');

    final List<Map<String, dynamic>> mockTransactions = Data.transactions;

    var uuid = Uuid();
    void addUuid(List<Map<String, dynamic>> transactions) {
      for (var transaction in transactions) {
        transaction['id'] = uuid.v4();
      }
    }
    addUuid(mockTransactions);

    for (var transaction in mockTransactions) {
      DateTime parsedDate = DateTime.parse(transaction['date']);
      double parsedAmount = double.tryParse(transaction['amount'].replaceAll('€', '')) ?? 0.0;
      Map<String, dynamic> firestoreData = {
        'type': transaction['type'],
        'amount': parsedAmount,
        'method': transaction['method'],
        'name': transaction['name'],
        'date': Timestamp.fromDate(parsedDate),
        'id': transaction['id']
      };
      await transactionsCollection.add(firestoreData);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Transactions', style: TextStyle(
            color: AppColors.pureBlack, fontWeight: FontWeight.w800, fontSize: 25
        ),),)
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: AppColors.black,));
          } else if (snapshot.hasError) {
            return Center(child: Text('Errore nel caricamente delle transazioni'));
          } else if (!snapshot.hasData || snapshot.data!['transactions'].isEmpty) {
            return Center(
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
              final date = transaction['date'].toDate().toString().split(' ')[0];
              if (!groupedTransactions.containsKey(date)) {
                groupedTransactions[date] = [];
              }
              groupedTransactions[date]!.add(transaction);
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
                  padding: EdgeInsets.symmetric(vertical: 6.0),
                  child: Text(
                    '${balance} €',
                    style: TextStyle(
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
                !transactions.isEmpty
                  ? Container(
                  child: ListView(
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
                          ...entry.value.map((transaction) => _buildTransactionItem(transaction)).toList(),
                          const SizedBox(height: 15)
                        ],
                      );
                    }).toList(),
                  ),
                )
                : Center(child: Text('Nessuna transazione'),)
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


