import 'package:flutter/material.dart';
import '../../splash/widgets/strongly_logo.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        StronglyLogo(
          fontSize: 24,
          letterSpacing: -1.2,
        ),
      ],
    );
  }
}
