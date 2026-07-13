import 'package:flutter/material.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';

class DonatePage extends StatelessWidget {
  const DonatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Donate', style: kSubHeadingSB),
      ),
    );
  }
}
