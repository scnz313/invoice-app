# Invoice - Professional Invoice Management App

A comprehensive, Airbnb-inspired invoice management application designed specifically for local merchants in India. This app provides category-specific features, modern UI/UX, and robust business functionality.

## 🎯 Features

### Core Features
- **Multi-Category Support**: 12 business categories with specialized fields
- **Airbnb-Inspired Design**: Clean, modern UI with smooth animations
- **SQLite Database**: Local storage with offline-first capability
- **Dynamic Forms**: Category-specific field generation
- **PDF Generation**: Professional invoice export
- **Analytics Dashboard**: Revenue tracking and business insights
- **Customer Management**: Complete customer database
- **Product Catalog**: Category-specific product management

### Business Categories
1. **Jewelry Store** - Metal type, karat, weight, making charges
2. **Grocery Store** - Barcode, unit type, expiry date, batch number
3. **Restaurant/Café** - Table number, order type, special instructions
4. **Clothing Store** - Size, color, brand, alteration charges
5. **Electronics Store** - Model number, serial number, warranty
6. **Hardware Store** - Specifications, material, grade, bulk pricing
7. **Pharmacy** - Medicine name, composition, prescription details
8. **Stationery Store** - Category, customer type, bulk discount
9. **Beauty Salon** - Service type, stylist, duration, products used
10. **Auto Parts Store** - Vehicle compatibility, part number, OEM type
11. **Bakery** - Category, custom order, delivery, dietary info
12. **Mobile Repair Shop** - Device model, IMEI, problem description

### Technical Features
- **Offline-First**: Works without internet connection
- **Data Export**: CSV, Excel, PDF formats
- **Backup & Restore**: Complete data backup functionality
- **Search & Filter**: Advanced search across all entities
- **Real-time Calculations**: Automatic tax and total calculations
- **Responsive Design**: Works on all screen sizes
- **Smooth Animations**: Airbnb-style transitions and effects

## 🏗️ Architecture

### Project Structure
```
lib/
├── models/
│   ├── business_category.dart
│   ├── enhanced_invoice.dart
│   └── settings.dart
├── providers/
│   ├── enhanced_invoice_provider.dart
│   └── settings_provider.dart
├── screens/
│   ├── welcome_screen.dart
│   ├── category_selection_screen.dart
│   ├── business_setup_screen.dart
│   ├── dashboard_screen.dart
│   └── invoice_creation_screen.dart
├── services/
│   └── database_service.dart
├── utils/
│   ├── theme.dart
│   └── logger.dart
├── widgets/
│   ├── airbnb_card.dart
│   ├── stat_card.dart
│   ├── recent_invoice_card.dart
│   ├── quick_action_button.dart
│   └── category_field_widget.dart
└── main.dart
```

### Technology Stack
- **Framework**: Flutter 3.0+
- **State Management**: Provider
- **Database**: SQLite (sqflite)
- **Charts**: fl_chart
- **PDF Generation**: pdf + printing
- **JSON Serialization**: json_annotation
- **UI Components**: Custom Airbnb-inspired widgets

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0 or higher
- Dart SDK 2.19 or higher
- Android Studio / VS Code
- Android SDK / Xcode (for mobile development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/invoice-app.git
   cd invoice-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code (for JSON serialization)**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Configuration

The app uses several configuration files:

- **pubspec.yaml**: Dependencies and assets
- **lib/utils/theme.dart**: Airbnb-inspired theme configuration
- **lib/models/business_category.dart**: Business category definitions

## 📱 User Flow

### 1. Onboarding
1. **Welcome Screen**: App introduction with animations
2. **Category Selection**: Choose from 12 business categories
3. **Business Setup**: 3-step business configuration

### 2. Main App
1. **Dashboard**: Overview with statistics and quick actions
2. **Invoice Creation**: Dynamic form with category-specific fields
3. **Customer Management**: Add and manage customers
4. **Product Catalog**: Category-specific product management
5. **Reports**: Analytics and business insights

## 🎨 Design System

### Airbnb-Inspired Theme
- **Primary Color**: #FF5A5F (Airbnb Red)
- **Secondary Colors**: 
  - Green: #00A699
  - Orange: #FFB400
  - Purple: #484848
- **Typography**: Roboto font family
- **Spacing**: 8px grid system
- **Border Radius**: 12px for cards, 8px for buttons

### UI Components
- **Cards**: Elevated with subtle shadows
- **Buttons**: Rounded corners with hover effects
- **Forms**: Clean input fields with validation
- **Animations**: Smooth transitions and micro-interactions

## 🗄️ Database Schema

### Tables
1. **invoices**: Main invoice data
2. **customers**: Customer information
3. **products**: Product catalog
4. **invoice_items**: Individual invoice items
5. **category_fields**: Dynamic category-specific fields
6. **business_settings**: Business configuration

### Key Features
- **Foreign Key Relationships**: Proper data integrity
- **Indexes**: Optimized for performance
- **JSON Storage**: Flexible category-specific data
- **Migration Support**: Version-based schema updates

## 🔧 Development

### Code Generation
The app uses code generation for JSON serialization:

```bash
# Generate code
flutter packages pub run build_runner build

# Watch for changes
flutter packages pub run build_runner watch
```

### Adding New Business Categories

1. **Update BusinessCategory enum** in `lib/models/business_category.dart`
2. **Add category-specific fields** in `CategoryFieldDefinitions`
3. **Update UI components** to handle new category
4. **Test thoroughly** with sample data

### Customization

#### Theme Customization
Edit `lib/utils/theme.dart` to modify:
- Colors
- Typography
- Spacing
- Border radius

#### Business Logic
- **Tax Calculations**: Modify in `EnhancedInvoiceProvider`
- **Validation Rules**: Update in form widgets
- **Export Formats**: Extend in provider classes

## 📊 Analytics & Reporting

### Dashboard Features
- **Revenue Charts**: Monthly revenue visualization
- **Statistics Cards**: Key business metrics
- **Recent Invoices**: Latest activity
- **Business Insights**: AI-powered recommendations

### Export Options
- **PDF**: Professional invoice format
- **CSV**: Data analysis and backup
- **Excel**: Advanced reporting
- **JSON**: API integration

## 🔒 Security & Privacy

### Data Protection
- **Local Storage**: All data stored locally
- **Encryption**: Optional data encryption
- **Backup Security**: Encrypted backup files
- **No Cloud Sync**: Complete privacy control

### Permissions
- **Storage**: For PDF/CSV export
- **Camera**: For barcode scanning (future)
- **Notifications**: For payment reminders

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Widget Tests
```bash
flutter test test/widget_test.dart
```

### Integration Tests
```bash
flutter drive --target=test_driver/app.dart
```

## 📦 Deployment

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

### Code Style
- Follow Flutter/Dart conventions
- Use meaningful variable names
- Add comments for complex logic
- Maintain consistent formatting

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Airbnb**: For design inspiration
- **Flutter Team**: For the amazing framework
- **Open Source Community**: For the excellent packages

## 📞 Support

For support and questions:
- **Email**: support@invoice-app.com
- **Documentation**: [docs.invoice-app.com](https://docs.invoice-app.com)
- **Issues**: [GitHub Issues](https://github.com/yourusername/invoice-app/issues)

## 🔄 Changelog

### Version 1.0.0
- Initial release
- 12 business categories
- Complete invoice management
- Dashboard with analytics
- PDF export functionality
- SQLite database
- Airbnb-inspired design

---

**Built with ❤️ for local merchants**
