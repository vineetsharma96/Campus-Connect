import 'package:flutter/material.dart';

class AnimatedStatCounter extends StatelessWidget {
  final double targetValue;
  final String suffix;
  final TextStyle? style;
  final Duration duration;
  final int fractionDigits;

  const AnimatedStatCounter({
    super.key,
    required this.targetValue,
    this.suffix = '',
    this.style,
    this.duration = const Duration(milliseconds: 900),
    this.fractionDigits = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: targetValue),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final formattedValue = fractionDigits == 0
            ? value.toInt().toString()
            : value.toStringAsFixed(fractionDigits);
        return Text(
          '$formattedValue$suffix',
          style: style,
        );
      },
    );
  }
}
