import 'package:flutter/material.dart';

import '../../core/theme/kaju_colors.dart';
import '../../core/theme/spacing.dart';
import 'parse_sheet.dart';

class UniversalInputBar extends StatelessWidget {
  const UniversalInputBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.kajuColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        KajuSpacing.md,
        KajuSpacing.sm,
        KajuSpacing.md,
        KajuSpacing.xs,
      ),
      child: Material(
        color: colors.bgElevated,
        borderRadius: BorderRadius.circular(KajuRadius.md),
        child: InkWell(
          key: const Key('universal-input-bar'),
          borderRadius: BorderRadius.circular(KajuRadius.md),
          onTap: () => showParseSheet(context),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: KajuSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(KajuRadius.md),
              border: Border.all(color: colors.borderSubtle),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: colors.accent, size: 20),
                const SizedBox(width: KajuSpacing.sm),
                Expanded(
                  child: Text(
                    'Kal Amit ko 80k ke liye call...',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.textSecondary,
                        ),
                  ),
                ),
                const SizedBox(width: KajuSpacing.sm),
                Icon(Icons.mic_none, color: colors.textSecondary, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
