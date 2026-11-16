import 'package:flutter/material.dart';
import '../models/gps_point.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

class StatusBadge extends StatefulWidget {
  final TrackingStatus status;
  final String languageCode;
  final bool showPulse;

  const StatusBadge({
    super.key,
    required this.status,
    required this.languageCode,
    this.showPulse = true,
  });

  @override
  State<StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<StatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnimation =
        Tween<double>(begin: 0.8, end: 1.2).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    String labelKey;
    IconData icon;

    switch (widget.status) {
      case TrackingStatus.live:
        badgeColor = AppColors.statusLive;
        labelKey = 'status_live';
        icon = Icons.satellite_alt_rounded;
        break;
      case TrackingStatus.demo:
        badgeColor = AppColors.statusDemo;
        labelKey = 'status_demo';
        icon = Icons.sensors_rounded;
        break;
      case TrackingStatus.stale:
        badgeColor = AppColors.statusStale;
        labelKey = 'status_stale';
        icon = Icons.access_time_rounded;
        break;
      case TrackingStatus.offline:
        badgeColor = AppColors.statusOffline;
        labelKey = 'status_offline';
        icon = Icons.cloud_off_rounded;
        break;
    }

    final label = AppStrings.get(labelKey, widget.languageCode);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withValues(alpha: 0.4), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showPulse && widget.status == TrackingStatus.live)
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) => Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: badgeColor.withValues(alpha: 0.6),
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Icon(icon, size: 13, color: badgeColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: badgeColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
