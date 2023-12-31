import 'package:flutter/material.dart';
import 'package:flutter_finance_app/constants/colors.dart';
import 'package:flutter_finance_app/constants/data.dart';
import 'package:flutter_finance_app/screens/stock_detail_screen.dart';

class StocksScreen extends StatefulWidget {
  const StocksScreen({super.key});

  @override
  State<StatefulWidget> createState() => _StocksScreenState();

}

class _StocksScreenState extends State<StocksScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
                top: 20,
                left: 30,
                right: 30,
                bottom: 30
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "STOCKS BALANCE",
                  style: TextStyle(
                      fontSize: 21.0,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFA5A5A5)
                  ),
                ),
                SizedBox(height: 10,),
                const Text(
                  "5,502.00 €",
                  style: TextStyle(
                      fontSize: 36.0,
                      fontWeight:
                      FontWeight.w900
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 25.0, bottom: 14.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Transactions History',
                        style: TextStyle(fontSize: 21.0, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {

                        },
                        child: const Text("ADD +", style: TextStyle(
                          color: AppColors.textColor2,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),),
                      )
                    ],
                  )
                ),
                Container(
                  child: ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: [
                      ...Data.positions.map<Widget>((position) {
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => StockDetailScreen(id: position['id'])
                            ));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(position['name'], style: TextStyle(
                                            color: AppColors.pureBlack, fontSize: 18, fontWeight: FontWeight.w400
                                        ),),
                                        Text('${position['shares']} shares', style: TextStyle(
                                            color: AppColors.textColor2, fontSize: 13
                                        ),)
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 20),
                                      child: Text("${position['value']}€", style: TextStyle(
                                          color: AppColors.pureBlack, fontSize: 20, fontWeight: FontWeight.w800
                                      ),),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: position['roi'] >= 0 ? Colors.green : Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text('${position['roi']}%', style: TextStyle(
                                      color: Colors.white, fontSize: 15
                                  ),),
                                )
                              ],
                            ),
                          ),
                        );
                      })
                    ]
                  ),
                )
              ],
            ),
          )
      ),
    );
  }


}

