import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/kaju_colors.dart';
import '../../core/theme/spacing.dart';
import 'kaju_card.dart';

class KajuSkeletonLine extends StatelessWidget {
  const KajuSkeletonLine({
    super.key,
    this.width,
    this.height = 14,
  });

  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.kajuColors;

    return Shimmer.fromColors(
      baseColor: colors.borderSubtle,
      highlightColor: colors.borderMedium,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: colors.borderSubtle,
          borderRadius: BorderRadius.circular(KajuRadius.full),
        ),
      ),
    );
  }
}

class KajuSkeletonCard extends StatelessWidget {
  const KajuSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const KajuCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KajuSkeletonLine(width: 120, height: 16),
          SizedBox(height: KajuSpacing.md),
          KajuSkeletonLine(),
          SizedBox(height: KajuSpacing.sm),
          KajuSkeletonLine(width: 180),
        ],
      ),
    );
  }
}
