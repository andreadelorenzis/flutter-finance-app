import 'package:flutter/material.dart';
import 'package:flutter_finance_app/constants/colors.dart';

class Data {

  static Map<String, Map<String, dynamic>> transactionTypes = {
    'generic': {
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
    'dining': {
      'icon': Image.asset(
        'assets/images/restaurant.png',
        width: 24,
        height: 24,
      ),
      'color': Colors.amber,
    },
    'health': {
      'icon': Image.asset(
        'assets/images/heart.png',
        width: 24,
        height: 24,
      ),
      'color': Colors.lightGreen,
    },
    'travel': {
      'icon': Image.asset(
        'assets/images/plane.png',
        width: 24,
        height: 24,
      ),
      'color': Colors.lightBlueAccent,
    },
  };

}
