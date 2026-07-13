import 'package:flutter/material.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';

class MarketPage extends StatelessWidget {
  const MarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Market', style: kSubHeadingSB),
      ),
    );
  }
}
