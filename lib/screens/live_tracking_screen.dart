import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/train.dart';
import '../models/gps_point.dart';
import '../models/station.dart';
import '../models/alert.dart';
import '../providers/train_tracking_provider.dart';
import '../providers/app_settings_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../widgets/railway_map_widget.dart';
import '../widgets/status_badge.dart';
import '../widgets/speedometer_widget.dart';
import '../widgets/journey_progress_bar.dart';
import 'train_details_screen.dart';

class LiveTrackingScreen extends StatefulWidget {
  final Train train;

  const LiveTrackingScreen({super.key, required this.train});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  final GlobalKey<RailwayMapWidgetState> _mapKey = GlobalKey<RailwayMapWidgetState>();
  bool _isSatelliteMode = false;
  bool _showSimControls = false;

  void _showStationAlertSheet(BuildContext context, Train currentTrain, String lang) {
    final scheduleStations = currentTrain.schedule.map((s) => s.station).toList();
    final hasNextInSchedule = scheduleStations.any((s) => s.id == currentTrain.nextStation.id);
    String selectedStationId = hasNextInSchedule
        ? currentTrain.nextStation.id
        : (scheduleStations.isNotEmpty ? scheduleStations.first.id : currentTrain.destination.id);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            final dropdownStations = scheduleStations.isNotEmpty
                ? scheduleStations
                : <Station>[currentTrain.destination];

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications_active_rounded, color: AppColors.goldAccent),
                      const SizedBox(width: 8),
                      Text(
                        AppStrings.get('set_alert', lang),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Receive a push notification when ${currentTrain.nameEn} approaches your destination station:',
                    style: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    dropdownColor: AppColors.darkSurface,
                    initialValue: selectedStationId,
                    items: dropdownStations.map((st) {
                      return DropdownMenuItem<String>(
                        value: st.id,
                        child: Text(
                          st.localizedName(lang),
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          selectedStationId = val;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: AppStrings.get('next_station', lang),
                      labelStyle: const TextStyle(color: AppColors.emeraldAccent),
                      filled: true,
                      fillColor: AppColors.darkSurface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emeraldPrimary,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                    label: const Text('Activate Proximity Alarm', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      final targetStation = dropdownStations.firstWhere(
                        (s) => s.id == selectedStationId,
                        orElse: () => currentTrain.nextStation,
                      );
                      final newAlert = TrainAlert(
                        id: 'alert_${DateTime.now().millisecondsSinceEpoch}',
                        trainId: currentTrain.id,
                        trainName: '${currentTrain.nameEn} (${currentTrain.trainNumber})',
                        targetStationId: targetStation.id,
                        targetStationName: targetStation.nameEn,
                        targetStationNameBn: targetStation.nameBn,
                        notifyMinutesBefore: 10,
                        notifyDistanceKm: 10.0,
                        isTriggered: false,
                        isDemo: true,
                        createdAt: DateTime.now(),
                      );
                      context.read<TrainTrackingProvider>().addAlert(newAlert);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.emeraldPrimary,
                          content: Row(
                            children: [
                              const Icon(Icons.notifications_active, color: Colors.white),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text('${AppStrings.get('alert_saved', lang)} (${targetStation.localizedName(lang)})'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tracking = context.watch<TrainTrackingProvider>();
    final settings = context.watch<AppSettingsProvider>();
    final lang = settings.languageCode;

    // Use current train state from tracking provider for real-time live updates
    final currentTrain = tracking.trains.firstWhere(
      (t) => t.id == widget.train.id,
      orElse: () => widget.train,
    );

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          // 1. MapLibre-style Interactive Map Layer
          Positioned.fill(
            child: RailwayMapWidget(
              key: _mapKey,
              train: currentTrain,
              languageCode: lang,
              isSatelliteMode: _isSatelliteMode,
            ),
          ),

          // 2. Floating Top Header: Train Info & Live Status Badge
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.darkSurface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.darkBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currentTrain.localizedName(lang),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${currentTrain.origin.localizedName(lang)} ➔ ${currentTrain.destination.localizedName(lang)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.darkTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(
                    status: currentTrain.trackingStatus,
                    languageCode: lang,
                  ),
                ],
              ),
            ),
          ),

          // 3. Floating Map Controls (Right side buttons)
          Positioned(
            right: 16,
            top: MediaQuery.of(context).padding.top + 80,
            child: Column(
              children: [
                _buildMapButton(
                  icon: _isSatelliteMode ? Icons.map_rounded : Icons.satellite_alt_rounded,
                  tooltip: 'Toggle Layer',
                  onTap: () => setState(() => _isSatelliteMode = !_isSatelliteMode),
                ),
                const SizedBox(height: 8),
                _buildMapButton(
                  icon: Icons.my_location_rounded,
                  tooltip: 'Recenter',
                  onTap: () => _mapKey.currentState?.recenter(),
                ),
                const SizedBox(height: 8),
                _buildMapButton(
                  icon: Icons.add_rounded,
                  tooltip: 'Zoom In',
                  onTap: () => _mapKey.currentState?.zoomIn(),
                ),
                const SizedBox(height: 8),
                _buildMapButton(
                  icon: Icons.remove_rounded,
                  tooltip: 'Zoom Out',
                  onTap: () => _mapKey.currentState?.zoomOut(),
                ),
                const SizedBox(height: 8),
                _buildMapButton(
                  icon: Icons.tune_rounded,
                  tooltip: 'GPS Controls',
                  color: _showSimControls ? AppColors.goldAccent : Colors.white,
                  onTap: () => setState(() => _showSimControls = !_showSimControls),
                ),
              ],
            ),
          ),

          // 4. GPS Simulation Engine Controls Panel (Collapsible)
          if (_showSimControls)
            Positioned(
              left: 16,
              right: 16,
              top: MediaQuery.of(context).padding.top + 80,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.get('sim_controls', lang),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70, size: 18),
                          onPressed: () => setState(() => _showSimControls = false),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: tracking.isSimulating ? Colors.redAccent.withValues(alpha: 0.3) : AppColors.emeraldPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          ),
                          icon: Icon(tracking.isSimulating ? Icons.pause : Icons.play_arrow, size: 16),
                          label: Text(tracking.isSimulating ? 'Pause GPS' : 'Play GPS', style: const TextStyle(fontSize: 12)),
                          onPressed: () => tracking.toggleSimulation(),
                        ),
                        const SizedBox(width: 8),
                        const Text('Speed: ', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        DropdownButton<double>(
                          dropdownColor: AppColors.darkCard,
                          value: tracking.simSpeedFactor,
                          items: const [
                            DropdownMenuItem(value: 1.0, child: Text('1x', style: TextStyle(color: Colors.white))),
                            DropdownMenuItem(value: 2.0, child: Text('2x', style: TextStyle(color: Colors.white))),
                            DropdownMenuItem(value: 5.0, child: Text('5x', style: TextStyle(color: Colors.white))),
                          ],
                          onChanged: (val) {
                            if (val != null) tracking.setSpeedFactor(val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Test Status Indicators (LIVE / DEMO / STALE / OFFLINE):',
                      style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 11),
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildStatusButton(tracking, TrackingStatus.live, 'LIVE'),
                          _buildStatusButton(tracking, TrackingStatus.demo, 'DEMO'),
                          _buildStatusButton(tracking, TrackingStatus.stale, 'STALE'),
                          _buildStatusButton(tracking, TrackingStatus.offline, 'OFFLINE'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 5. Floating Bottom Telemetry & Navigation Drawer
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: BoxDecoration(
                color: AppColors.darkSurface.withValues(alpha: 0.96),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: AppColors.darkBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Real-time HUD Grid
                  Row(
                    children: [
                      // Speedometer
                      SpeedometerWidget(
                        currentSpeedKmh: currentTrain.currentSpeedKmh,
                      ),
                      const SizedBox(width: 14),
                      // Next Station & ETA Cards
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.darkCard,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.darkBorder),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.fmd_good_rounded, color: AppColors.goldAccent, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppStrings.get('next_station', lang),
                                          style: const TextStyle(fontSize: 10, color: AppColors.darkTextSecondary),
                                        ),
                                        Text(
                                          currentTrain.nextStation.localizedName(lang),
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${currentTrain.distanceToNextStationKm} km',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.emeraldAccent),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.darkCard,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.darkBorder),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppStrings.get('estimated_arrival', lang),
                                        style: const TextStyle(fontSize: 10, color: AppColors.darkTextSecondary),
                                      ),
                                      Text(
                                        currentTrain.estimatedArrivalNextStation,
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: currentTrain.delayMinutes > 5
                                          ? Colors.redAccent.withValues(alpha: 0.2)
                                          : AppColors.emeraldPrimary.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      currentTrain.delayMinutes > 5
                                          ? '+${currentTrain.delayMinutes.toStringAsFixed(0)}m ${AppStrings.get('delayed', lang)}'
                                          : AppStrings.get('no_delay', lang),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: currentTrain.delayMinutes > 5 ? Colors.redAccent : AppColors.emeraldAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Station-by-station journey timeline
                  JourneyProgressBar(
                    train: currentTrain,
                    languageCode: lang,
                  ),
                  const SizedBox(height: 12),

                  // Bottom Action Buttons: Set Alert & View Timetable
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.goldAccent),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.notifications_active_outlined, color: AppColors.goldAccent, size: 18),
                          label: Text(AppStrings.get('set_alert', lang), style: const TextStyle(color: AppColors.goldAccent, fontSize: 13)),
                          onPressed: () => _showStationAlertSheet(context, currentTrain, lang),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emeraldPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 18),
                          label: Text(AppStrings.get('timetable', lang), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TrainDetailsScreen(train: currentTrain),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 20),
        tooltip: tooltip,
        onPressed: onTap,
      ),
    );
  }

  Widget _buildStatusButton(TrainTrackingProvider tracking, TrackingStatus status, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
        onPressed: () => tracking.setTrackingStatus(status),
        child: Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70)),
      ),
    );
  }
}
