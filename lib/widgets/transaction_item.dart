import 'package:flutter/material.dart';
import 'package:flutter_finance_app/constants/data.dart';

class TransactionItem extends StatefulWidget{
  final Map<String, dynamic> transaction;
  final bool isSelected;
  final bool isEditing;
  final Function onLongPress;
  final Function(bool, String) onCheckboxChange;

  const TransactionItem({
    super.key,
    required this.transaction,
    required this.isSelected,
    required this.isEditing,
    required this.onLongPress,
    required this.onCheckboxChange,
  });

  @override
  State<TransactionItem> createState() => _TransactionItemState();
}

class _TransactionItemState extends State<TransactionItem> {
  @override
  Widget build(BuildContext context) {
    final transactionType = Data.transactionTypes[widget.transaction['type']];

    return InkWell(
      onLongPress: () => widget.onLongPress(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            if (widget.isEditing)
              Checkbox(
                value: widget.isSelected,
                onChanged: (bool? newValue) {
                  widget.onCheckboxChange(newValue!, widget.transaction['id']);
                },
              ),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (transactionType?['color'] ?? Colors.grey).withOpacity(0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: transactionType?['icon'] ?? Image.asset(
                'assets/images/ticket.png',
                width: 24,
                height: 24,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.transaction['name'],
                    style: const TextStyle(fontSize: 18, color: Color(0xFF212121), fontWeight: FontWeight.w500),
                  ),
                  Text(
                    widget.transaction['method'],
                    style: const TextStyle(fontSize: 11, color: Color(0xFF5A5B78), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Text(
              '${widget.transaction['method'] == 'Payment' ? '-' : '+'}${widget.transaction['amount']}',
              style: TextStyle(
                  color: widget.transaction['method'] == 'Payment' ? Colors.red : Colors.green,
                  fontSize: 18
              ),
            ),
          ],
        ),
      ),
    );
  }
}