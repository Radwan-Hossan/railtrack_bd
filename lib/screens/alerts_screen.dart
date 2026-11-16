import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/train_tracking_provider.dart';
import '../providers/app_settings_provider.dart';
import '../models/alert.dart';
import '../models/train.dart';
import '../models/station.dart';
import '../data/bangladesh_railway_data.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../services/notification_service.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  StreamSubscription<TrainAlert>? _alertSub;

  @override
  void initState() {
    super.initState();
    // Listen for real-time triggered destination alarms
    _alertSub = NotificationService.onAlertTriggered.listen((alert) {
      if (!mounted) return;
      _showTriggeredAlarmDialog(alert);
    });
  }

  @override
  void dispose() {
    _alertSub?.cancel();
    super.dispose();
  }

  void _showTriggeredAlarmDialog(TrainAlert alert) {
    final settings = context.read<AppSettingsProvider>();
    final lang = settings.languageCode;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.darkSurface,
          shape: _roundedShape(18),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.goldAccent.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.alarm_on_rounded,
                  color: AppColors.goldAccent,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppStrings.get('alarm_dialog_title', lang),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.goldAccent.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.trainName,
                      style: const TextStyle(
                        color: AppColors.emeraldAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${lang == 'bn' && alert.targetStationNameBn.isNotEmpty ? alert.targetStationNameBn : alert.targetStationName} Station',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                sprintf(
                  AppStrings.get('alarm_dialog_msg', lang),
                  [
                    lang == 'bn' && alert.targetStationNameBn.isNotEmpty
                        ? alert.targetStationNameBn
                        : alert.targetStationName,
                    alert.notifyMinutesBefore,
                    alert.notifyDistanceKm.toStringAsFixed(1),
                  ],
                ),
                style: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 13),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 14, color: AppColors.goldAccent),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        AppStrings.get('demo_alarm_badge', lang),
                        style: const TextStyle(
                          color: AppColors.goldAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emeraldPrimary,
                shape: _roundedShape(10),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                AppStrings.get('dismiss', lang),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  String sprintf(String template, List<dynamic> arguments) {
    String result = template;
    for (final arg in arguments) {
      if (result.contains('%s')) {
        result = result.replaceFirst('%s', arg.toString());
      } else if (result.contains('%d')) {
        result = result.replaceFirst('%d', arg.toString());
      }
    }
    return result;
  }

  RoundedRectangleBorder _roundedShape(double r) =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(r));

  @override
  Widget build(BuildContext context) {
    final tracking = context.watch<TrainTrackingProvider>();
    final settings = context.watch<AppSettingsProvider>();
    final lang = settings.languageCode;
    final alerts = tracking.alerts;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        title: Text(
          AppStrings.get('destination_alarm', lang),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alarm_rounded, color: AppColors.emeraldAccent),
            tooltip: AppStrings.get('create_alarm', lang),
            onPressed: () => _openCreateAlarmSheet(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner introducing Smart Destination Alarm
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.emeraldPrimary.withValues(alpha: 0.3),
                  AppColors.darkCard,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.emeraldAccent.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.emeraldPrimary.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: AppColors.emeraldAccent,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.get('destination_alarm', lang),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppStrings.get('destination_alarm_desc', lang),
                        style: const TextStyle(
                          color: AppColors.darkTextSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Demo Mode Transparency Disclaimer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, size: 16, color: AppColors.goldAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppStrings.get('demo_alarm_notice', lang),
                    style: const TextStyle(
                      color: AppColors.darkTextSecondary,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // List Header with count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppStrings.get('alerts', lang)} (${alerts.length})',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.add, size: 18, color: AppColors.emeraldAccent),
                label: Text(
                  AppStrings.get('set_alert', lang),
                  style: const TextStyle(
                    color: AppColors.emeraldAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                onPressed: () => _openCreateAlarmSheet(context),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Empty state
          if (alerts.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: Column(
                children: [
                  const Icon(Icons.alarm_off_rounded, size: 48, color: AppColors.darkTextSecondary),
                  const SizedBox(height: 14),
                  Text(
                    AppStrings.get('no_alerts', lang),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emeraldPrimary,
                      shape: _roundedShape(10),
                    ),
                    icon: const Icon(Icons.add_alarm, color: Colors.white, size: 18),
                    label: Text(
                      AppStrings.get('create_alarm', lang),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => _openCreateAlarmSheet(context),
                  ),
                ],
              ),
            )
          else
            ...alerts.map((alert) {
              final metrics = tracking.getProximityForAlert(alert);
              final distKm = metrics['distanceKm'] ?? 0.0;
              final mins = metrics['remainingMinutes'] ?? 0.0;

              return _buildAlertCard(
                context: context,
                tracking: tracking,
                alert: alert,
                distanceKm: distKm,
                remainingMinutes: mins,
                lang: lang,
              );
            }),
        ],
      ),
    );
  }

  Widget _buildAlertCard({
    required BuildContext context,
    required TrainTrackingProvider tracking,
    required TrainAlert alert,
    required double distanceKm,
    required double remainingMinutes,
    required String lang,
  }) {
    final isTriggered = alert.isTriggered;
    final isActive = alert.isActive;

    Color statusColor;
    String statusText;
    if (isTriggered) {
      statusColor = AppColors.goldAccent;
      statusText = AppStrings.get('alarm_triggered', lang);
    } else if (isActive) {
      statusColor = AppColors.emeraldAccent;
      statusText = AppStrings.get('alarm_active', lang);
    } else {
      statusColor = AppColors.darkTextSecondary;
      statusText = AppStrings.get('alarm_inactive', lang);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isTriggered
              ? AppColors.goldAccent.withValues(alpha: 0.6)
              : isActive
                  ? AppColors.emeraldAccent.withValues(alpha: 0.3)
                  : AppColors.darkBorder,
          width: isTriggered ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Train name + Status switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.train_rounded, color: AppColors.emeraldAccent, size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        alert.trainName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: alert.isActive,
                activeThumbColor: AppColors.emeraldAccent,
                onChanged: (val) {
                  tracking.toggleAlertActive(alert.id, val);
                },
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Destination Station details
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: AppColors.goldAccent, size: 18),
              const SizedBox(width: 8),
              Text(
                '${AppStrings.get('target_station', lang)}: ',
                style: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 13),
              ),
              Expanded(
                child: Text(
                  lang == 'bn' && alert.targetStationNameBn.isNotEmpty
                      ? alert.targetStationNameBn
                      : alert.targetStationName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Proximity Metrics Pills
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      AppStrings.get('distance_remaining', lang),
                      style: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${distanceKm.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Container(width: 1, height: 26, color: AppColors.darkBorder),
                Column(
                  children: [
                    Text(
                      AppStrings.get('eta_remaining', lang),
                      style: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '~${remainingMinutes.toStringAsFixed(0)} mins',
                      style: const TextStyle(
                        color: AppColors.emeraldAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Container(width: 1, height: 26, color: AppColors.darkBorder),
                Column(
                  children: [
                    Text(
                      AppStrings.get('alarm_timing', lang),
                      style: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${alert.notifyMinutesBefore} mins',
                      style: const TextStyle(
                        color: AppColors.goldAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Status & Actions Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isTriggered
                          ? Icons.check_circle_rounded
                          : isActive
                              ? Icons.alarm_rounded
                              : Icons.pause_circle_outline_rounded,
                      size: 13,
                      color: statusColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              Row(
                children: [
                  // Test trigger button for manual demo testing
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      side: BorderSide(color: AppColors.emeraldAccent.withValues(alpha: 0.5)),
                      shape: _roundedShape(8),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 16, color: AppColors.emeraldAccent),
                    label: Text(
                      AppStrings.get('test_trigger', lang),
                      style: const TextStyle(
                        color: AppColors.emeraldAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      tracking.testTriggerAlert(alert.id);
                    },
                  ),

                  const SizedBox(width: 6),

                  // Delete button
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                    tooltip: AppStrings.get('delete_alarm', lang),
                    onPressed: () {
                      tracking.deleteAlert(alert.id);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openCreateAlarmSheet(BuildContext context) {
    final tracking = context.read<TrainTrackingProvider>();
    final settings = context.read<AppSettingsProvider>();
    final lang = settings.languageCode;

    Train selectedTrain = tracking.selectedTrain ?? tracking.trains.first;
    Station selectedStation = selectedTrain.destination;
    int selectedMinutes = 10;
    double selectedKm = 10.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            final availableStations = BangladeshRailwayData.allStations;

            return Padding(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 18,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.get('create_alarm', lang),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.darkBorder),
                  const SizedBox(height: 8),

                  // Step 1: Select Train
                  Text(
                    AppStrings.get('select_train', lang),
                    style: const TextStyle(
                      color: AppColors.darkTextSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.darkBorder),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        dropdownColor: AppColors.darkCard,
                        value: selectedTrain.id,
                        items: tracking.trains.map((train) {
                          return DropdownMenuItem<String>(
                            value: train.id,
                            child: Text(
                              '${train.nameEn} (${train.trainNumber})',
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            final match = tracking.trains.firstWhere((t) => t.id == val);
                            setModalState(() {
                              selectedTrain = match;
                              selectedStation = match.destination;
                            });
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Step 2: Select Target Station
                  Text(
                    AppStrings.get('target_station', lang),
                    style: const TextStyle(
                      color: AppColors.darkTextSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.darkBorder),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        dropdownColor: AppColors.darkCard,
                        value: selectedStation.id,
                        items: availableStations.map((st) {
                          return DropdownMenuItem<String>(
                            value: st.id,
                            child: Text(
                              '${st.nameEn} (${st.nameBn})',
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            final match = availableStations.firstWhere((s) => s.id == val);
                            setModalState(() {
                              selectedStation = match;
                            });
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Step 3: Select Notification Timing (5 mins, 10 mins, 15 mins)
                  Text(
                    AppStrings.get('alarm_timing', lang),
                    style: const TextStyle(
                      color: AppColors.darkTextSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [5, 10, 15].map((mins) {
                      final isSelected = selectedMinutes == mins;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedMinutes = mins;
                              selectedKm = mins * 1.0;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.emeraldPrimary
                                  : AppColors.darkCard,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.emeraldAccent
                                    : AppColors.darkBorder,
                              ),
                            ),
                            alignment: Alignment.center,//solve it 
                            child: Text(
                              '$mins ${lang == 'bn' ? 'মিনিট' : 'mins'}',
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppColors.darkTextSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Save Alarm Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emeraldPrimary,
                        shape: _roundedShape(12),
                      ),
                      onPressed: () {
                        final newAlert = TrainAlert(
                          id: 'alert_${DateTime.now().millisecondsSinceEpoch}',
                          trainId: selectedTrain.id,
                          trainName: '${selectedTrain.nameEn} (${selectedTrain.trainNumber})',
                          targetStationId: selectedStation.id,
                          targetStationName: selectedStation.nameEn,
                          targetStationNameBn: selectedStation.nameBn,
                          notifyMinutesBefore: selectedMinutes,
                          notifyDistanceKm: selectedKm,
                          isTriggered: false,
                          isDemo: true,
                          createdAt: DateTime.now(),
                        );

                        tracking.addAlert(newAlert);
                        Navigator.pop(ctx);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.emeraldPrimary,
                            content: Text(
                              AppStrings.get('alert_saved', lang),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        AppStrings.get('set_alert', lang),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
