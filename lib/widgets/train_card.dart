import 'package:flutter/material.dart';
import '../models/train.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import 'status_badge.dart';

class TrainCard extends StatelessWidget {
  final Train train;
  final String languageCode;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onTrackPressed;

  const TrainCard({
    super.key,
    required this.train,
    required this.languageCode,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onTrackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDelayed = train.delayMinutes > 5.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTrackPressed,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: Train Name & Status Badge & Favorite
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                train.localizedName(languageCode),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.darkSurface,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '#${train.trainNumber}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.emeraldAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${train.type.name.toUpperCase()} INTERCITY',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkTextSecondary,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        StatusBadge(
                          status: train.trackingStatus,
                          languageCode: languageCode,
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                            color: isFavorite ? AppColors.goldAccent : AppColors.darkTextSecondary,
                            size: 24,
                          ),
                          onPressed: onToggleFavorite,
                          tooltip: 'Favorite',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Route endpoints (Origin -> Destination)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            train.origin.localizedName(languageCode),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            train.departureTime,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.darkTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.arrow_forward_rounded, color: AppColors.emeraldAccent, size: 18),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            train.destination.localizedName(languageCode),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            train.arrivalTime,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.darkTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(color: AppColors.darkBorder, height: 24),
                // Live metrics row (Speed, Next Station, Delay)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.speed_rounded, size: 16, color: AppColors.emeraldAccent),
                        const SizedBox(width: 4),
                        Text(
                          '${train.currentSpeedKmh.toStringAsFixed(0)} km/h',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.fmd_good_outlined, size: 16, color: AppColors.goldAccent),
                        const SizedBox(width: 4),
                        Text(
                          'Next: ${train.nextStation.localizedName(languageCode)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDelayed ? Colors.redAccent.withValues(alpha: 0.15) : AppColors.emeraldPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isDelayed
                            ? '+${train.delayMinutes.toStringAsFixed(0)}m ${AppStrings.get('delayed', languageCode)}'
                            : AppStrings.get('on_time', languageCode),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDelayed ? Colors.redAccent : AppColors.emeraldAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
