import 'package:flutter/material.dart';

class Progresscircle extends StatelessWidget {
  final Color? color;
  final double? size;
  final double strokeWidth;

  const Progresscircle({
    super.key,
    this.color,
    this.size,
    this.strokeWidth = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size ?? 25,
      height: size ?? 25,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? Colors.blue),
      ),
    );
  }
}
