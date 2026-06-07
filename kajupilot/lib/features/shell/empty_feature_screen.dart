import 'package:flutter/material.dart';

import '../../core/theme/kaju_colors.dart';
import '../../core/theme/spacing.dart';

class EmptyFeatureScreen extends StatelessWidget {
  const EmptyFeatureScreen({
    super.key,
    required this.title,
    required this.eyebrow,
    required this.body,
    required this.icon,
  });

  final String title;
  final String eyebrow;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.kajuColors;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        KajuSpacing.lg,
        KajuSpacing.xl,
        KajuSpacing.lg,
        160,
      ),
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colors.textMuted,
                letterSpacing: 0,
              ),
        ),
        const SizedBox(height: KajuSpacing.sm),
        Text(
          title,
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: KajuSpacing.xl),
        Container(
          padding: const EdgeInsets.all(KajuSpacing.lg),
          decoration: BoxDecoration(
            color: colors.bgCard,
            borderRadius: BorderRadius.circular(KajuRadius.lg),
            border: Border.all(color: colors.borderSubtle),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.accentMuted,
                  borderRadius: BorderRadius.circular(KajuRadius.md),
                ),
                child: Icon(icon, color: colors.accent),
              ),
              const SizedBox(width: KajuSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      body,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: KajuSpacing.sm),
                    Text(
                      'Ready for the next phase.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
