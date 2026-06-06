import 'package:flutter/material.dart';

import '../../core/theme/kaju_colors.dart';
import '../../core/theme/spacing.dart';

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
          onTap: () => _showInputSheet(context),
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
                    'Sold 50kg W320 to Amit at ₹780...',
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

  void _showInputSheet(BuildContext context) {
    final colors = context.kajuColors;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(KajuRadius.sheet),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: KajuSpacing.lg,
            right: KajuSpacing.lg,
            top: KajuSpacing.md,
            bottom: MediaQuery.of(context).viewInsets.bottom + KajuSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.borderMedium,
                    borderRadius: BorderRadius.circular(KajuRadius.full),
                  ),
                ),
              ),
              const SizedBox(height: KajuSpacing.lg),
              Text(
                "What's happening?",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: KajuSpacing.md),
              TextField(
                minLines: 4,
                maxLines: 7,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Tomorrow call Amit for 80k payment...',
                ),
              ),
              const SizedBox(height: KajuSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Parse'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
