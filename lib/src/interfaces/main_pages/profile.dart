import 'package:flutter/material.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Profile', style: kSubHeadingSB),
      ),
    );
  }
}
