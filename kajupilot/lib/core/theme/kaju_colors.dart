import 'package:flutter/material.dart';

class KajuColorTokens extends ThemeExtension<KajuColorTokens> {
  const KajuColorTokens({
    required this.bgBase,
    required this.bgSurface,
    required this.bgCard,
    required this.bgElevated,
    required this.borderSubtle,
    required this.borderMedium,
    required this.accent,
    required this.accentMuted,
    required this.accentDim,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.success,
    required this.successMuted,
    required this.warning,
    required this.warningMuted,
    required this.danger,
    required this.dangerMuted,
    required this.info,
  });

  final Color bgBase;
  final Color bgSurface;
  final Color bgCard;
  final Color bgElevated;
  final Color borderSubtle;
  final Color borderMedium;
  final Color accent;
  final Color accentMuted;
  final Color accentDim;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color success;
  final Color successMuted;
  final Color warning;
  final Color warningMuted;
  final Color danger;
  final Color dangerMuted;
  final Color info;

  @override
  KajuColorTokens copyWith({
    Color? bgBase,
    Color? bgSurface,
    Color? bgCard,
    Color? bgElevated,
    Color? borderSubtle,
    Color? borderMedium,
    Color? accent,
    Color? accentMuted,
    Color? accentDim,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? success,
    Color? successMuted,
    Color? warning,
    Color? warningMuted,
    Color? danger,
    Color? dangerMuted,
    Color? info,
  }) {
    return KajuColorTokens(
      bgBase: bgBase ?? this.bgBase,
      bgSurface: bgSurface ?? this.bgSurface,
      bgCard: bgCard ?? this.bgCard,
      bgElevated: bgElevated ?? this.bgElevated,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderMedium: borderMedium ?? this.borderMedium,
      accent: accent ?? this.accent,
      accentMuted: accentMuted ?? this.accentMuted,
      accentDim: accentDim ?? this.accentDim,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      success: success ?? this.success,
      successMuted: successMuted ?? this.successMuted,
      warning: warning ?? this.warning,
      warningMuted: warningMuted ?? this.warningMuted,
      danger: danger ?? this.danger,
      dangerMuted: dangerMuted ?? this.dangerMuted,
      info: info ?? this.info,
    );
  }

  @override
  KajuColorTokens lerp(ThemeExtension<KajuColorTokens>? other, double t) {
    if (other is! KajuColorTokens) {
      return this;
    }

    return KajuColorTokens(
      bgBase: Color.lerp(bgBase, other.bgBase, t)!,
      bgSurface: Color.lerp(bgSurface, other.bgSurface, t)!,
      bgCard: Color.lerp(bgCard, other.bgCard, t)!,
      bgElevated: Color.lerp(bgElevated, other.bgElevated, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderMedium: Color.lerp(borderMedium, other.borderMedium, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentMuted: Color.lerp(accentMuted, other.accentMuted, t)!,
      accentDim: Color.lerp(accentDim, other.accentDim, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      success: Color.lerp(success, other.success, t)!,
      successMuted: Color.lerp(successMuted, other.successMuted, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningMuted: Color.lerp(warningMuted, other.warningMuted, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerMuted: Color.lerp(dangerMuted, other.dangerMuted, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}

class KajuColors {
  const KajuColors._();

  static const dark = KajuColorTokens(
    bgBase: Color(0xFF0B0B10),
    bgSurface: Color(0xFF13131C),
    bgCard: Color(0xFF1A1A26),
    bgElevated: Color(0xFF22223A),
    borderSubtle: Color(0xFF28283C),
    borderMedium: Color(0xFF36366A),
    accent: Color(0xFFC8873A),
    accentMuted: Color(0x1FC8873A),
    accentDim: Color(0xFF7A5020),
    textPrimary: Color(0xFFEEEEF4),
    textSecondary: Color(0xFF7878A0),
    textMuted: Color(0xFF46466A),
    success: Color(0xFF34D399),
    successMuted: Color(0x1F34D399),
    warning: Color(0xFFFBBF24),
    warningMuted: Color(0x1FFBBF24),
    danger: Color(0xFFF87171),
    dangerMuted: Color(0x1FF87171),
    info: Color(0xFF60A5FA),
  );

  static const light = KajuColorTokens(
    bgBase: Color(0xFFF3F2ED),
    bgSurface: Color(0xFFFAFAF7),
    bgCard: Color(0xFFFFFFFF),
    bgElevated: Color(0xFFF6F5F0),
    borderSubtle: Color(0xFFE6E5DE),
    borderMedium: Color(0xFFD0CFC4),
    accent: Color(0xFFB5692A),
    accentMuted: Color(0x1FB5692A),
    accentDim: Color(0xFF7A5020),
    textPrimary: Color(0xFF18181E),
    textSecondary: Color(0xFF636380),
    textMuted: Color(0xFF9898B8),
    success: Color(0xFF059669),
    successMuted: Color(0x1F059669),
    warning: Color(0xFFD97706),
    warningMuted: Color(0x1FD97706),
    danger: Color(0xFFDC2626),
    dangerMuted: Color(0x1FDC2626),
    info: Color(0xFF2563EB),
  );
}

extension KajuColorsContext on BuildContext {
  KajuColorTokens get kajuColors {
    return Theme.of(this).extension<KajuColorTokens>() ?? KajuColors.dark;
  }
}
