import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/app_settings_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<AppSettingsProvider>();
    final lang = settings.languageCode;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        title: Text(AppStrings.get('login', lang), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.emeraldPrimary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.train_rounded, size: 64, color: AppColors.emeraldAccent),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.get('app_name', lang),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                AppStrings.get('app_tagline', lang),
                style: const TextStyle(fontSize: 13, color: AppColors.darkTextSecondary),
              ),
              const SizedBox(height: 36),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emeraldPrimary,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.person_rounded, color: Colors.white),
                label: const Text(
                  'Continue as Passenger (যাত্রী)',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                onPressed: () {
                  auth.loginAsPassenger();
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 14),

              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.goldAccent),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.goldAccent),
                label: const Text(
                  'Sign In as Admin Dispatcher (কর্মকর্তা)',
                  style: TextStyle(color: AppColors.goldAccent, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                onPressed: () {
                  auth.loginAsAdmin();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
