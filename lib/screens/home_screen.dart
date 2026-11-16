import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/train_tracking_provider.dart';
import '../providers/app_settings_provider.dart';
import '../providers/auth_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../widgets/train_card.dart';
import 'live_tracking_screen.dart';
import 'train_search_screen.dart';
import 'favorites_screen.dart';
import 'alerts_screen.dart';
import 'admin_dashboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.emeraldPrimary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.train_rounded, color: AppColors.emeraldAccent, size: 22),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.get('app_name', lang),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  AppStrings.get('app_tagline', lang),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.darkTextSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Language Switcher (Bangla / English)
          TextButton(
            onPressed: () {
              settings.setLanguage(lang == 'en' ? 'bn' : 'en');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: Text(
                lang == 'en' ? 'বাংলা' : 'EN',
                style: const TextStyle(
                  color: AppColors.goldAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          // Destination Alarm Action
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.alarm_on_rounded, color: AppColors.goldAccent),
                if (tracking.alerts.any((a) => a.isActive && !a.isTriggered))
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.emeraldAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: AppStrings.get('alerts', lang),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AlertsScreen()),
              );
            },
          ),
          // Admin Dashboard quick action
          if (auth.isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.emeraldAccent),
              tooltip: 'Admin Console',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                );
              },
            ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Search & Filter Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TrainSearchScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.darkCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.darkBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, color: AppColors.darkTextSecondary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              AppStrings.get('search_hint', lang),
                              style: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 14),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.emeraldPrimary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.tune_rounded, size: 16, color: AppColors.emeraldAccent),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Filter Chips (All, Running, Delayed, On-Time)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(context, tracking, 'all', AppStrings.get('all_trains', lang)),
                        _buildFilterChip(context, tracking, 'running', AppStrings.get('running', lang)),
                        _buildFilterChip(context, tracking, 'delayed', AppStrings.get('delayed', lang)),
                        _buildFilterChip(context, tracking, 'on_time', AppStrings.get('on_time', lang)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Active Train Live Radar Card (Featured)
                  if (tracking.selectedTrain != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.radar_rounded, size: 18, color: AppColors.statusLive),
                            const SizedBox(width: 6),
                            Text(
                              AppStrings.get('live_trains', lang),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${tracking.filteredTrains.length} active',
                          style: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),

          // Train Cards List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final train = tracking.filteredTrains[index];
                  final isFav = tracking.isFavorite(train.id);

                  return TrainCard(
                    train: train,
                    languageCode: lang,
                    isFavorite: isFav,
                    onToggleFavorite: () => tracking.toggleFavorite(train.id),
                    onTrackPressed: () {
                      tracking.selectTrain(train);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LiveTrackingScreen(train: train),
                        ),
                      );
                    },
                  );
                },
                childCount: tracking.filteredTrains.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.emeraldPrimary.withValues(alpha: 0.3),
        selectedIndex: 0,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.train_rounded, color: Colors.white70),
            selectedIcon: const Icon(Icons.train_rounded, color: AppColors.emeraldAccent),
            label: AppStrings.get('all_trains', lang),
          ),
          NavigationDestination(
            icon: const Icon(Icons.search_rounded, color: Colors.white70),
            selectedIcon: const Icon(Icons.search_rounded, color: AppColors.emeraldAccent),
            label: AppStrings.get('track_now', lang),
          ),
          NavigationDestination(
            icon: const Icon(Icons.star_rounded, color: Colors.white70),
            selectedIcon: const Icon(Icons.star_rounded, color: AppColors.goldAccent),
            label: AppStrings.get('favorites', lang),
          ),
          NavigationDestination(
            icon: const Icon(Icons.alarm_on_rounded, color: Colors.white70),
            selectedIcon: const Icon(Icons.alarm_on_rounded, color: AppColors.goldAccent),
            label: AppStrings.get('alerts', lang),
          ),
          if (auth.isAdmin)
            NavigationDestination(
              icon: const Icon(Icons.dashboard_rounded, color: Colors.white70),
              selectedIcon: const Icon(Icons.dashboard_rounded, color: AppColors.emeraldAccent),
              label: AppStrings.get('admin_dashboard', lang),
            ),
        ],
        onDestinationSelected: (index) {
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const TrainSearchScreen()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()));
          } else if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AlertsScreen()));
          } else if (index == 4 && auth.isAdmin) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
          }
        },
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    TrainTrackingProvider provider,
    String key,
    String label,
  ) {
    final isSelected = provider.selectedFilter == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => provider.setFilter(key),
        backgroundColor: AppColors.darkCard,
        selectedColor: AppColors.emeraldPrimary,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.darkTextSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isSelected ? AppColors.emeraldAccent : AppColors.darkBorder,
          ),
        ),
      ),
    );
  }
}
