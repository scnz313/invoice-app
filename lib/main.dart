import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'providers/enhanced_invoice_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/category_selection_screen.dart';
import 'screens/business_setup_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'theme/app_theme.dart';
import 'utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize logger (if needed)
  // Logger.initialize();
  
  runApp(const InvoiceApp());
}

class InvoiceApp extends StatelessWidget {
  const InvoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => EnhancedInvoiceProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: 'Invoice App',
            theme: AppTheme.lightTheme,
            home: FutureBuilder<bool>(
              future: settingsProvider.hasCompletedOnboardingAsync(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    backgroundColor: AppTheme.backgroundColor,
                    body: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      ),
                    ),
                  );
                }
                
                final hasCompletedOnboarding = snapshot.data ?? false;
                return hasCompletedOnboarding
                    ? const MainNavigationScreen()
                    : const WelcomeScreen();
              },
            ),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}


