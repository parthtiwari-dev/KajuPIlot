import 'package:flutter/material.dart';

import '../../core/theme/kaju_colors.dart';
import '../../core/theme/spacing.dart';

enum StatusBadgeTone {
  neutral,
  info,
  accent,
  success,
  warning,
  danger,
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.tone = StatusBadgeTone.neutral,
  });

  final String label;
  final StatusBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.kajuColors;
    final palette = _palette(colors);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(KajuRadius.full),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KajuSpacing.sm,
          vertical: KajuSpacing.xs,
        ),
        child: Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: palette.foreground,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }

  _StatusBadgePalette _palette(KajuColorTokens colors) {
    return switch (tone) {
      StatusBadgeTone.neutral => _StatusBadgePalette(
          background: colors.borderSubtle,
          foreground: colors.textSecondary,
        ),
      StatusBadgeTone.info => _StatusBadgePalette(
          background: colors.info.withValues(alpha: 0.12),
          foreground: colors.info,
        ),
      StatusBadgeTone.accent => _StatusBadgePalette(
          background: colors.accentMuted,
          foreground: colors.accent,
        ),
      StatusBadgeTone.success => _StatusBadgePalette(
          background: colors.successMuted,
          foreground: colors.success,
        ),
      StatusBadgeTone.warning => _StatusBadgePalette(
          background: colors.warningMuted,
          foreground: colors.warning,
        ),
      StatusBadgeTone.danger => _StatusBadgePalette(
          background: colors.dangerMuted,
          foreground: colors.danger,
        ),
    };
  }
}

class _StatusBadgePalette {
  const _StatusBadgePalette({
    required this.background,
    required this.foreground,
  });

  final Color background;
  final Color foreground;
}
