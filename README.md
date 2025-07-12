# Invoice App - Professional Invoice Management for Local Merchants

A modern, Airbnb-inspired invoice management application designed specifically for local merchants. The app automatically adapts its features based on the business category selected by the user.

## 🎨 Design Philosophy

This app follows Airbnb's design principles:
- **Clean, modern UI** with generous white space
- **Card-based layouts** with subtle shadows and rounded corners
- **Smooth animations** and micro-interactions
- **Consistent color palette** using Airbnb's signature colors
- **Professional typography** with clear hierarchy

## 🏪 Business Categories

The app supports 12 different business categories, each with tailored features:

### 1. Jewelry Store
- Metal type tracking (Gold, Silver, Platinum)
- Karat/Purity fields
- Weight in grams
- Making charges
- Stone details
- Hallmark certification
- GST calculation (3%)

### 2. Grocery Store
- Barcode scanning capability
- Quantity and unit types (kg, grams, pieces, liters)
- Expiry date tracking
- Batch number management
- Category-wise organization
- Loyalty points system

### 3. Restaurant/Café
- Menu item selection
- Table number tracking
- Order types (Dine-in, Takeaway, Delivery)
- Special instructions
- Split billing
- Tip calculation
- Kitchen order token (KOT)

### 4. Clothing Store
- Size and color specifications
- Brand details
- Season/Collection information
- Return policy terms
- Alteration charges
- Exchange policy details

### 5. Electronics Store
- Model number and specifications
- Warranty period and terms
- Serial number tracking
- Installation charges
- Extended warranty options
- Service center details

### 6. Hardware Store
- Product specifications
- Quantity in different units
- Brand and grade information
- Bulk pricing options
- Project-based invoicing
- Installation services

### 7. Pharmacy
- Medicine name and composition
- Dosage information
- Prescription number
- Doctor's name
- Batch number and expiry
- Insurance claim support

### 8. Stationery Store
- Product categories
- Bulk quantity discounts
- Academic/Corporate customer types
- Seasonal pricing
- Gift wrapping options
- Educational institution discounts

### 9. Beauty Salon
- Service type selection
- Stylist/Therapist assignment
- Service duration
- Product used details
- Package deals
- Membership discounts

### 10. Auto Parts Store
- Vehicle compatibility details
- Part number and specifications
- OEM/Aftermarket classification
- Warranty information
- Core exchange values
- Bulk pricing for garages

### 11. Bakery
- Product categories
- Custom order details
- Delivery date and time
- Special dietary information
- Decoration charges
- Advance booking system

### 12. Mobile Repair Shop
- Device model and IMEI
- Problem description
- Parts replaced
- Labor charges
- Warranty on repair
- Pickup/delivery options

## ✨ Key Features

### 🎯 Category-Specific Features
- **Dynamic form fields** based on business type
- **Custom tax rates** for different industries
- **Specialized workflows** for each business category
- **Industry-specific terminology** and labels

### 🎨 Modern UI/UX
- **Airbnb-inspired design** with signature colors
- **Smooth animations** and transitions
- **Responsive layout** for all screen sizes
- **Dark mode support**
- **Accessibility features**

### 📱 Core Functionality
- **Invoice creation and management**
- **Customer database**
- **Product/service catalog**
- **Payment tracking**
- **Reports and analytics**
- **PDF generation**
- **Data export** (CSV, Excel)

### 🔧 Technical Features
- **Offline-first** architecture
- **Local SQLite database**
- **Real-time calculations**
- **Search and filtering**
- **Data backup and restore**
- **Multi-language support**

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Android/iOS device or emulator

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

3. **Run the app**
   ```bash
   flutter run
   ```

### First Time Setup

1. **Welcome Screen**: The app starts with a beautiful welcome screen
2. **Category Selection**: Choose your business category from 12 options
3. **Business Setup**: Complete a 3-step setup process:
   - Basic information (business name, owner, logo)
   - Contact details (phone, email, address)
   - Business details (GST, PAN, category-specific info)

## 🎨 Design System

### Color Palette
- **Rausch** (#FF5A5F) - Primary red
- **Babu** (#00A699) - Primary teal
- **Arches** (#FC642D) - Orange
- **Hof** (#484848) - Dark gray
- **Foggy** (#767676) - Medium gray
- **Snow** (#FFFFFF) - White
- **Ghost** (#F7F7F7) - Light background

### Typography
- **Font Family**: Roboto (system font)
- **Headline 1**: 32px, Bold
- **Headline 2**: 28px, Bold
- **Headline 3**: 24px, Semi-bold
- **Headline 4**: 20px, Semi-bold
- **Body 1**: 16px, Regular
- **Body 2**: 14px, Regular
- **Caption**: 12px, Regular

### Spacing
- **4px, 8px, 12px, 16px, 20px, 24px, 32px, 40px, 48px**

### Border Radius
- **8px, 12px, 16px, 20px, 24px**

## 📱 Screens

### 1. Welcome Screen
- Hero section with app logo
- Feature highlights
- Smooth fade-in animations
- "Get Started" button with bounce effect

### 2. Category Selection Screen
- Grid layout of business categories
- Search functionality
- Category details modal
- Staggered animations

### 3. Business Setup Screen
- 3-step setup process
- Progress indicator
- Form validation
- Logo upload functionality

### 4. Dashboard/Home Screen
- Quick stats cards
- Recent invoices
- Action buttons
- Category-specific widgets

## 🔧 Architecture

### State Management
- **Provider** for state management
- **ChangeNotifier** for reactive UI updates
- **SharedPreferences** for local storage

### Data Layer
- **SQLite** for local database
- **JSON serialization** for data models
- **File system** for document storage

### UI Layer
- **Material Design 3** components
- **Custom widgets** for category-specific features
- **Responsive design** patterns

## 📊 Features by Category

| Category | Tax Rate | Key Features |
|----------|----------|--------------|
| Jewelry Store | 3% | Metal types, Karat, Weight, Hallmark |
| Grocery Store | 5% | Barcode, Expiry, Units, Loyalty |
| Restaurant/Café | 5% | Menu, Table, Order types, KOT |
| Clothing Store | 5% | Size, Color, Brand, Returns |
| Electronics Store | 18% | Model, Warranty, Serial, Installation |
| Hardware Store | 18% | Specs, Units, Bulk pricing, Projects |
| Pharmacy | 5% | Medicine, Dosage, Prescription, Insurance |
| Stationery Store | 18% | Categories, Bulk, Academic, Seasonal |
| Beauty Salon | 18% | Services, Stylist, Duration, Packages |
| Auto Parts Store | 18% | Vehicle, Parts, OEM, Core exchange |
| Bakery | 5% | Categories, Custom, Delivery, Dietary |
| Mobile Repair Shop | 18% | Device, IMEI, Parts, Labor, Warranty |

## � Future Enhancements

### Planned Features
- **Cloud sync** for data backup
- **Multi-currency support**
- **Advanced analytics** and reporting
- **Inventory management**
- **Customer loyalty programs**
- **Payment gateway integration**
- **Email/SMS notifications**
- **Barcode scanning** for all categories

### Technical Improvements
- **Performance optimization**
- **Enhanced security**
- **Offline sync** capabilities
- **API integration** for external services
- **Advanced search** and filtering
- **Custom invoice templates**

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## � License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Check the documentation
- Contact the development team

## 🎯 Success Metrics

- **User Adoption**: Easy onboarding and category selection
- **Daily Usage**: Regular invoice creation and management
- **Data Accuracy**: Correct tax calculations and formatting
- **Performance**: Fast, responsive user interface
- **User Satisfaction**: Professional, intuitive experience

---

**Built with ❤️ for local merchants worldwide**
