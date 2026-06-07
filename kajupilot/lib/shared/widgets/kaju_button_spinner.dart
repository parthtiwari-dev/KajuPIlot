import 'package:flutter/material.dart';

class KajuButtonSpinner extends StatelessWidget {
  const KajuButtonSpinner({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onPrimary;
    return SizedBox.square(
      dimension: 16,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: color,
      ),
    );
  }
}
