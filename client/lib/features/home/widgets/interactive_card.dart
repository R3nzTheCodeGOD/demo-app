import 'package:flutter/material.dart';

/// Tıklama efektleri ve standart bir stil sunan, yeniden kullanılabilir kart widget'ı.
class InteractiveCard extends StatelessWidget {
  /// Kartın içine yerleştirilecek widget (çocuk).
  final Widget child;

  /// Kartın üzerine tıklandığında çağrılacak fonksiyon.
  final VoidCallback? onTap;

  /// Kartın arka plan rengi. Opsiyonel, verilmezse temadan alınacak.
  final Color? color;

  /// Kartın köşe yuvarlaklığı.
  final BorderRadius? borderRadius;

  /// Kartın iç boşluğu.
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
    final splashColor = theme.colorScheme.primary.withOpacity(0.1);
    final highlightColor = theme.colorScheme.primary.withOpacity(0.05);
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(16.0);

    return Card(
      color: color ?? Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: effectiveBorderRadius),
      // InkWell efektlerinin köşelerden taşmasını engeller.
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: splashColor,
        highlightColor: highlightColor,
        borderRadius: effectiveBorderRadius,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(20.0),
          child: child,
        ),
      ),
    );
  }
}
