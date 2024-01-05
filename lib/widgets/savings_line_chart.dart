// File: savings_chart.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_finance_app/constants/colors.dart';
import 'package:flutter_finance_app/constants/months.dart';

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

    String monthYear = widget.monthlyBalances[value.toInt()]["month"] ?? '';
    List<String> parts = monthYear.split(' ');
    String year = parts.length > 1 ? parts[1] : '';
    String month = Months.getShort(value.toInt());
    int lastIndex = widget.monthlyBalances.length - 2;
    int middleIndex = (widget.monthlyBalances.length / 2).toInt();

    // Mostra l'etichetta solo per il primo e l'ultimo mese
    Widget text;
    if (value.toInt() == 1 || value.toInt() == lastIndex || value.toInt() == middleIndex) {
      text = Text('$month $year', style: style);
    } else {
      text = Text('', style: style);
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
    double maxY = spots.map((spot) => spot.y).reduce(max);
    double minY = spots.map((spot) => spot.y).reduce(min);

    var balances = widget.monthlyBalances.map<double>((e) => e["balance"] ?? 0.0).toList();
    double maxOriginalValue = balances.isNotEmpty ? balances.reduce(max) : 0.0;
    double minOriginalValue = balances.isNotEmpty ? balances.reduce(min) : 0.0;

    double scaleFactor = (maxY - minY) != 0 ? (maxOriginalValue - minOriginalValue) / (maxY - minY) : 1;
    double originalValue = minOriginalValue + (value - minY) * scaleFactor;
    String labelText;
    if (value == minY || value == maxY) {
      if (originalValue.abs() >= 10000) {
        labelText = '${(originalValue.abs() / 1000.0).round()}k';
        if (originalValue < 0) labelText = '-$labelText';
      } else {
        labelText = '${originalValue.round()}';
      }
    } else {
      return Container();
    }

    return Center(
        child: Padding(
          padding: EdgeInsets.only(right: 10),
          child: Text(labelText, style: style, textAlign: TextAlign.left),
        ),
    );
  }

  bool shouldDrawHorizontalLine(double value) {
    List<double> realValues = widget.monthlyBalances
        .map((e) => (e["balance"] as double) ?? 0.0)
        .toList();

    double maxY = realValues.reduce(max);
    double minY = realValues.reduce(min);

    double scaleFactor = (maxY - minY) != 0 ? 10 / (maxY - minY) : 1;
    List<double> scaledValues = realValues.map((realValue) => (realValue - minY) * scaleFactor + minY).toList();

    // Aggiunge il controllo per il primo e l'ultimo valore
    double firstScaledValue = scaledValues.first;
    double lastScaledValue = scaledValues.last;

    return scaledValues.contains(value) || value == firstScaledValue || value == lastScaledValue;
  }


  LineChartData mainData() {
    List<FlSpot> spots = getSpotsFromBalances();
    double maxY = spots.map((spot) => spot.y).reduce(max);
    double minY = spots.map((spot) => spot.y).reduce(min);

    // Aggiunge un piccolo buffer ai valori di maxY e minY per evitare che la linea tocchi il bordo del grafico
    double buffer = (maxY - minY) * 0.1;
    maxY += buffer;
    minY -= buffer;

    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueAccent,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((LineBarSpot touchedSpot) {
              final textStyle = TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14
              );
              double realValue = widget.monthlyBalances[touchedSpot.x.toInt()]['balance'];
              return LineTooltipItem('${realValue }€', textStyle);
            }).toList();
          }
        ),
        touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
          // Qui puoi gestire gli eventi touch, se necessario
        },
        handleBuiltInTouches: true,
      ),
      backgroundColor: AppColors.primaryColor,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          if (shouldDrawHorizontalLine(value)) {
            return FlLine(
              color: Colors.grey.withOpacity(0.1),
              strokeWidth: 1,
            );
          } else {
            return FlLine(
              color: Colors.transparent,
              strokeWidth: 0,
            );
          }
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
        border: Border(
          left: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
          right: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
          top: BorderSide(color: Colors.transparent),
          bottom: BorderSide(color: Colors.transparent),
        ),
      ),
      minX: 0,
      maxX: spots.length.toDouble() - 1,
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: false,
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
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.primaryColor,
      ),
      child: Stack(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1.65,
            child: Padding(
              padding: const EdgeInsets.only(
                right: 18,
                left: 12,
                top: 34,
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
