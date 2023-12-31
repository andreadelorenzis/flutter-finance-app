import 'package:flutter/material.dart';
import 'package:flutter_finance_app/constants/colors.dart';

class Data {

  static Map<String, Map<String, dynamic>> transactionTypes = {
    'subscription': {
      'icon': Image.asset(
        'assets/images/bolt.png',
        width: 24,
        height: 24,
      ),
      'color': AppColors.subscriptionColor,
    },
    'event': {
      'icon': Image.asset(
        'assets/images/ticket.png',
        width: 24,
        height: 24,
      ),
      'color': AppColors.eventColor,
    },
    'grocery': {
      'icon': Image.asset(
        'assets/images/groceries.png',
        width: 24,
        height: 24,
      ),
      'color': AppColors.groceriesColor,
    },
  };

  static const List<Map<String, dynamic>> transactions = [
    {'type': 'subscription', 'amount': '€15.99', 'method': 'Payment', 'name': 'Netflix', 'date': '2023-01-01'},
    {'type': 'event', 'amount': '€45.00', 'method': 'Deposit', 'name': 'Concert', 'date': '2023-01-01'},
    {'type': 'grocery', 'amount': '€30.25', 'method': 'Payment', 'name': 'Grocery', 'date': '2023-01-01'},
    {'type': 'grocery', 'amount': '€20.00', 'method': 'Payment', 'name': 'Supermarket', 'date': '2023-01-05'},
    {'type': 'event', 'amount': '€60.00', 'method': 'Deposit', 'name': 'Movie Night', 'date': '2023-01-05'},
    {'type': 'subscription', 'amount': '€12.99', 'method': 'Payment', 'name': 'Spotify', 'date': '2023-01-10'},
    {'type': 'grocery', 'amount': '€25.50', 'method': 'Payment', 'name': 'Weekly Groceries', 'date': '2023-01-10'},
    {'type': 'event', 'amount': '€80.00', 'method': 'Deposit', 'name': 'Theatre Tickets', 'date': '2023-01-10'},
    {'type': 'grocery', 'amount': '€55.75', 'method': 'Payment', 'name': 'Grocery Store', 'date': '2023-01-15'},
    {'type': 'subscription', 'amount': '€18.00', 'method': 'Payment', 'name': 'Amazon Prime', 'date': '2023-01-15'},
    {'type': 'grocery', 'amount': '€22.30', 'method': 'Payment', 'name': 'Local Market', 'date': '2023-01-15'},
    {'type': 'event', 'amount': '€90.00', 'method': 'Deposit', 'name': 'Art Exhibition', 'date': '2023-01-15'},
    {'type': 'subscription', 'amount': '€10.00', 'method': 'Payment', 'name': 'Online Streaming', 'date': '2023-01-15'},
    {'type': 'grocery', 'amount': '€18.60', 'method': 'Payment', 'name': 'Groceries', 'date': '2023-01-15'},
    {'type': 'event', 'amount': '€50.00', 'method': 'Deposit', 'name': 'Music Festival', 'date': '2023-01-15'},
    {'type': 'subscription', 'amount': '€16.50', 'method': 'Payment', 'name': 'Gym Membership', 'date': '2023-01-15'},
    {'type': 'grocery', 'amount': '€40.80', 'method': 'Payment', 'name': 'Organic Food Store', 'date': '2023-01-15'},
    {'type': 'event', 'amount': '€70.00', 'method': 'Deposit', 'name': 'Football Match', 'date': '2023-01-15'},
    {'type': 'subscription', 'amount': '€9.99', 'method': 'Payment', 'name': 'Video Game', 'date': '2023-01-15'},
    {'type': 'grocery', 'amount': '€32.00', 'method': 'Payment', 'name': 'Supermarket Visit', 'date': '2023-01-15'},
  ];

  static const List<Map<String, dynamic>> weekTransactions = [
    {'type': 'grocery', 'amount': '€30.00', 'method': 'Payment', 'name': 'Grocery Shopping', 'date': '2023-01-02'},
    {'type': 'subscription', 'amount': '€50.00', 'method': 'Payment', 'name': 'Cable TV', 'date': '2023-01-05'},
    {'type': 'event', 'amount': '€15.00', 'method': 'Payment', 'name': 'Book Signing', 'date': '2023-01-08'},
    {'type': 'grocery', 'amount': '€20.00', 'method': 'Payment', 'name': 'Grocery Haul', 'date': '2023-01-10'},
    {'type': 'subscription', 'amount': '€100.00', 'method': 'Payment', 'name': 'Online Course', 'date': '2023-01-12'},
    {'type': 'event', 'amount': '€45.00', 'method': 'Payment', 'name': 'Sports Match', 'date': '2023-01-14'},
    {'type': 'grocery', 'amount': '€25.00', 'method': 'Payment', 'name': 'Grocery Stock', 'date': '2023-01-16'},
    {'type': 'subscription', 'amount': '€2000.00', 'method': 'Deposit', 'name': 'Monthly Salary', 'date': '2023-01-01'},
    {'type': 'event', 'amount': '€150.00', 'method': 'Deposit', 'name': 'Event Participation', 'date': '2023-01-07'},
    {'type': 'grocery', 'amount': '€500.00', 'method': 'Deposit', 'name': 'Market Sale', 'date': '2023-01-15'}
  ];

  static const List<Map<String, dynamic>> monthTransactions = [
    {'type': 'grocery', 'amount': '€30.00', 'method': 'Payment', 'name': 'Grocery Shopping', 'date': '2023-01-02'},
    {'type': 'subscription', 'amount': '€50.00', 'method': 'Payment', 'name': 'Cable TV', 'date': '2023-01-05'},
    {'type': 'event', 'amount': '€15.00', 'method': 'Payment', 'name': 'Book Signing', 'date': '2023-01-08'},
    {'type': 'grocery', 'amount': '€20.00', 'method': 'Payment', 'name': 'Grocery Haul', 'date': '2023-01-10'},
    {'type': 'subscription', 'amount': '€100.00', 'method': 'Payment', 'name': 'Online Course', 'date': '2023-01-12'},
    {'type': 'event', 'amount': '€45.00', 'method': 'Payment', 'name': 'Sports Match', 'date': '2023-01-14'},
    {'type': 'grocery', 'amount': '€25.00', 'method': 'Payment', 'name': 'Grocery Stock', 'date': '2023-01-16'},
    {'type': 'subscription', 'amount': '€2000.00', 'method': 'Deposit', 'name': 'Monthly Salary', 'date': '2023-01-01'},
    {'type': 'event', 'amount': '€150.00', 'method': 'Deposit', 'name': 'Event Participation', 'date': '2023-01-07'},
    {'type': 'grocery', 'amount': '€500.00', 'method': 'Deposit', 'name': 'Market Sale', 'date': '2023-01-15'}
  ];

  static const List<Map<String, dynamic>> yearTransactions = [
    {'type': 'grocery', 'amount': '€30.00', 'method': 'Payment', 'name': 'Grocery Shopping', 'date': '2023-01-02'},
    {'type': 'subscription', 'amount': '€50.00', 'method': 'Payment', 'name': 'Cable TV', 'date': '2023-01-05'},
    {'type': 'event', 'amount': '€15.00', 'method': 'Payment', 'name': 'Book Signing', 'date': '2023-01-08'},
    {'type': 'grocery', 'amount': '€20.00', 'method': 'Payment', 'name': 'Grocery Haul', 'date': '2023-01-10'},
    {'type': 'subscription', 'amount': '€100.00', 'method': 'Payment', 'name': 'Online Course', 'date': '2023-01-12'},
    {'type': 'event', 'amount': '€45.00', 'method': 'Payment', 'name': 'Sports Match', 'date': '2023-01-14'},
    {'type': 'grocery', 'amount': '€25.00', 'method': 'Payment', 'name': 'Grocery Stock', 'date': '2023-01-16'},
    {'type': 'subscription', 'amount': '€2000.00', 'method': 'Deposit', 'name': 'Monthly Salary', 'date': '2023-01-01'},
    {'type': 'event', 'amount': '€150.00', 'method': 'Deposit', 'name': 'Event Participation', 'date': '2023-01-07'},
    {'type': 'grocery', 'amount': '€500.00', 'method': 'Deposit', 'name': 'Market Sale', 'date': '2023-01-15'}
  ];

  static const List<Map<String, dynamic>> octoberBudgetTransactions = [
    {'type': 'grocery', 'amount': '€30.00', 'method': 'Payment', 'name': 'Grocery Shopping', 'date': '2023-01-02'},
    {'type': 'subscription', 'amount': '€50.00', 'method': 'Payment', 'name': 'Streaming Service', 'date': '2023-01-05'},
    {'type': 'event', 'amount': '€15.00', 'method': 'Payment', 'name': 'Concert Ticket', 'date': '2023-01-08'},
    {'type': 'grocery', 'amount': '€20.00', 'method': 'Payment', 'name': 'Grocery Trip', 'date': '2023-01-10'},
    {'type': 'subscription', 'amount': '€100.00', 'method': 'Payment', 'name': 'Gym Membership', 'date': '2023-01-12'},
    {'type': 'event', 'amount': '€45.00', 'method': 'Payment', 'name': 'Theater Show', 'date': '2023-01-14'},
    {'type': 'grocery', 'amount': '€25.00', 'method': 'Payment', 'name': 'Groceries', 'date': '2023-01-16'},
    {'type': 'subscription', 'amount': '€2000.00', 'method': 'Deposit', 'name': 'Monthly Salary', 'date': '2023-01-01'},
    {'type': 'event', 'amount': '€150.00', 'method': 'Deposit', 'name': 'Event Hosting', 'date': '2023-01-07'},
    {'type': 'grocery', 'amount': '€500.00', 'method': 'Deposit', 'name': 'Grocery Sale', 'date': '2023-01-15'}
  ];


  static const List<Map<String, dynamic>> novemberBudgetTransactions = [
    {'type': 'grocery', 'amount': '€30.00', 'method': 'Payment', 'name': 'Grocery Shopping', 'date': '2023-01-02'},
    {'type': 'subscription', 'amount': '€50.00', 'method': 'Payment', 'name': 'Internet Plan', 'date': '2023-01-05'},
    {'type': 'event', 'amount': '€15.00', 'method': 'Payment', 'name': 'Music Festival', 'date': '2023-01-08'},
    {'type': 'grocery', 'amount': '€20.00', 'method': 'Payment', 'name': 'Grocery Visit', 'date': '2023-01-10'},
    {'type': 'subscription', 'amount': '€100.00', 'method': 'Payment', 'name': 'Magazine Subscription', 'date': '2023-01-12'},
    {'type': 'event', 'amount': '€45.00', 'method': 'Payment', 'name': 'Art Exhibition', 'date': '2023-01-14'},
    {'type': 'grocery', 'amount': '€25.00', 'method': 'Payment', 'name': 'Grocery Store', 'date': '2023-01-16'},
    {'type': 'subscription', 'amount': '€2000.00', 'method': 'Deposit', 'name': 'Monthly Salary', 'date': '2023-01-01'},
    {'type': 'event', 'amount': '€150.00', 'method': 'Deposit', 'name': 'Event Planning', 'date': '2023-01-07'},
    {'type': 'grocery', 'amount': '€500.00', 'method': 'Deposit', 'name': 'Grocery Sale', 'date': '2023-01-15'}
  ];


  static const List<Map<String, dynamic>> decemberBudgetTransactions = [
    {'type': 'grocery', 'amount': '€30.00', 'method': 'Payment', 'name': 'Grocery Shopping', 'date': '2023-01-02'},
    {'type': 'subscription', 'amount': '€50.00', 'method': 'Payment', 'name': 'Cable TV', 'date': '2023-01-05'},
    {'type': 'event', 'amount': '€15.00', 'method': 'Payment', 'name': 'Book Signing', 'date': '2023-01-08'},
    {'type': 'grocery', 'amount': '€20.00', 'method': 'Payment', 'name': 'Grocery Haul', 'date': '2023-01-10'},
    {'type': 'subscription', 'amount': '€100.00', 'method': 'Payment', 'name': 'Online Course', 'date': '2023-01-12'},
    {'type': 'event', 'amount': '€45.00', 'method': 'Payment', 'name': 'Sports Match', 'date': '2023-01-14'},
    {'type': 'grocery', 'amount': '€25.00', 'method': 'Payment', 'name': 'Grocery Stock', 'date': '2023-01-16'},
    {'type': 'subscription', 'amount': '€2000.00', 'method': 'Deposit', 'name': 'Monthly Salary', 'date': '2023-01-01'},
    {'type': 'event', 'amount': '€150.00', 'method': 'Deposit', 'name': 'Event Participation', 'date': '2023-01-07'},
    {'type': 'grocery', 'amount': '€500.00', 'method': 'Deposit', 'name': 'Market Sale', 'date': '2023-01-15'}
  ];

  static const List<List<Map<String, dynamic>>> budgetTransactions = [
    octoberBudgetTransactions,
    novemberBudgetTransactions,
    decemberBudgetTransactions
  ];

  static const Map<String, dynamic> budgetInfo = {
    'startDate': '2023-01-01',
    'endDate': '2023-12-31',
    'initialBalance': 2000.0
  };

  static const List<Map<String, dynamic>> positions = [
    {
      'id': 1,
      'name': 'ETSY',
      'shares': 2,
      'value': 345.00,
      'roi': 12.17,
      'myPosition': true,
      'position': {
        'sharesPrecise': 2.234123,
        'avgCost': 50.45,
        'return': 167.81,
      },
      'stats': {
        'value': 150.23,
        'volume': 2234234,
        'MSAD': '150.46',
        'change': '+9.68%',
        'cap': '17.20B',

      }
    },
    {
      'id': 2,
      'name': 'ETSY',
      'shares': 2,
      'value': 345.00,
      'roi': 12.17,
      'myPosition': true,
      'position': {
        'sharesPrecise': 2.234123,
        'avgCost': 50.45,
        'return': 167.81,
      },
      'stats': {
        'value': 150.23,
        'volume': 2234234,
        'msad': '150.46',
        'change': '+9.68%',
        'cap': '17.20B',

      }
    },
    {'id': 3, 'name': 'ETSY', 'shares': 2, 'value': 345.00, 'roi': 12.17},
    {'id': 4, 'name': 'ETSY', 'shares': 2, 'value': 345.00, 'roi': 12.17},
    {'id': 5, 'name': 'ETSY', 'shares': 2, 'value': 345.00, 'roi': 12.17},
    {'id': 6, 'name': 'ETSY', 'shares': 2, 'value': 345.00, 'roi': 12.17},
    {'id': 7, 'name': 'ETSY', 'shares': 2, 'value': 345.00, 'roi': 12.17},
    {'id': 8, 'name': 'ETSY', 'shares': 2, 'value': 345.00, 'roi': 12.17},
    {'id': 9, 'name': 'ETSY', 'shares': 2, 'value': 345.00, 'roi': 12.17},
    {'id': 10, 'name': 'ETSY', 'shares': 2, 'value': 345.00, 'roi': 12.17},
    {'id': 11, 'name': 'ETSY', 'shares': 2, 'value': 345.00, 'roi': 12.17},
  ];
}
