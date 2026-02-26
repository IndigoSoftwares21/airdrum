import 'package:flutter/material.dart';

enum AdButtonType { filled, outlined, text }

class AdButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AdButtonType type;
  final bool isDestructive;

  const AdButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.type = AdButtonType.filled,
    this.isDestructive = false,
  });

  factory AdButton.filled({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool isDestructive = false,
  }) {
    return AdButton(
      key: key,
      label: label,
      onPressed: onPressed,
      icon: icon,
      type: AdButtonType.filled,
      isDestructive: isDestructive,
    );
  }

  factory AdButton.outlined({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool isDestructive = false,
  }) {
    return AdButton(
      key: key,
      label: label,
      onPressed: onPressed,
      icon: icon,
      type: AdButtonType.outlined,
      isDestructive: isDestructive,
    );
  }

  factory AdButton.text({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool isDestructive = false,
  }) {
    return AdButton(
      key: key,
      label: label,
      onPressed: onPressed,
      icon: icon,
      type: AdButtonType.text,
      isDestructive: isDestructive,
    );
  }

  @override
  Widget build(BuildContext context) {
    Color? foregroundColor;
    if (isDestructive) {
      foregroundColor = Theme.of(context).colorScheme.error;
    }

    Widget child;
    if (icon != null) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(label)],
      );
    } else {
      child = Text(label);
    }

    switch (type) {
      case AdButtonType.filled:
        return FilledButton(
          onPressed: onPressed,
          style: isDestructive
              ? FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  foregroundColor: Theme.of(
                    context,
                  ).colorScheme.onErrorContainer,
                )
              : null,
          child: child,
        );
      case AdButtonType.outlined:
        return OutlinedButton(
          onPressed: onPressed,
          style: isDestructive
              ? OutlinedButton.styleFrom(foregroundColor: foregroundColor)
              : null,
          child: child,
        );
      case AdButtonType.text:
        return TextButton(
          onPressed: onPressed,
          style: isDestructive
              ? TextButton.styleFrom(foregroundColor: foregroundColor)
              : null,
          child: child,
        );
    }
  }
}
