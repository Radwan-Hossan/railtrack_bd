import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/train.dart';
import '../providers/app_settings_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

class TrainDetailsScreen extends StatelessWidget {
  final Train train;

  const TrainDetailsScreen({super.key, required this.train});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final lang = settings.languageCode;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        title: Text(
          '${train.localizedName(lang)} (#${train.trainNumber})',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Meta Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Route Distance: ${train.totalDistanceKm} km', style: const TextStyle(color: Colors.white70)),
                    Text('Off-Day: ${train.offDay}', style: const TextStyle(color: AppColors.goldAccent, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Coaches: ${train.totalCoaches}', style: const TextStyle(color: Colors.white70)),
                    Text('Classes: ${train.coachClasses.join(', ')}', style: const TextStyle(color: AppColors.emeraldAccent)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Station Timetable Header
          Text(
            AppStrings.get('timetable', lang),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),

          ...train.schedule.map((stop) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.emeraldPrimary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'P${stop.platform}',
                        style: const TextStyle(color: AppColors.emeraldAccent, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stop.station.localizedName(lang),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          '${stop.distanceKmFromOrigin} km from origin',
                          style: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Arr: ${stop.scheduledArrival}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      Text('Dep: ${stop.scheduledDeparture}', style: const TextStyle(color: AppColors.emeraldAccent, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
