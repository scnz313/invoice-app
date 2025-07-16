import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'providers/enhanced_invoice_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/category_selection_screen.dart';
import 'screens/business_setup_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/invoice_creation_screen.dart';
import 'screens/grocery_invoice_creation_screen.dart';
import 'screens/inventory_management_screen.dart';
import 'screens/grocery_product_management_screen.dart';
import 'screens/customer_loyalty_screen.dart';
import 'screens/grocery_reports_screen.dart';
import 'theme/app_theme.dart';
import 'utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize logging
  Logger.initialize();
  
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
            title: 'Invoice - Professional Invoice Management',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              fontFamily: 'Roboto',
              useMaterial3: true,
            ),
            home: FutureBuilder<bool>(
              future: settingsProvider.isOnboardingComplete(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    backgroundColor: AirbnbTheme.backgroundColor,
                    body: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AirbnbTheme.primaryColor),
                      ),
                    ),
                  );
                }

                final isOnboardingComplete = snapshot.data ?? false;
                
                if (!isOnboardingComplete) {
                  return const WelcomeScreen();
                }

                return const MainNavigationScreen();
              },
            ),
            routes: {
              '/welcome': (context) => const WelcomeScreen(),
              '/category-selection': (context) => const CategorySelectionScreen(),
              '/business-setup': (context) => const BusinessSetupScreen(),
              '/dashboard': (context) => const MainNavigationScreen(),
              '/invoice-creation': (context) => const InvoiceCreationScreen(),
            },
          );
        },
      ),
    );
  }
}


