import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/train_tracking_provider.dart';
import '../providers/app_settings_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../widgets/train_card.dart';
import 'live_tracking_screen.dart';

class TrainSearchScreen extends StatefulWidget {
  const TrainSearchScreen({super.key});

  @override
  State<TrainSearchScreen> createState() => _TrainSearchScreenState();
}

class _TrainSearchScreenState extends State<TrainSearchScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final tracking = Provider.of<TrainTrackingProvider>(context, listen: false);
    _searchController = TextEditingController(text: tracking.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch(TrainTrackingProvider tracking) {
    _searchController.clear();
    tracking.setSearchQuery('');
  }

  void _resetAllFilters(TrainTrackingProvider tracking) {
    _searchController.clear();
    tracking.resetFilters();
  }

  @override
  Widget build(BuildContext context) {
    final tracking = context.watch<TrainTrackingProvider>();
    final settings = context.watch<AppSettingsProvider>();
    final lang = settings.languageCode;
    final results = tracking.filteredTrains;

    // Sync controller if external change occurred
    if (_searchController.text != tracking.searchQuery && !FocusScope.of(context).hasFocus) {
      _searchController.text = tracking.searchQuery;
    }

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        title: Text(
          AppStrings.get('search_trains', lang),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          if (tracking.hasActiveFilters)
            TextButton.icon(
              onPressed: () => _resetAllFilters(tracking),
              icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.goldAccent),
              label: Text(
                AppStrings.get('clear_filters', lang),
                style: const TextStyle(
                  color: AppColors.goldAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar Container
          Container(
            color: AppColors.darkSurface,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  autofocus: tracking.searchQuery.isEmpty,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  onChanged: (val) => tracking.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: AppStrings.get('search_hint', lang),
                    hintStyle: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.emeraldAccent),
                    suffixIcon: tracking.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: Colors.white70, size: 20),
                            onPressed: () => _clearSearch(tracking),
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.darkCard,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.darkBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.darkBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.emeraldAccent, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // 2. Status Filter Chips (All, Running, Delayed, On-Time, Favorites)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildChip(
                        label: AppStrings.get('all_trains', lang),
                        icon: Icons.train_rounded,
                        isSelected: tracking.selectedStatusFilter == 'all',
                        onSelected: () => tracking.setStatusFilter('all'),
                      ),
                      const SizedBox(width: 8),
                      _buildChip(
                        label: AppStrings.get('running', lang),
                        icon: Icons.radar_rounded,
                        isSelected: tracking.selectedStatusFilter == 'running',
                        onSelected: () => tracking.setStatusFilter('running'),
                        activeColor: AppColors.statusLive,
                      ),
                      const SizedBox(width: 8),
                      _buildChip(
                        label: AppStrings.get('delayed', lang),
                        icon: Icons.schedule_rounded,
                        isSelected: tracking.selectedStatusFilter == 'delayed',
                        onSelected: () => tracking.setStatusFilter('delayed'),
                        activeColor: AppColors.goldAccent,
                      ),
                      const SizedBox(width: 8),
                      _buildChip(
                        label: AppStrings.get('on_time', lang),
                        icon: Icons.check_circle_outline_rounded,
                        isSelected: tracking.selectedStatusFilter == 'on_time',
                        onSelected: () => tracking.setStatusFilter('on_time'),
                      ),
                      const SizedBox(width: 8),
                      _buildChip(
                        label: AppStrings.get('filter_favorites', lang),
                        icon: Icons.star_rounded,
                        isSelected: tracking.selectedStatusFilter == 'favorites',
                        onSelected: () => tracking.setStatusFilter('favorites'),
                        activeColor: AppColors.goldAccent,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // 3. Train Type Filter Chips (All Types, Intercity, Mail/Express, Commuter)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildChip(
                        label: AppStrings.get('all_types', lang),
                        isSelected: tracking.selectedTrainTypeFilter == 'all',
                        onSelected: () => tracking.setTrainTypeFilter('all'),
                        isSecondary: true,
                      ),
                      const SizedBox(width: 8),
                      _buildChip(
                        label: AppStrings.get('type_intercity', lang),
                        isSelected: tracking.selectedTrainTypeFilter == 'intercity',
                        onSelected: () => tracking.setTrainTypeFilter('intercity'),
                        isSecondary: true,
                      ),
                      const SizedBox(width: 8),
                      _buildChip(
                        label: AppStrings.get('type_express', lang),
                        isSelected: tracking.selectedTrainTypeFilter == 'express',
                        onSelected: () => tracking.setTrainTypeFilter('express'),
                        isSecondary: true,
                      ),
                      const SizedBox(width: 8),
                      _buildChip(
                        label: AppStrings.get('type_commuter', lang),
                        isSelected: tracking.selectedTrainTypeFilter == 'commuter',
                        onSelected: () => tracking.setTrainTypeFilter('commuter'),
                        isSecondary: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 4. Sort & Result Count Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: AppColors.darkBackground,
              border: Border(
                bottom: BorderSide(color: AppColors.darkBorder, width: 0.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Result Count
                Text(
                  '${results.length} ${AppStrings.get('trains_found', lang)}',
                  style: const TextStyle(
                    color: AppColors.darkTextSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                // Sort Dropdown & Order Toggle
                Row(
                  children: [
                    Text(
                      '${AppStrings.get('sort_by', lang)}: ',
                      style: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 11),
                    ),
                    PopupMenuButton<String>(
                      initialValue: tracking.sortBy,
                      color: AppColors.darkCard,
                      shape: RoundedRectangleBorder(borderRadius: _roundedRadius(12)),
                      onSelected: (val) => tracking.setSortBy(val),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.darkSurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.darkBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getSortLabel(tracking.sortBy, lang),
                              style: const TextStyle(
                                color: AppColors.emeraldAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down_rounded, color: AppColors.emeraldAccent, size: 18),
                          ],
                        ),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'name',
                          child: Text(AppStrings.get('sort_name', lang), style: const TextStyle(color: Colors.white, fontSize: 13)),
                        ),
                        PopupMenuItem(
                          value: 'departure',
                          child: Text(AppStrings.get('sort_departure', lang), style: const TextStyle(color: Colors.white, fontSize: 13)),
                        ),
                        PopupMenuItem(
                          value: 'delay',
                          child: Text(AppStrings.get('sort_delay', lang), style: const TextStyle(color: Colors.white, fontSize: 13)),
                        ),
                        PopupMenuItem(
                          value: 'progress',
                          child: Text(AppStrings.get('sort_progress', lang), style: const TextStyle(color: Colors.white, fontSize: 13)),
                        ),
                      ],
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: Icon(
                        tracking.sortAscending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                        color: AppColors.emeraldAccent,
                        size: 18,
                      ),
                      tooltip: tracking.sortAscending
                          ? AppStrings.get('ascending', lang)
                          : AppStrings.get('descending', lang),
                      onPressed: () => tracking.toggleSortOrder(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 5. Results List or Empty State
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.darkCard,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.darkBorder),
                            ),
                            child: const Icon(
                              Icons.search_off_rounded,
                              size: 54,
                              color: AppColors.darkTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppStrings.get('no_trains_found', lang),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppStrings.get('no_trains_match_filters', lang),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.darkTextSecondary,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          if (tracking.searchQuery.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.darkSurface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '"${tracking.searchQuery}"',
                                style: const TextStyle(
                                  color: AppColors.goldAccent,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.emeraldPrimary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: _roundedRadius(12)),
                            ),
                            onPressed: () => _resetAllFilters(tracking),
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: Text(
                              AppStrings.get('clear_filters', lang),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final train = results[index];
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
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onSelected,
    Color activeColor = AppColors.emeraldAccent,
    bool isSecondary = false,
  }) {
    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSecondary ? 10 : 12,
          vertical: isSecondary ? 5 : 7,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.18)
              : AppColors.darkCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? activeColor
                : AppColors.darkBorder,
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? activeColor : AppColors.darkTextSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: isSecondary ? 11 : 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.darkTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSortLabel(String sortBy, String lang) {
    switch (sortBy) {
      case 'departure':
        return AppStrings.get('sort_departure', lang);
      case 'delay':
        return AppStrings.get('sort_delay', lang);
      case 'progress':
        return AppStrings.get('sort_progress', lang);
      case 'name':
      default:
        return AppStrings.get('sort_name', lang);
    }
  }

  BorderRadius _roundedRadius(double radius) => BorderRadius.circular(radius);
}
