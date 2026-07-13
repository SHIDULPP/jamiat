import 'package:flutter/material.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Home', style: kSubHeadingSB)),
    );
  }
}
