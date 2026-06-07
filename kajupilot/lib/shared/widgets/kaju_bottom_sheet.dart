import 'package:flutter/material.dart';

import '../../core/theme/kaju_colors.dart';
import '../../core/theme/spacing.dart';

Future<T?> showKajuBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool useRootNavigator = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: useRootNavigator,
    backgroundColor: context.kajuColors.bgElevated,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(KajuRadius.sheet),
      ),
    ),
    sheetAnimationStyle: AnimationStyle(
      duration: Duration(milliseconds: 320),
      reverseDuration: Duration(milliseconds: 220),
    ),
    builder: builder,
  );
}
