import 'package:flutter/material.dart';

enum BusinessCategory {
  jewelryStore,
  groceryStore,
  restaurantCafe,
  clothingStore,
  electronicsStore,
  hardwareStore,
  bakery,
  stationeryStore,
}

extension BusinessCategoryExtension on BusinessCategory {
  String get displayName {
    switch (this) {
      case BusinessCategory.jewelryStore:
        return 'Jewelry Store';
      case BusinessCategory.groceryStore:
        return 'Grocery Store';
      case BusinessCategory.restaurantCafe:
        return 'Restaurant/Café';
      case BusinessCategory.clothingStore:
        return 'Clothing Store';
      case BusinessCategory.electronicsStore:
        return 'Electronics Store';
      case BusinessCategory.hardwareStore:
        return 'Hardware Store';
      case BusinessCategory.bakery:
        return 'Bakery';
      case BusinessCategory.stationeryStore:
        return 'Stationery Store';
    }
  }

  String get description {
    switch (this) {
      case BusinessCategory.jewelryStore:
        return 'Sell jewelry, watches, and precious metals with certification tracking';
      case BusinessCategory.groceryStore:
        return 'Sell groceries, fresh produce, and household items with inventory management';
      case BusinessCategory.restaurantCafe:
        return 'Serve food and beverages with table management and kitchen orders';
      case BusinessCategory.clothingStore:
        return 'Sell clothing, accessories, and fashion items with size and color variants';
      case BusinessCategory.electronicsStore:
        return 'Sell electronics, gadgets, and tech accessories with warranty tracking';
      case BusinessCategory.hardwareStore:
        return 'Sell tools, building materials, and hardware with project tracking';
      case BusinessCategory.bakery:
        return 'Sell fresh baked goods, cakes, and pastries with production scheduling';
      case BusinessCategory.stationeryStore:
        return 'Sell office supplies, books, and stationery items with bulk pricing';
    }
  }

  IconData get icon {
    switch (this) {
      case BusinessCategory.jewelryStore:
        return Icons.diamond;
      case BusinessCategory.groceryStore:
        return Icons.shopping_basket;
      case BusinessCategory.restaurantCafe:
        return Icons.restaurant;
      case BusinessCategory.clothingStore:
        return Icons.checkroom;
      case BusinessCategory.electronicsStore:
        return Icons.devices;
      case BusinessCategory.hardwareStore:
        return Icons.build;
      case BusinessCategory.bakery:
        return Icons.cake;
      case BusinessCategory.stationeryStore:
        return Icons.edit;
    }
  }

  Color get color {
    switch (this) {
      case BusinessCategory.jewelryStore:
        return Colors.amber;
      case BusinessCategory.groceryStore:
        return Colors.green;
      case BusinessCategory.restaurantCafe:
        return Colors.orange;
      case BusinessCategory.clothingStore:
        return Colors.pink;
      case BusinessCategory.electronicsStore:
        return Colors.blue;
      case BusinessCategory.hardwareStore:
        return Colors.brown;
      case BusinessCategory.bakery:
        return Colors.orange;
      case BusinessCategory.stationeryStore:
        return Colors.purple;
    }
  }

  List<String> get specificFeatures {
    switch (this) {
      case BusinessCategory.jewelryStore:
        return [
          'Gemstone Certification',
          'Precious Metal Tracking',
          'Jewelry Appraisal',
          'Warranty Management',
          'Custom Design Orders',
          'Layaway Plans',
          'Insurance Documentation',
          'Quality Certificates',
        ];
      case BusinessCategory.groceryStore:
        return [
          'Barcode Scanning',
          'Inventory Management',
          'Expiry Date Tracking',
          'Supplier Management',
          'Loyalty Program',
          'Promotional Offers',
          'Fresh Produce Tracking',
          'Bulk Pricing',
        ];
      case BusinessCategory.restaurantCafe:
        return [
          'Table Management',
          'Kitchen Orders',
          'Menu Management',
          'Reservation System',
          'Takeaway Orders',
          'Delivery Tracking',
          'Staff Scheduling',
          'Recipe Management',
        ];
      case BusinessCategory.clothingStore:
        return [
          'Size Variants',
          'Color Options',
          'Brand Management',
          'Seasonal Collections',
          'Fitting Room Booking',
          'Alteration Services',
          'Return Management',
          'Fashion Trends',
        ];
      case BusinessCategory.electronicsStore:
        return [
          'Warranty Tracking',
          'Technical Support',
          'Installation Services',
          'Trade-in Programs',
          'Extended Warranty',
          'Product Demos',
          'Repair Services',
          'Accessory Bundles',
        ];
      case BusinessCategory.hardwareStore:
        return [
          'Project Tracking',
          'Contractor Accounts',
          'Tool Rental',
          'Material Estimation',
          'Safety Equipment',
          'Delivery Services',
          'Installation Services',
          'DIY Guides',
        ];
      case BusinessCategory.bakery:
        return [
          'Production Scheduling',
          'Ingredient Management',
          'Custom Cake Orders',
          'Allergen Tracking',
          'Freshness Monitoring',
          'Catering Orders',
          'Recipe Scaling',
          'Quality Control',
        ];
      case BusinessCategory.stationeryStore:
        return [
          'Bulk Pricing',
          'School Supplies',
          'Office Equipment',
          'Printing Services',
          'Book Management',
          'Art Supplies',
          'Corporate Accounts',
          'Educational Discounts',
        ];
    }
  }

  List<String> get productCategories {
    switch (this) {
      case BusinessCategory.jewelryStore:
        return [
          'Rings',
          'Necklaces',
          'Earrings',
          'Bracelets',
          'Watches',
          'Pendants',
          'Anklets',
          'Wedding Bands',
          'Diamond Jewelry',
          'Gold Jewelry',
          'Silver Jewelry',
          'Platinum Jewelry',
        ];
      case BusinessCategory.groceryStore:
        return [
          'Fruits & Vegetables',
          'Dairy & Eggs',
          'Meat & Fish',
          'Grains & Cereals',
          'Beverages',
          'Snacks',
          'Frozen Foods',
          'Personal Care',
          'Household',
          'Baby Care',
          'Pet Supplies',
          'Others',
        ];
      case BusinessCategory.restaurantCafe:
        return [
          'Appetizers',
          'Main Course',
          'Desserts',
          'Beverages',
          'Alcoholic Drinks',
          'Coffee & Tea',
          'Fast Food',
          'Healthy Options',
          'Vegetarian',
          'Vegan',
          'Gluten-Free',
          'Kids Menu',
        ];
      case BusinessCategory.clothingStore:
        return [
          'Men\'s Clothing',
          'Women\'s Clothing',
          'Kids Clothing',
          'Accessories',
          'Shoes',
          'Bags',
          'Jewelry',
          'Watches',
          'Sunglasses',
          'Belts',
          'Scarves',
          'Hats',
        ];
      case BusinessCategory.electronicsStore:
        return [
          'Smartphones',
          'Laptops',
          'Tablets',
          'TVs & Audio',
          'Gaming',
          'Cameras',
          'Accessories',
          'Smart Home',
          'Wearables',
          'Computers',
          'Networking',
          'Software',
        ];
      case BusinessCategory.hardwareStore:
        return [
          'Tools',
          'Building Materials',
          'Electrical',
          'Plumbing',
          'Paint & Supplies',
          'Garden & Outdoor',
          'Safety Equipment',
          'Automotive',
          'Fasteners',
          'Adhesives',
          'Measuring Tools',
          'Power Tools',
        ];
      case BusinessCategory.bakery:
        return [
          'Bread',
          'Cakes',
          'Pastries',
          'Cookies',
          'Muffins',
          'Pies',
          'Donuts',
          'Sandwiches',
          'Beverages',
          'Custom Orders',
          'Seasonal Items',
          'Dietary Options',
        ];
      case BusinessCategory.stationeryStore:
        return [
          'Writing Supplies',
          'Paper Products',
          'Office Equipment',
          'Art Supplies',
          'Books',
          'School Supplies',
          'Desk Accessories',
          'Filing Supplies',
          'Presentation Materials',
          'Technology',
          'Gifts',
          'Printing Services',
        ];
    }
  }

  List<String> get paymentMethods {
    switch (this) {
      case BusinessCategory.jewelryStore:
        return [
          'Cash',
          'Card',
          'UPI',
          'Bank Transfer',
          'Layaway',
          'EMI',
          'Gold Exchange',
          'Insurance Claim',
        ];
      case BusinessCategory.groceryStore:
        return [
          'Cash',
          'Card',
          'UPI',
          'Store Credit',
          'Loyalty Points',
          'Split Payment',
          'Partial Payment',
        ];
      case BusinessCategory.restaurantCafe:
        return [
          'Cash',
          'Card',
          'UPI',
          'Digital Wallets',
          'Split Bill',
          'Corporate Account',
          'Gift Cards',
        ];
      case BusinessCategory.clothingStore:
        return [
          'Cash',
          'Card',
          'UPI',
          'Store Credit',
          'Layaway',
          'Split Payment',
          'Exchange',
        ];
      case BusinessCategory.electronicsStore:
        return [
          'Cash',
          'Card',
          'UPI',
          'EMI',
          'Trade-in',
          'Corporate Account',
          'Extended Warranty',
        ];
      case BusinessCategory.hardwareStore:
        return [
          'Cash',
          'Card',
          'UPI',
          'Contractor Account',
          'Project Billing',
          'Rental Payment',
          'Delivery Payment',
        ];
      case BusinessCategory.bakery:
        return [
          'Cash',
          'Card',
          'UPI',
          'Pre-orders',
          'Catering Payment',
          'Loyalty Points',
          'Split Payment',
        ];
      case BusinessCategory.stationeryStore:
        return [
          'Cash',
          'Card',
          'UPI',
          'Corporate Account',
          'Bulk Payment',
          'School Account',
          'Printing Payment',
        ];
    }
  }

  List<String> get reportTypes {
    switch (this) {
      case BusinessCategory.jewelryStore:
        return [
          'Sales by Category',
          'Gemstone Analysis',
          'Warranty Reports',
          'Appraisal History',
          'Layaway Tracking',
          'Insurance Claims',
          'Customer Preferences',
          'Profit Margins',
        ];
      case BusinessCategory.groceryStore:
        return [
          'Sales Analysis',
          'Inventory Reports',
          'Customer Analytics',
          'Profit Margins',
          'Expiry Reports',
          'Supplier Performance',
          'Promotion Effectiveness',
          'Loyalty Analytics',
        ];
      case BusinessCategory.restaurantCafe:
        return [
          'Sales by Menu',
          'Table Turnover',
          'Kitchen Performance',
          'Reservation Analytics',
          'Delivery Reports',
          'Staff Performance',
          'Food Cost Analysis',
          'Customer Feedback',
        ];
      case BusinessCategory.clothingStore:
        return [
          'Sales by Category',
          'Size Analytics',
          'Color Preferences',
          'Seasonal Trends',
          'Return Analysis',
          'Brand Performance',
          'Fitting Room Usage',
          'Alteration Services',
        ];
      case BusinessCategory.electronicsStore:
        return [
          'Sales by Category',
          'Warranty Claims',
          'Technical Support',
          'Installation Services',
          'Trade-in Analysis',
          'Accessory Sales',
          'Repair Services',
          'Customer Satisfaction',
        ];
      case BusinessCategory.hardwareStore:
        return [
          'Sales by Category',
          'Project Tracking',
          'Contractor Accounts',
          'Tool Rental',
          'Material Usage',
          'Delivery Services',
          'Installation Services',
          'Safety Compliance',
        ];
      case BusinessCategory.bakery:
        return [
          'Sales by Category',
          'Production Analysis',
          'Ingredient Usage',
          'Custom Orders',
          'Catering Reports',
          'Freshness Tracking',
          'Quality Control',
          'Recipe Performance',
        ];
      case BusinessCategory.stationeryStore:
        return [
          'Sales by Category',
          'Bulk Orders',
          'School Supplies',
          'Corporate Accounts',
          'Printing Services',
          'Book Sales',
          'Art Supplies',
          'Educational Discounts',
        ];
    }
  }

  double get defaultTaxRate {
    switch (this) {
      case BusinessCategory.groceryStore:
        return 5.0; // Lower tax rate for groceries
      case BusinessCategory.restaurantCafe:
        return 5.0; // Service tax for restaurants
      case BusinessCategory.jewelryStore:
        return 3.0; // Lower tax for jewelry
      case BusinessCategory.clothingStore:
        return 12.0; // Standard tax for clothing
      case BusinessCategory.electronicsStore:
        return 18.0; // Higher tax for electronics
      case BusinessCategory.hardwareStore:
        return 18.0; // Standard tax for hardware
      case BusinessCategory.bakery:
        return 5.0; // Lower tax for food items
      case BusinessCategory.stationeryStore:
        return 12.0; // Standard tax for stationery
      case BusinessCategory.other:
        return 18.0; // Default tax rate
    }
  }

  Map<String, dynamic> get defaultSettings {
    switch (this) {
      case BusinessCategory.jewelryStore:
        return {
          'taxRate': 3.0,
          'currency': '₹',
          'language': 'English',
          'timezone': 'Asia/Kolkata',
          'businessHours': {
            'monday': {'open': '10:00', 'close': '19:00'},
            'tuesday': {'open': '10:00', 'close': '19:00'},
            'wednesday': {'open': '10:00', 'close': '19:00'},
            'thursday': {'open': '10:00', 'close': '19:00'},
            'friday': {'open': '10:00', 'close': '19:00'},
            'saturday': {'open': '10:00', 'close': '18:00'},
            'sunday': {'open': '11:00', 'close': '17:00'},
          },
          'features': {
            'warrantyTracking': true,
            'certificationTracking': true,
            'layawayPlans': true,
            'insuranceClaims': true,
          },
        };
      case BusinessCategory.groceryStore:
        return {
          'taxRate': 5.0,
          'currency': '₹',
          'language': 'English',
          'timezone': 'Asia/Kolkata',
          'businessHours': {
            'monday': {'open': '07:00', 'close': '22:00'},
            'tuesday': {'open': '07:00', 'close': '22:00'},
            'wednesday': {'open': '07:00', 'close': '22:00'},
            'thursday': {'open': '07:00', 'close': '22:00'},
            'friday': {'open': '07:00', 'close': '22:00'},
            'saturday': {'open': '07:00', 'close': '22:00'},
            'sunday': {'open': '07:00', 'close': '22:00'},
          },
          'features': {
            'barcodeScanning': true,
            'inventoryManagement': true,
            'loyaltyProgram': true,
            'expiryTracking': true,
          },
        };
      case BusinessCategory.restaurantCafe:
        return {
          'taxRate': 5.0,
          'currency': '₹',
          'language': 'English',
          'timezone': 'Asia/Kolkata',
          'businessHours': {
            'monday': {'open': '08:00', 'close': '23:00'},
            'tuesday': {'open': '08:00', 'close': '23:00'},
            'wednesday': {'open': '08:00', 'close': '23:00'},
            'thursday': {'open': '08:00', 'close': '23:00'},
            'friday': {'open': '08:00', 'close': '00:00'},
            'saturday': {'open': '08:00', 'close': '00:00'},
            'sunday': {'open': '08:00', 'close': '22:00'},
          },
          'features': {
            'tableManagement': true,
            'kitchenOrders': true,
            'reservations': true,
            'delivery': true,
          },
        };
      case BusinessCategory.clothingStore:
        return {
          'taxRate': 5.0,
          'currency': '₹',
          'language': 'English',
          'timezone': 'Asia/Kolkata',
          'businessHours': {
            'monday': {'open': '10:00', 'close': '20:00'},
            'tuesday': {'open': '10:00', 'close': '20:00'},
            'wednesday': {'open': '10:00', 'close': '20:00'},
            'thursday': {'open': '10:00', 'close': '20:00'},
            'friday': {'open': '10:00', 'close': '21:00'},
            'saturday': {'open': '10:00', 'close': '21:00'},
            'sunday': {'open': '11:00', 'close': '19:00'},
          },
          'features': {
            'sizeVariants': true,
            'colorOptions': true,
            'fittingRooms': true,
            'alterationServices': true,
          },
        };
      case BusinessCategory.electronicsStore:
        return {
          'taxRate': 18.0,
          'currency': '₹',
          'language': 'English',
          'timezone': 'Asia/Kolkata',
          'businessHours': {
            'monday': {'open': '10:00', 'close': '20:00'},
            'tuesday': {'open': '10:00', 'close': '20:00'},
            'wednesday': {'open': '10:00', 'close': '20:00'},
            'thursday': {'open': '10:00', 'close': '20:00'},
            'friday': {'open': '10:00', 'close': '21:00'},
            'saturday': {'open': '10:00', 'close': '21:00'},
            'sunday': {'open': '11:00', 'close': '19:00'},
          },
          'features': {
            'warrantyTracking': true,
            'technicalSupport': true,
            'installationServices': true,
            'tradeInPrograms': true,
          },
        };
      case BusinessCategory.hardwareStore:
        return {
          'taxRate': 18.0,
          'currency': '₹',
          'language': 'English',
          'timezone': 'Asia/Kolkata',
          'businessHours': {
            'monday': {'open': '08:00', 'close': '19:00'},
            'tuesday': {'open': '08:00', 'close': '19:00'},
            'wednesday': {'open': '08:00', 'close': '19:00'},
            'thursday': {'open': '08:00', 'close': '19:00'},
            'friday': {'open': '08:00', 'close': '19:00'},
            'saturday': {'open': '08:00', 'close': '18:00'},
            'sunday': {'open': '09:00', 'close': '17:00'},
          },
          'features': {
            'projectTracking': true,
            'contractorAccounts': true,
            'toolRental': true,
            'deliveryServices': true,
          },
        };
      case BusinessCategory.bakery:
        return {
          'taxRate': 5.0,
          'currency': '₹',
          'language': 'English',
          'timezone': 'Asia/Kolkata',
          'businessHours': {
            'monday': {'open': '06:00', 'close': '21:00'},
            'tuesday': {'open': '06:00', 'close': '21:00'},
            'wednesday': {'open': '06:00', 'close': '21:00'},
            'thursday': {'open': '06:00', 'close': '21:00'},
            'friday': {'open': '06:00', 'close': '21:00'},
            'saturday': {'open': '06:00', 'close': '21:00'},
            'sunday': {'open': '07:00', 'close': '20:00'},
          },
          'features': {
            'productionScheduling': true,
            'customOrders': true,
            'catering': true,
            'allergenTracking': true,
          },
        };
      case BusinessCategory.stationeryStore:
        return {
          'taxRate': 18.0,
          'currency': '₹',
          'language': 'English',
          'timezone': 'Asia/Kolkata',
          'businessHours': {
            'monday': {'open': '09:00', 'close': '19:00'},
            'tuesday': {'open': '09:00', 'close': '19:00'},
            'wednesday': {'open': '09:00', 'close': '19:00'},
            'thursday': {'open': '09:00', 'close': '19:00'},
            'friday': {'open': '09:00', 'close': '19:00'},
            'saturday': {'open': '09:00', 'close': '18:00'},
            'sunday': {'open': '10:00', 'close': '17:00'},
          },
          'features': {
            'bulkPricing': true,
            'corporateAccounts': true,
            'printingServices': true,
            'educationalDiscounts': true,
          },
        };
    }
  }
}

class BusinessCategoryData {
  final BusinessCategory category;
  final String displayName;
  final IconData icon;
  final Color color;
  final String description;
  final List<String> features;
  final double defaultTaxRate;

  const BusinessCategoryData({
    required this.category,
    required this.displayName,
    required this.icon,
    required this.color,
    required this.description,
    required this.features,
    required this.defaultTaxRate,
  });

  static List<BusinessCategoryData> getAllCategories() {
    return BusinessCategory.values.map((category) => BusinessCategoryData(
      category: category,
      displayName: category.displayName,
      icon: category.icon,
      color: category.color,
      description: category.description,
      features: category.specificFeatures,
      defaultTaxRate: category.defaultTaxRate,
    )).toList();
  }
}