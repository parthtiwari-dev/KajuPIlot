import 'package:flutter/material.dart';

import '../../core/theme/kaju_colors.dart';

class PersonAvatar extends StatelessWidget {
  const PersonAvatar({
    super.key,
    required this.name,
    this.size = 40,
  });

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.kajuColors;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.accentMuted,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials(name),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colors.accent,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }

  String _initials(String value) {
    final words = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (words.isEmpty) {
      return '?';
    }

    if (words.length == 1) {
      return words.first.characters.take(2).toString().toUpperCase();
    }

    return words
        .take(2)
        .map((word) => word.characters.first)
        .join()
        .toUpperCase();
  }
}
