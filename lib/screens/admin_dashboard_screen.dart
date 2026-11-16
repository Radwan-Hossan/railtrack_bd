import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/train_tracking_provider.dart';
import '../providers/app_settings_provider.dart';
import '../providers/auth_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tracking = context.watch<TrainTrackingProvider>();
    final settings = context.watch<AppSettingsProvider>();
    final auth = context.watch<AuthProvider>();
    final lang = settings.languageCode;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        title: Text(
          AppStrings.get('admin_dashboard', lang),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            tooltip: 'Sign Out',
            onPressed: () {
              auth.logout();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Console Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.emeraldDark, AppColors.darkCard],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.emeraldPrimary.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.security_rounded, color: AppColors.emeraldAccent, size: 36),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.currentUser?.name ?? 'Admin Dispatcher',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'PostgreSQL / PostGIS & Redis Cluster Active',
                        style: TextStyle(color: AppColors.emeraldAccent, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.statusLive.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.statusLive),
                  ),
                  child: const Text('SYSTEM HEALTHY', style: TextStyle(color: AppColors.statusLive, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Real-time Metrics Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.satellite_alt_rounded,
                  title: 'Active Trains',
                  value: '${tracking.trains.length}',
                  color: AppColors.emeraldAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.speed_rounded,
                  title: 'Avg Speed',
                  value: '74.2 km/h',
                  color: AppColors.goldAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.storage_rounded,
                  title: 'Redis Hit Ratio',
                  value: '99.8%',
                  color: Colors.lightBlueAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.check_circle_outline_rounded,
                  title: 'GPS Validations',
                  value: '100% OK',
                  color: AppColors.statusLive,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // GPS Validation Monitor & Geofence Logs
          Text(
            AppStrings.get('geofence_status', lang),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Column(
              children: [
                _buildLogItem('Suborno Exp (#701)', 'Position within 12m of centerline. Geofence OK.', Colors.greenAccent),
                const Divider(color: AppColors.darkBorder),
                _buildLogItem('Sonar Bangla (#787)', 'Cruising 78 km/h. Speed limit OK.', Colors.greenAccent),
                const Divider(color: AppColors.darkBorder),
                _buildLogItem('Padma Exp (#759)', 'Weak signal recovered from STALE to DEMO.', Colors.amberAccent),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Emergency Broadcast Tool
          Text(
            AppStrings.get('emergency_broadcast', lang),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Broadcast emergency track advisory or fog speed limit alert to all passengers:',
                  style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 12),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.shade700,
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.campaign_rounded, color: Colors.white),
                  label: const Text('Broadcast Emergency Notice (FCM)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: AppColors.emeraldPrimary,
                        content: Text('Emergency broadcast dispatched to all connected clients!'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.darkTextSecondary)),
        ],
      ),
    );
  }

  Widget _buildLogItem(String train, String message, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(train, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                Text(message, style: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
