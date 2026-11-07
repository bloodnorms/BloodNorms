// ============================================================================
// BloodNorms | shared/widgets/app_stat_card.dart
//
// Soft, calm stat card with headline number, label, and subtle icon.
// Adheres to 16px radius and minimal 1px border.
// ============================================================================

import 'package:flutter/material.dart';
import '../theme/brand_colors.dart';
import '../theme/brand_typography.dart';

/// Stat card for metrics and KPIs.
class AppStatCard extends StatefulWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBgColor;
  final String? subtitle;
  final String? trendText;
  final VoidCallback? onTap;

  const AppStatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
    this.iconBgColor,
    this.subtitle,
    this.trendText,
    this.onTap,
  });

  @override
  State<AppStatCard> createState() => _AppStatCardState();
}

class _AppStatCardState extends State<AppStatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = widget.iconColor ?? BrandColors.primaryAction;
    final effectiveIconBg = widget.iconBgColor ?? BrandColors.surfaceMuted;
    final displaySubtitle = widget.subtitle ?? widget.trendText;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform: Matrix4.translationValues(0, _isHovered && widget.onTap != null ? -2 : 0, 0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: BrandColors.background,
            borderRadius: BorderRadius.circular(BrandColors.radiusCard),
            border: Border.all(
              color: _isHovered ? BrandColors.borderStrong : BrandColors.borderSubtle,
              width: 1.0,
            ),
            boxShadow: _isHovered && widget.onTap != null ? BrandColors.shadowCardHover : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.label,
                      style: BrandTypography.label(color: BrandColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.icon != null)
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: effectiveIconBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(widget.icon, size: 16, color: effectiveIconColor),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.value,
                style: TextStyle(
                  fontFamily: BrandTypography.fontFamily,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: BrandColors.textPrimary,
                  height: 1.2,
                ),
              ),
              if (displaySubtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  displaySubtitle,
                  style: BrandTypography.label(color: BrandColors.textMuted),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

