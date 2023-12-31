import 'package:flutter/material.dart';
import 'package:flutter_finance_app/constants/colors.dart';
import 'package:flutter_finance_app/constants/data.dart';

class StockDetailScreen extends StatefulWidget {
  final int id;

  const StockDetailScreen({
    super.key,
    required this.id
  });

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {

  Map<String, dynamic>? stockDetail;

  @override
  void initState() {
    super.initState();
    stockDetail = _findStockById(widget.id);
  }

  Map<String, dynamic>? _findStockById(int id) {
    try {
      return Data.positions.firstWhere((position) => position['id'] == id);
    } catch (e) {
      return null;
    }
  }

  Widget _buildColumnItem({required String title, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 13, color: Color(0xFF5A5B78), fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 18, color: Color(0xFF212121), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildRowItem({required String title, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 30),
          child: Text(
            title,
            style: const TextStyle(fontSize: 13, color: Color(0xFF5A5B78), fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 18, color: Color(0xFF212121), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget roundedButtonWithIcon({
    required String text,
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
    double borderRadius = 15.0, // Default borderRadius value
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: EdgeInsets.symmetric(horizontal: 8)
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          SizedBox(width: 8),
          Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(stockDetail?['name'], style: TextStyle(
              fontSize: 23, fontWeight: FontWeight.w500, color: AppColors.pureBlack
            ),),
            Text("${stockDetail!['value'].toString()}€", style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textColor2
            ),)
          ],
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              Container(
                padding: const EdgeInsets.only(
                    top: 0,
                    left: 30,
                    right: 30,
                    bottom: 30
                ),
                child: stockDetail == null
                    ? Center(child: Text("Stock not found"))
                    : Column(
                  children: [
                    SizedBox(height: 30),
                    // Placeholder per il grafico
                    Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: Center(child: Text("Grafico Andamento")),
                    ),
                    SizedBox(height: 30),
                    Container(
                      child: stockDetail?['myPosition']
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 25.0, bottom: 14.0),
                            child: Text(
                              'Your position',
                              style: TextStyle(fontSize: 21.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Flex(
                            direction: Axis.horizontal,
                            children: [
                              Expanded(
                                child: _buildColumnItem(
                                  title: 'Shares',
                                  value: stockDetail!['position']['sharesPrecise'].toString(),
                                ),
                              ),
                              Expanded(
                                child: _buildColumnItem(
                                  title: 'Market value',
                                  value: stockDetail!['stats']['value'].toString(),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Flex(
                            direction: Axis.horizontal,
                            children: [
                              Expanded(
                                child: _buildColumnItem(
                                  title: 'Avg cost',
                                  value: stockDetail!['position']['avgCost'].toString(),
                                ),
                              ),
                              Expanded(
                                child: _buildColumnItem(
                                  title: 'Return',
                                  value: stockDetail!['position']['return'].toString(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                          : null,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 35.0, bottom: 14.0),
                          child: Text(
                            'Stats',
                            style: TextStyle(fontSize: 21.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Flex(
                          direction: Axis.horizontal,
                          children: [
                            Expanded(
                              child: _buildRowItem(
                                  title: 'Value',
                                  value: stockDetail!['stats']['value'].toString()
                              ),
                            ),
                            Expanded(
                              child: _buildRowItem(
                                  title: 'Change',
                                  value: stockDetail!['stats']['change']
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Flex(
                          direction: Axis.horizontal,
                          children: [
                            Expanded(
                              child: _buildRowItem(
                                  title: 'Volume',
                                  value: stockDetail!['stats']['volume'].toString()
                              ),
                            ),
                            Expanded(
                              child: _buildRowItem(
                                  title: 'Mkt cap',
                                  value: stockDetail!['stats']['cap']
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Flex(
                          direction: Axis.horizontal,
                          children: [
                            Expanded(
                              child: _buildRowItem(
                                  title: 'change',
                                  value: stockDetail!['stats']['change']
                              ),
                            ),
                            Expanded(
                              child: _buildRowItem(
                                  title: 'change',
                                  value: stockDetail!['stats']['change']
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50,)
            ],
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                roundedButtonWithIcon(
                    text: 'Add to list',
                    color: Color(0xFF29B83C),
                    icon: Icons.add,
                    onPressed: () {

                    }
                ),
                SizedBox(width: 10,),
                roundedButtonWithIcon(
                    text: 'Remove',
                    color: Color(0xFFE03D32),
                    icon: Icons.remove,
                    onPressed: () {

                    }
                ),
                SizedBox(width: 10,),
                roundedButtonWithIcon(
                    text: 'Edit',
                    color: Color(0xFFC1C51D),
                    icon: Icons.edit,
                    onPressed: () {

                    }
                )
              ],
            )
          )
        ],
      )
    );
  }

}
