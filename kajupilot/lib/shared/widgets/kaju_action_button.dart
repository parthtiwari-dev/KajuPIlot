import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class KajuActionButton extends StatelessWidget {
  const KajuActionButton({
    super.key,
    this.label = 'Call',
    this.icon = Icons.phone_outlined,
    this.phoneNumber,
    this.onPressed,
  });

  final String label;
  final IconData icon;
  final String? phoneNumber;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null || _normalizedPhoneNumber != null;

    return FilledButton.icon(
      onPressed: enabled ? _handlePressed : null,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }

  String? get _normalizedPhoneNumber {
    final value = phoneNumber?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }

    return value;
  }

  void _handlePressed() {
    final callback = onPressed;
    if (callback != null) {
      callback();
      return;
    }

    final number = _normalizedPhoneNumber;
    if (number == null) {
      return;
    }

    unawaited(launchUrl(Uri(scheme: 'tel', path: number)));
  }
}
