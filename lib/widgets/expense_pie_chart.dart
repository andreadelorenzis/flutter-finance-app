import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_finance_app/constants/colors.dart';
import 'package:flutter_finance_app/constants/data.dart';
import 'package:flutter_finance_app/widgets/indicator.dart';

class PieChartSample2 extends StatefulWidget {
  final Map<String, double> categories;

  const PieChartSample2({
    super.key,
    required this.categories
  });

  @override
  _PieChart2State createState() => _PieChart2State();
}

class _PieChart2State extends State<PieChartSample2> {
  int touchedIndex = -1;


  @override
  Widget build(BuildContext context) {
    var categoryList = widget.categories.keys.toList();
    final screenSize = MediaQuery.of(context).size;
    final isWideScreen = screenSize.width > 600;

    return AspectRatio(
      aspectRatio: isWideScreen ? 3.0 : 1.6,
      child: Row(
        children: <Widget>[
          const SizedBox(
            height: 18,
          ),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: showingSections(),
                ),
              ),
            ),
          ),
          SizedBox(width: 20,),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List<Widget>.generate(widget.categories.length, (index) {
              Color color = Data.transactionTypes[categoryList[index]]?['color'] ?? Colors.grey;
              String text = categoryList[index];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Indicator(color: color, text: text, isSquare: true,),
              );
            }),
          ),
          const SizedBox(
            width: 28,
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    double total = widget.categories.values.fold(0, (a, b) => a + b);
    var categoryList = widget.categories.keys.toList();

    double screenWidth =  MediaQuery.of(context).size.width;
    double baseRadius = screenWidth / 10;

    return List.generate(widget.categories.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;

      final radius = isTouched ? baseRadius * 1.2 : baseRadius;

      final shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      double value = (widget.categories[categoryList[i]]! / total) * 100;
      Color color = Data.transactionTypes[categoryList[i]]?['color'];

      return PieChartSectionData(
        color: color,
        value: value,
        title: '${value.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: AppColors.mainTextColor1,
          shadows: shadows,
        ),
      );
    });


  }

}