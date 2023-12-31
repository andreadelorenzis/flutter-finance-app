// File: savings_chart.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_finance_app/constants/colors.dart';

class SavingsChart extends StatefulWidget {
  final List<Map<String, dynamic>> monthlyBalances;

  const SavingsChart({
    Key? key,
    required this.monthlyBalances
  }) : super(key: key);

  @override
  _SavingsChartState createState() => _SavingsChartState();
}

class _SavingsChartState extends State<SavingsChart> {
  List<Color> gradientColors = [Colors.blue, Colors.blueAccent];
  bool showAvg = false;
  String selectedButton = '';

  List<FlSpot> getSpotsFromBalances() {
    var balances = widget.monthlyBalances.map<double>((e) => e["balance"] ?? 0.0).toList();
    double maxBalance = balances.isNotEmpty ? balances.reduce(max) : 0.0;
    double scaleFactor = maxBalance != 0 ? 10 / maxBalance : 1;

    return widget.monthlyBalances.asMap().entries.map((entry) {
      int index = entry.key;
      double value = (entry.value["balance"] ?? 0) * scaleFactor;
      return FlSpot(index.toDouble(), value);
    }).toList();
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 10,
        color: Colors.white
    );

    String month = widget.monthlyBalances[value.toInt()]["month"] ?? '';

    Widget text;
    switch (value.toInt()) {
      case 2:
        text = Text(month, style: style);
        break;
      case 5:
        text = Text(month, style: style);
        break;
      case 8:
        text = Text(month, style: style);
        break;
      default:
        text = Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 11,
        color: Colors.white
    );

    List<FlSpot> spots = getSpotsFromBalances();
    double maxScaledValue = spots.map((spot) => spot.y).reduce(max);
    var balances = widget.monthlyBalances.map<double>((e) => e["balance"] ?? 0.0).toList();
    double maxOriginalValue = balances.isNotEmpty ? balances.reduce(max) : 0.0;
    double interval = maxScaledValue / 2;
    double originalValue = value / maxScaledValue * maxOriginalValue;

    String labelText;
    if (value == 0 || value == interval || value == maxScaledValue) {
      labelText = '${originalValue.toStringAsFixed(2)}'; // Formatta il testo come desideri
    } else {
      return Container();
    }

    return Text(labelText, style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    List<FlSpot> spots = getSpotsFromBalances();
    double maxY = spots.map((spot) => spot.y).reduce(max);

    return LineChartData(
      backgroundColor: AppColors.primaryColor,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.white.withOpacity(0.1),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.white.withOpacity(0.0),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: spots.length.toDouble() - 1,
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(radius: 4, color: Colors.white)
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData avgData() {
    return LineChartData(
      backgroundColor: AppColors.primaryColor,
      lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 1,
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: bottomTitleWidgets,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
            interval: 1,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3.44),
            FlSpot(2.6, 3.44),
            FlSpot(4.9, 3.44),
            FlSpot(6.8, 3.44),
            FlSpot(8, 3.44),
            FlSpot(9.5, 3.44),
            FlSpot(11, 3.44),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
            ],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.primaryColor,
      ),
      child: Stack(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1.60,
            child: Padding(
              padding: const EdgeInsets.only(
                right: 18,
                left: 12,
                top: 36,
                bottom: 12,
              ),
              child: LineChart(
                showAvg ? avgData() : mainData(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
