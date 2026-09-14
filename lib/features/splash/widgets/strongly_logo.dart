import 'package:flutter/material.dart';
import '../../../core/constants/app_text_styles.dart';

class StronglyLogo extends StatelessWidget {
  final double fontSize;
  final double? letterSpacing;

  const StronglyLogo({
    super.key,
    this.fontSize = 42,
    this.letterSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      'STRONGLY',
      style: AppTextStyles.logoTitle(
        fontSize: fontSize,
        letterSpacing: letterSpacing,
      ),
    );
  }
}

