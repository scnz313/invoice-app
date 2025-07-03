# Minimalist Invoice App

A clean, responsive, and user-friendly invoice application built with Flutter. This app follows minimalist design principles while providing powerful functionality for managing invoices and clients.

## 🌟 Features

### Core Functionality
- **Create & Manage Invoices**: Quickly create, edit, and manage invoices with an intuitive interface
- **Client Management**: Simple address book to store and manage client information
- **Itemized Lists**: Add multiple line items with automatic calculations
- **Tax & Discount Options**: Flexible pricing with tax percentages and discount amounts
- **Status Tracking**: Track invoices as Draft, Sent, Paid, or Overdue
- **PDF Export**: Generate professional PDF invoices for sharing and printing
- **Responsive Design**: Optimized for phones, tablets, and desktop environments

### Technical Features
- **Local Storage**: All data is stored locally using SharedPreferences
- **State Management**: Uses Provider for efficient state management
- **JSON Serialization**: Automatic JSON conversion for data persistence
- **PDF Generation**: Professional PDF creation with detailed invoice layouts
- **Search & Filter**: Find invoices and clients quickly
- **Sample Data**: Load sample data for testing and demonstration

## 🏗️ Architecture

### Project Structure
```
lib/
├── models/              # Data models
│   ├── client.dart
│   ├── invoice.dart
│   └── invoice_item.dart
├── providers/           # State management
│   ├── client_provider.dart
│   └── invoice_provider.dart
├── screens/             # UI screens
│   ├── home_screen.dart
│   ├── invoice_list_screen.dart
│   ├── invoice_form_screen.dart
│   ├── client_list_screen.dart
│   └── client_form_screen.dart
├── widgets/             # Reusable widgets
│   └── dashboard_card.dart
├── services/            # External services
│   └── pdf_service.dart
├── utils/               # Utilities
│   └── sample_data.dart
└── main.dart           # App entry point
```

### Dependencies
- **provider**: State management
- **pdf**: PDF generation
- **printing**: PDF sharing and printing
- **shared_preferences**: Local data storage
- **uuid**: Unique ID generation
- **json_annotation**: JSON serialization

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- An IDE (VS Code or Android Studio recommended)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd invoice_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate JSON serialization code**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Development Setup

1. **For VS Code users**:
   - Install the Flutter extension
   - Open the project folder
   - Use F5 to run in debug mode

2. **For Android Studio users**:
   - Install the Flutter plugin
   - Open the project
   - Use the run button to start the app

## 📱 Usage

### Getting Started
1. Launch the app - you'll see the Dashboard
2. Tap "Load Sample Data" to populate the app with example data
3. Navigate between Dashboard, Invoices, and Clients using the bottom navigation

### Creating Your First Invoice
1. Go to the Invoices tab
2. Tap the + button
3. Select a client (or create a new one)
4. Add items with descriptions, quantities, and prices
5. Set tax percentage and discount if needed
6. Add notes and save the invoice

### Managing Clients
1. Go to the Clients tab
2. Tap + to add new clients
3. Fill in name, email, address, and phone
4. Use the search to find clients quickly
5. Tap on a client to view details or create an invoice

### Working with Invoices
- **View Details**: Tap any invoice to see full details
- **Filter**: Use the filter button to show specific statuses
- **Search**: Use the search bar to find invoices by number or client
- **Export PDF**: From invoice details, tap "Share PDF" or "Print"
- **Mark as Paid**: Change invoice status from the details screen

## 🎨 Design Principles

### Minimalist UI
- Clean, single-column layouts
- Professional color scheme (Blue primary with neutral grays)
- Consistent spacing and typography
- Material Design 3 components

### User Experience
- Intuitive navigation with bottom tabs
- Quick actions via floating action buttons
- Contextual menus for item actions
- Progressive disclosure of information
- Responsive layouts for all screen sizes

### Performance
- Efficient state management with Provider
- Local data storage for offline access
- Lazy loading of lists
- Optimized PDF generation

## 🔧 Customization

### Changing the Theme
Edit `lib/main.dart` to modify colors, fonts, and styling:

```dart
theme: ThemeData(
  primarySwatch: Colors.blue, // Change primary color
  // ... other theme properties
),
```

### Adding Your Company Info
Edit `lib/services/pdf_service.dart` to add your company details:

```dart
pw.Text(
  'Your Company Name', // Replace with your company name
  // ... styling
),
```

### Extending Functionality
- Add new fields to models in `lib/models/`
- Create new providers for additional state management
- Add new screens for extra features
- Implement cloud storage by modifying providers

## 🧪 Testing

### Running Tests
```bash
flutter test
```

### Sample Data
The app includes sample data generation for testing:
- 3 sample clients with realistic information
- 4 sample invoices with different statuses
- Variety of items, taxes, and discounts

## 🚀 Building for Production

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

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Support

If you encounter any issues or have questions, please create an issue in the repository.

---

Built with ❤️ using Flutter
