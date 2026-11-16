import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/train_tracking_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/app_settings_provider.dart';
import 'constants/app_colors.dart';

import 'screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TrainTrackingProvider()),
      ],
      child: const RailTrackBdApp(),
    ),
  );
}

class RailTrackBdApp extends StatelessWidget {
  const RailTrackBdApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();

    return MaterialApp(
      title: 'RailTrack BD',
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBackground,
        primaryColor: AppColors.emeraldPrimary,
        colorScheme: const ColorScheme.light(
          primary: AppColors.emeraldPrimary,
          secondary: AppColors.goldAccent,
          surface: AppColors.lightSurface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.lightSurface,
          foregroundColor: AppColors.lightTextPrimary,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        primaryColor: AppColors.emeraldPrimary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.emeraldAccent,
          secondary: AppColors.goldAccent,
          surface: AppColors.darkSurface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkSurface,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
