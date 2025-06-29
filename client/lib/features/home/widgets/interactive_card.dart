import 'package:flutter/material.dart';

/// Tıklama efektleri ve standart bir stil sunan, yeniden kullanılabilir kart widget'ı.
class InteractiveCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  const InteractiveCard({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final splashColor = theme.colorScheme.primary.withAlpha(25);
    final highlightColor = theme.colorScheme.primary.withAlpha(15);
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(16.0);

    return Card(
      color: color ?? Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: effectiveBorderRadius),
      // InkWell efektlerinin köşelerden taşmasını engellemk için.
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: splashColor,
        highlightColor: highlightColor,
        borderRadius: effectiveBorderRadius,
        child: Padding(padding: padding ?? const EdgeInsets.all(20.0), child: child),
      ),
    );
  }
}
