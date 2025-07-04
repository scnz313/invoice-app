import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/client_provider.dart';
import 'providers/enhanced_invoice_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/theme_provider.dart';
import 'services/feature_flags.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/client_form_screen.dart';
import 'utils/logger.dart';

// Utility function to clear all app data
Future<void> clearAllAppData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Logger.info('All app data cleared successfully', 'DataClear');
  } catch (e) {
    Logger.error('Error clearing app data', 'DataClear', e);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize feature flags first
    await FeatureFlags.instance.initialize();

    runApp(const InvoiceApp());
  } catch (e, stack) {
    // Log and show fallback UI with data clearing option
    Logger.error('Initialization error', 'Main', e, stack);
    
    // If it's a type casting error, automatically clear data and retry
    if (e.toString().contains('type \'String\' is not a subtype of type \'List<dynamic>')) {
      Logger.warning('Type casting error detected, clearing app data...', 'Main');
      await clearAllAppData();
      
      // Try to restart the app
      try {
        await FeatureFlags.instance.initialize();
        runApp(const InvoiceApp());
        return;
      } catch (e2) {
        Logger.error('Failed to restart after clearing data', 'Main', e2);
      }
    }
    
    runApp(InitializationErrorApp(
      message: e.toString(),
      onClearData: clearAllAppData,
    ));
  }
}

class InvoiceApp extends StatelessWidget {
  const InvoiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ClientProvider()),
        ChangeNotifierProvider(create: (_) => EnhancedInvoiceProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Invoice Manager',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AppInitializer(),
            routes: {
              '/home': (context) => const HomeScreen(),
              '/add-client': (context) => const ClientFormScreen(),
            },
          );
        },
      ),
    );
  }
}

// Safe initializer that loads data properly without causing setState during build
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Delay initialization to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    try {
      // Get providers without listen to avoid setState during build
      final clientProvider = context.read<ClientProvider>();
      final invoiceProvider = context.read<EnhancedInvoiceProvider>();
      final settingsProvider = context.read<SettingsProvider>();
      final themeProvider = context.read<ThemeProvider>();
      
      // Initialize all providers
      await Future.wait([
        clientProvider.loadClients(),
        invoiceProvider.initialize(),
        settingsProvider.loadSettings(),
        themeProvider.loadThemeMode(),
      ]);
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      Logger.error('App initialization failed', 'AppInitializer', e);
      
      // If it's a type casting error, clear data and retry
      if (e.toString().contains('type \'String\' is not a subtype of type \'List<dynamic>') ||
          e.toString().contains('type \'String\' is not a subtype') ||
          e.toString().contains('List<dynamic>') ||
          e.toString().contains('FormatException') ||
          e.toString().contains('Invalid argument(s)')) {
        try {
          await clearAllAppData();
          
          // Retry initialization after clearing data
          final clientProvider = context.read<ClientProvider>();
          final invoiceProvider = context.read<EnhancedInvoiceProvider>();
          final settingsProvider = context.read<SettingsProvider>();
          final themeProvider = context.read<ThemeProvider>();
          
          await Future.wait([
            clientProvider.loadClients(),
            invoiceProvider.initialize(),
            settingsProvider.loadSettings(),
            themeProvider.loadThemeMode(),
          ]);
          
          if (mounted) {
            setState(() {
              _isInitialized = true;
            });
          }
          return;
        } catch (e2) {
          Logger.error('Failed to initialize even after clearing data', 'AppInitializer', e2);
        }
      }
      
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 80, color: Colors.red),
                    const SizedBox(height: 24),
                    const Text(
                      'Error loading data',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage?.contains('type \'String\' is not a subtype') == true
                          ? 'Data format issue detected. The app will clear corrupted data and restart.'
                          : _errorMessage ?? 'Unknown error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await clearAllAppData();
                          setState(() {
                            _hasError = false;
                            _isInitialized = false;
                          });
                          _initializeApp();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Retry',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'This will clear stored data and restart the app',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading...'),
            ],
          ),
        ),
      );
    }
    
    return const HomeScreen();
  }
}

class InitializationErrorApp extends StatelessWidget {
  final String message;
  final Future<void> Function()? onClearData;
  
  const InitializationErrorApp({
    super.key, 
    required this.message,
    this.onClearData,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'App Initialization Failed',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 24),
                if (onClearData != null) ...[
                  ElevatedButton(
                    onPressed: () async {
                      await onClearData!();
                      // Restart the app after clearing data
                      runApp(const InvoiceApp());
                    },
                    child: const Text('Clear App Data & Restart'),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This will clear all stored data and restart the app',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
