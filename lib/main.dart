import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/settings_provider.dart';
import 'providers/enhanced_invoice_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/category_selection_screen.dart';
import 'screens/business_setup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/invoice_creation_screen.dart';
import 'screens/grocery_invoice_creation_screen.dart';
import 'screens/inventory_management_screen.dart';
import 'screens/grocery_product_management_screen.dart';
import 'screens/customer_loyalty_screen.dart';
import 'screens/grocery_reports_screen.dart';
import 'utils/theme.dart';
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

                return const DashboardScreen();
              },
            ),
            routes: {
              '/welcome': (context) => const WelcomeScreen(),
              '/category-selection': (context) => const CategorySelectionScreen(),
              '/business-setup': (context) => const BusinessSetupScreen(),
              '/dashboard': (context) => const DashboardScreen(),
              '/invoice-creation': (context) => const InvoiceCreationScreen(),
            },
          );
        },
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const PlaceholderScreen(title: 'Invoices', icon: Icons.receipt_long),
    const PlaceholderScreen(title: 'Customers', icon: Icons.people),
    const PlaceholderScreen(title: 'Products', icon: Icons.inventory_2),
    const PlaceholderScreen(title: 'Reports', icon: Icons.analytics),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.dashboard, 'Dashboard'),
                _buildNavItem(1, Icons.receipt_long, 'Invoices'),
                _buildNavItem(2, Icons.people, 'Customers'),
                _buildNavItem(3, Icons.inventory_2, 'Products'),
                _buildNavItem(4, Icons.analytics, 'Reports'),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InvoiceCreationScreen(),
            ),
          );
        },
        backgroundColor: AirbnbTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AirbnbTheme.primaryColor : Colors.grey[600],
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AirbnbTheme.bodyStyle.copyWith(
              fontSize: 12,
              color: isSelected ? AirbnbTheme.primaryColor : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AirbnbTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          title,
          style: AirbnbTheme.headlineStyle.copyWith(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: AirbnbTheme.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AirbnbTheme.headlineStyle.copyWith(
                fontSize: 24,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Coming Soon',
              style: AirbnbTheme.bodyStyle.copyWith(
                color: Colors.grey[500],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InvoiceCreationScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AirbnbTheme.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Create Invoice',
                style: AirbnbTheme.bodyStyle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
