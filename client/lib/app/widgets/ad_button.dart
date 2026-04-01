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
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            splashFactory: NoSplash.splashFactory,
            backgroundColor: isDestructive ? Theme.of(context).colorScheme.error : null,
            foregroundColor: isDestructive ? Theme.of(context).colorScheme.onError : null,
          ),
          child: child,
        );
      case AdButtonType.outlined:
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            splashFactory: NoSplash.splashFactory,
            side: isDestructive
                ? BorderSide(color: Theme.of(context).colorScheme.error)
                : null,
            foregroundColor: isDestructive ? Theme.of(context).colorScheme.error : null,
          ),
          child: child,
        );
      case AdButtonType.text:
        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            splashFactory: NoSplash.splashFactory,
            foregroundColor: isDestructive ? Theme.of(context).colorScheme.error : null,
          ),
          child: child,
        );
    }
  }
}
