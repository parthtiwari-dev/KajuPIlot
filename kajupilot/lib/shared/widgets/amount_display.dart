import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/kaju_colors.dart';
import '../../core/utils/currency.dart';

enum AmountDisplayTone {
  neutral,
  received,
  pending,
  overdue,
}

enum AmountDisplaySize {
  large,
  medium,
  small,
}

class AmountDisplay extends StatelessWidget {
  const AmountDisplay({
    super.key,
    required this.amountPaise,
    this.tone = AmountDisplayTone.neutral,
    this.size = AmountDisplaySize.medium,
    this.showDecimals = false,
    this.textAlign,
  });

  final int amountPaise;
  final AmountDisplayTone tone;
  final AmountDisplaySize size;
  final bool showDecimals;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final colors = context.kajuColors;
    final amountTheme = Theme.of(context).extension<KajuAmountTextTheme>();
    final baseStyle = switch (size) {
      AmountDisplaySize.large => amountTheme?.amountLarge,
      AmountDisplaySize.medium => amountTheme?.amountMedium,
      AmountDisplaySize.small => amountTheme?.amountSmall,
    };

    return Text(
      formatInrFromPaise(amountPaise, showDecimals: showDecimals),
      textAlign: textAlign,
      style: baseStyle?.copyWith(color: _toneColor(colors)),
    );
  }

  Color _toneColor(KajuColorTokens colors) {
    return switch (tone) {
      AmountDisplayTone.neutral => colors.textPrimary,
      AmountDisplayTone.received => colors.success,
      AmountDisplayTone.pending => colors.warning,
      AmountDisplayTone.overdue => colors.danger,
    };
  }
}
