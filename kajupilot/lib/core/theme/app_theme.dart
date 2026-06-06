import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'kaju_colors.dart';

class KajuTheme {
  const KajuTheme._();

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return _buildTheme(
      base: base,
      colors: KajuColors.dark,
      brightness: Brightness.dark,
    );
  }

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return _buildTheme(
      base: base,
      colors: KajuColors.light,
      brightness: Brightness.light,
    );
  }

  static ThemeData _buildTheme({
    required ThemeData base,
    required KajuColorTokens colors,
    required Brightness brightness,
  }) {
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme);
    final mono = GoogleFonts.jetBrainsMonoTextTheme(base.textTheme);

    return base.copyWith(
      scaffoldBackgroundColor: colors.bgBase,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.accent,
        onPrimary: Colors.white,
        secondary: colors.info,
        onSecondary: Colors.white,
        error: colors.danger,
        onError: Colors.white,
        surface: colors.bgSurface,
        onSurface: colors.textPrimary,
      ),
      textTheme: textTheme.copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 32,
          letterSpacing: -0.5,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 24,
          letterSpacing: -0.3,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 18,
          letterSpacing: -0.2,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(
          color: colors.textPrimary,
          fontSize: 16,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          color: colors.textSecondary,
          fontSize: 14,
        ),
        labelSmall: textTheme.labelSmall?.copyWith(
          color: colors.textMuted,
          fontWeight: FontWeight.w500,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.bgBase,
        foregroundColor: colors.textPrimary,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.bgBase,
        indicatorColor: colors.accentMuted,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            color: selected ? colors.accent : colors.textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? colors.accent : colors.textSecondary,
            size: 22,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.bgCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.accent, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.accent,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.accent,
        selectionColor: colors.accentMuted,
        selectionHandleColor: colors.accent,
      ),
      cardTheme: CardTheme(
        color: colors.bgCard,
        elevation: brightness == Brightness.light ? 1 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.borderSubtle),
        ),
      ),
      extensions: [
        colors,
        KajuAmountTextTheme(
          amountLarge: mono.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
          amountMedium: mono.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
          amountSmall: mono.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class KajuAmountTextTheme extends ThemeExtension<KajuAmountTextTheme> {
  const KajuAmountTextTheme({
    required this.amountLarge,
    required this.amountMedium,
    required this.amountSmall,
  });

  final TextStyle? amountLarge;
  final TextStyle? amountMedium;
  final TextStyle? amountSmall;

  @override
  KajuAmountTextTheme copyWith({
    TextStyle? amountLarge,
    TextStyle? amountMedium,
    TextStyle? amountSmall,
  }) {
    return KajuAmountTextTheme(
      amountLarge: amountLarge ?? this.amountLarge,
      amountMedium: amountMedium ?? this.amountMedium,
      amountSmall: amountSmall ?? this.amountSmall,
    );
  }

  @override
  KajuAmountTextTheme lerp(
    ThemeExtension<KajuAmountTextTheme>? other,
    double t,
  ) {
    if (other is! KajuAmountTextTheme) {
      return this;
    }

    return KajuAmountTextTheme(
      amountLarge: TextStyle.lerp(amountLarge, other.amountLarge, t),
      amountMedium: TextStyle.lerp(amountMedium, other.amountMedium, t),
      amountSmall: TextStyle.lerp(amountSmall, other.amountSmall, t),
    );
  }
}
