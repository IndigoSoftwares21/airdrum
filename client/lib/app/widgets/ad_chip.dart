import 'package:flutter/material.dart';
import 'ad_text.dart';
import 'pulse_dot.dart';

class AdStatusChip extends StatelessWidget {
  final String label;
  final bool isConnected;
  final bool isTrailing;

  const AdStatusChip({
    super.key,
    required this.label,
    this.isConnected = false,
    this.isTrailing = false,
  });

  @override
  Widget build(BuildContext context) {
    final avatarWidget = isConnected
        ? const PulseDot()
        : Icon(
            Icons.error_outline,
            size: 14,
            color: Theme.of(context).colorScheme.error,
          );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isTrailing) ...[
            avatarWidget,
            const SizedBox(width: 8),
          ],
          AdText.label(
            label,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
          if (isTrailing) ...[
            const SizedBox(width: 8),
            avatarWidget,
          ],
        ],
      ),
    );
  }
}
