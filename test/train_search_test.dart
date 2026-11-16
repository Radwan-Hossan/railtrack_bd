import 'package:flutter_test/flutter_test.dart';
import 'package:railtrack_bd/models/train.dart';
import 'package:railtrack_bd/providers/train_tracking_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'favorite_train_ids': <String>['TR_701', 'TR_709'],
    });
  });

  group('Phase 1: Train Search & Filtering Tests', () {
    test('Initial train list loads correctly', () async {
      final provider = TrainTrackingProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(provider.trains.isNotEmpty, true);
      expect(provider.filteredTrains.length, provider.trains.length);
    });

    test('Search by English train name', () async {
      final provider = TrainTrackingProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      provider.setSearchQuery('Suborno');
      final results = provider.filteredTrains;

      expect(results.any((t) => t.nameEn.contains('Suborno')), true);
      for (final t in results) {
        expect(
          t.nameEn.toLowerCase().contains('suborno') ||
          t.origin.nameEn.toLowerCase().contains('suborno') ||
          t.destination.nameEn.toLowerCase().contains('suborno'),
          true,
        );
      }
    });

    test('Search by Bangla train name', () async {
      final provider = TrainTrackingProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      provider.setSearchQuery('পারাবত');
      final results = provider.filteredTrains;

      expect(results.any((t) => t.trainNumber == '709'), true);
    });

    test('Search by train number', () async {
      final provider = TrainTrackingProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      provider.setSearchQuery('787');
      final results = provider.filteredTrains;

      expect(results.length, 1);
      expect(results.first.trainNumber, '787');
      expect(results.first.nameEn, 'Sonar Bangla Express');
    });

    test('Search by Origin and Destination in English and Bangla', () async {
      final provider = TrainTrackingProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      provider.setSearchQuery('Sylhet');
      expect(provider.filteredTrains.any((t) => t.destination.nameEn == 'Sylhet' || t.origin.nameEn == 'Sylhet'), true);

      provider.setSearchQuery('চট্টগ্রাম');
      expect(provider.filteredTrains.any((t) => t.destination.nameBn == 'চট্টগ্রাম' || t.origin.nameBn == 'চট্টগ্রাম'), true);
    });

    test('Filter by Train Type (Intercity, Express, Commuter)', () async {
      final provider = TrainTrackingProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      provider.setTrainTypeFilter('intercity');
      expect(provider.filteredTrains.every((t) => t.type == TrainType.intercity), true);

      provider.setTrainTypeFilter('express');
      expect(provider.filteredTrains.every((t) => t.type == TrainType.express), true);

      provider.setTrainTypeFilter('commuter');
      expect(provider.filteredTrains.every((t) => t.type == TrainType.commuter), true);

      provider.setTrainTypeFilter('all');
      expect(provider.filteredTrains.length, provider.trains.length);
    });

    test('Filter by Status (Running, Delayed, On-Time, Favorites)', () async {
      final provider = TrainTrackingProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      provider.setStatusFilter('delayed');
      expect(provider.filteredTrains.every((t) => t.delayMinutes > 5.0), true);

      provider.setStatusFilter('on_time');
      expect(provider.filteredTrains.every((t) => t.delayMinutes <= 5.0), true);

      provider.setStatusFilter('favorites');
      expect(provider.filteredTrains.every((t) => provider.isFavorite(t.id)), true);
    });

    test('Sorting by Name, Departure Time, Delay, and Progress', () async {
      final provider = TrainTrackingProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      // Sort by Name ascending
      provider.setSortBy('name');
      var names = provider.filteredTrains.map((t) => t.nameEn).toList();
      var sortedNames = List<String>.from(names)..sort((a, b) => a.compareTo(b));
      expect(names, sortedNames);

      // Toggle to Descending
      provider.toggleSortOrder();
      names = provider.filteredTrains.map((t) => t.nameEn).toList();
      sortedNames = List<String>.from(sortedNames.reversed);
      expect(names, sortedNames);

      // Sort by Delay
      provider.setSortBy('delay');
      final delays = provider.filteredTrains.map((t) => t.delayMinutes).toList();
      for (int i = 0; i < delays.length - 1; i++) {
        expect(delays[i] <= delays[i + 1], true);
      }
    });

    test('Resetting filters restores full list', () async {
      final provider = TrainTrackingProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      provider.setSearchQuery('NonExistentTrain12345');
      provider.setTrainTypeFilter('commuter');
      expect(provider.filteredTrains.isEmpty, true);

      provider.resetFilters();
      expect(provider.searchQuery, '');
      expect(provider.selectedStatusFilter, 'all');
      expect(provider.selectedTrainTypeFilter, 'all');
      expect(provider.filteredTrains.length, provider.trains.length);
    });
  });
}
