# Quick Setup Guide - Jewelry Invoice System

## 🚀 Getting Started

### Step 1: Generate Required Files
Since the system uses JSON serialization, you need to generate the required `.g.dart` files:

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Step 2: Update Main App
Update your `main.dart` to include the new providers:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/jewelry_invoice_provider.dart';
import 'providers/jewelry_client_provider.dart';
import 'providers/metal_rates_provider.dart';
import 'providers/enhanced_invoice_provider.dart';
import 'providers/client_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ClientProvider()),
        ChangeNotifierProvider(create: (_) => EnhancedInvoiceProvider()),
        ChangeNotifierProvider(create: (_) => JewelryClientProvider()),
        ChangeNotifierProvider(create: (_) => JewelryInvoiceProvider()),
        ChangeNotifierProvider(create: (_) => MetalRatesProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Jewelry Invoice Manager',
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const HomeScreen(),
            routes: {
              '/jewelry-invoice': (context) => const JewelryInvoiceFormScreen(),
            },
          );
        },
      ),
    );
  }
}
```

### Step 3: Default Metal Rates
The system will automatically create default metal rates on first run:

- **Gold 24K**: ₹6,300/g (selling), ₹6,200/g (buying)
- **Gold 22K**: ₹5,800/g (selling), ₹5,700/g (buying)
- **Gold 18K**: ₹4,800/g (selling), ₹4,700/g (buying)
- **Silver 999**: ₹80/g (selling), ₹75/g (buying)
- **Silver 925**: ₹75/g (selling), ₹70/g (buying)

### Step 4: Navigation Updates
Add jewelry invoice options to your navigation:

```dart
// In your home screen or main navigation
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const JewelryInvoiceFormScreen(),
      ),
    );
  },
  child: const Text('Create Jewelry Invoice'),
),
```

## 🎯 Key Features Ready to Use

### 1. Jewelry Items
- **Complete Metal Support**: Gold (14K, 18K, 22K, 24K), Silver (925, 999), Platinum
- **Automatic Calculations**: Metal value + wastage + making charges + stones
- **Stone Management**: Multiple stones per item with individual pricing
- **GST Compliance**: Built-in GST calculations with HSN codes

### 2. Customer Management
- **Customer Types**: Regular, VIP, Wholesale, Corporate
- **Loyalty System**: Automatic points (1 point per ₹100)
- **Credit Management**: Credit limits and outstanding tracking
- **Personal Data**: Birthdays, anniversaries, addresses

### 3. Invoice Types
- **Sale**: Standard jewelry sales
- **Exchange**: Old jewelry exchange with deductions
- **Estimate**: Price quotations
- **Repair**: Jewelry repair invoices
- **Custom**: Bespoke jewelry orders

### 4. Payment Processing
- **Multiple Methods**: Cash, Card, UPI, Net Banking, Cheque
- **Gold Exchange**: Old jewelry as payment
- **Partial Payments**: Installment support
- **Advance Payments**: Advance amount handling

## 📊 Daily Operations

### Metal Rates Management
1. Update rates daily through the Metal Rates section
2. Rates automatically apply to new items
3. Historical tracking for trend analysis

### Invoice Creation Process
1. **Basic Info**: Invoice details, client selection, dates
2. **Items**: Add jewelry items with complete specifications
3. **Exchange**: Add old jewelry exchange items
4. **Summary**: Review totals, add payments, finalize

### Customer Management
1. Add customers with complete details
2. Set credit limits and customer types
3. Track purchase history and loyalty points
4. Manage special occasions (birthdays, anniversaries)

## 🛠️ Customization Options

### Default Settings
- Update company information in settings
- Set default GST rates for your region
- Configure default making charges
- Set up terms and conditions

### Metal Rates
- Customize buying and selling rates
- Set different rates for different purities
- Configure wastage percentages
- Set making charges per gram

### Customer Categories
- Define VIP criteria and benefits
- Set wholesale pricing rules
- Configure loyalty point values
- Set credit limit policies

## 📱 User Interface

### Tabbed Interface
- **4-Tab Design**: Basic Info, Items, Exchange, Summary
- **Real-time Calculations**: Live total updates
- **Validation**: Comprehensive form validation
- **Error Handling**: User-friendly error messages

### Modern Design
- **Material Design**: Clean, modern interface
- **Responsive Layout**: Works on all screen sizes
- **Dark Mode Support**: Automatic theme switching
- **Accessibility**: Screen reader support

## 🔧 Troubleshooting

### Common Issues

1. **Build Errors**: Run `flutter clean` then `flutter pub get`
2. **Serialization Issues**: Run build_runner command again
3. **State Issues**: Check provider initialization in main.dart
4. **Navigation Issues**: Verify route definitions

### Data Issues
- **Missing Rates**: System will create defaults automatically
- **Missing Customers**: Import existing customer data
- **Calculation Issues**: Verify metal rates and GST settings

## 📈 Analytics and Reporting

### Built-in Analytics
- **Sales Reports**: Daily, weekly, monthly sales
- **Customer Analytics**: Purchase patterns, loyalty tracking
- **Inventory Reports**: Metal weight tracking by type
- **Financial Reports**: Revenue, profit margins, outstanding amounts

### Custom Reports
- **Top Customers**: Best customers by purchase amount
- **Popular Items**: Most sold jewelry categories
- **Payment Analysis**: Payment method preferences
- **Exchange Trends**: Exchange transaction patterns

## 🎯 Best Practices

### Daily Operations
1. Update metal rates every morning
2. Process all payments and exchanges
3. Review outstanding amounts
4. Update customer information

### Weekly Reviews
1. Analyze sales performance
2. Review customer loyalty programs
3. Check inventory levels
4. Update making charges if needed

### Monthly Tasks
1. Generate comprehensive reports
2. Review customer credit limits
3. Analyze profitability
4. Update terms and conditions

## 🔐 Security and Backup

### Data Protection
- Local storage encryption
- Regular automated backups
- Access control measures
- Audit trail maintenance

### Backup Strategy
- Daily local backups
- Weekly cloud backups (if configured)
- Monthly full system backups
- Quarterly disaster recovery tests

## 🎉 You're Ready!

Your comprehensive jewelry invoice system is now ready to use with all the features a jewelry shopkeeper needs:

✅ **Complete Jewelry Item Management**
✅ **Advanced Customer Management**
✅ **Daily Metal Rates Tracking**
✅ **Multiple Invoice Types**
✅ **Payment Processing**
✅ **Exchange Management**
✅ **Business Analytics**
✅ **GST Compliance**

Start by creating your first jewelry invoice and explore all the powerful features designed specifically for jewelry businesses!