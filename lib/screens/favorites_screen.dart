import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/train_tracking_provider.dart';
import '../providers/app_settings_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../widgets/train_card.dart';
import 'live_tracking_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tracking = context.watch<TrainTrackingProvider>();
    final settings = context.watch<AppSettingsProvider>();
    final lang = settings.languageCode;
    final favTrains = tracking.favoriteTrains;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        title: Text(
          AppStrings.get('favorites', lang),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: favTrains.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_border_rounded, size: 64, color: AppColors.goldAccent),
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.get('no_favorites', lang),
                    style: const TextStyle(color: AppColors.darkTextSecondary),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favTrains.length,
              itemBuilder: (context, index) {
                final train = favTrains[index];
                return TrainCard(
                  train: train,
                  languageCode: lang,
                  isFavorite: true,
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
    );
  }
}
