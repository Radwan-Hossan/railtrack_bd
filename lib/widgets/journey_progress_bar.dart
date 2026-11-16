import 'package:flutter/material.dart';
import '../models/train.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

class JourneyProgressBar extends StatelessWidget {
  final Train train;
  final String languageCode;

  const JourneyProgressBar({
    super.key,
    required this.train,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.get('journey_progress', languageCode),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.emeraldPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${train.journeyProgressPercentage.toStringAsFixed(0)}% Completed',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.emeraldAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress line
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (train.journeyProgressPercentage / 100.0).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.darkBorder,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.emeraldAccent),
            ),
          ),
          const SizedBox(height: 16),
          // Station milestones
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: train.schedule.map((stop) {
              final isPassed = stop.distanceKmFromOrigin <
                  (train.totalDistanceKm * (train.journeyProgressPercentage / 100.0));
              final isNext = stop.station.id == train.nextStation.id;

              Color dotColor = AppColors.darkBorder;
              if (isNext) {
                dotColor = AppColors.goldAccent;
              } else if (isPassed) {
                dotColor = AppColors.emeraldAccent;
              }

              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: isNext ? 14 : 10,
                      height: isNext ? 14 : 10,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                        border: isNext
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      stop.station.localizedName(languageCode),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                        color: isNext
                            ? AppColors.goldAccent
                            : (isPassed ? Colors.white70 : AppColors.darkTextSecondary),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stop.scheduledArrival,
                      style: TextStyle(
                        fontSize: 9,
                        color: isNext ? AppColors.goldAccent : AppColors.darkTextSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
