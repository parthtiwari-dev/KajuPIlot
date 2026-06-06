import 'package:flutter/material.dart';

import '../../core/theme/kaju_colors.dart';
import '../../core/theme/spacing.dart';

class KajuCard extends StatelessWidget {
  const KajuCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(KajuSpacing.md),
    this.margin,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.kajuColors;
    final brightness = Theme.of(context).brightness;
    final radius = BorderRadius.circular(KajuRadius.lg);

    final content = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: radius,
        border: Border.all(color: colors.borderSubtle),
        boxShadow: brightness == Brightness.light
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );

    return content;
  }
}
