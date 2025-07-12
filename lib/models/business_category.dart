import 'package:flutter/material.dart';

enum BusinessCategory {
  jewelryStore,
  groceryStore,
  restaurantCafe,
  clothingStore,
  electronicsStore,
  hardwareStore,
  pharmacy,
  stationeryStore,
  beautySalon,
  autoPartsStore,
  bakery,
  mobileRepairShop,
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
      case BusinessCategory.pharmacy:
        return 'Pharmacy';
      case BusinessCategory.stationeryStore:
        return 'Stationery Store';
      case BusinessCategory.beautySalon:
        return 'Beauty Salon';
      case BusinessCategory.autoPartsStore:
        return 'Auto Parts Store';
      case BusinessCategory.bakery:
        return 'Bakery';
      case BusinessCategory.mobileRepairShop:
        return 'Mobile Repair Shop';
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
        return Icons.hardware;
      case BusinessCategory.pharmacy:
        return Icons.local_pharmacy;
      case BusinessCategory.stationeryStore:
        return Icons.edit_note;
      case BusinessCategory.beautySalon:
        return Icons.face;
      case BusinessCategory.autoPartsStore:
        return Icons.directions_car;
      case BusinessCategory.bakery:
        return Icons.cake;
      case BusinessCategory.mobileRepairShop:
        return Icons.phone_android;
    }
  }

  Color get color {
    switch (this) {
      case BusinessCategory.jewelryStore:
        return const Color(0xFFFFD700); // Gold
      case BusinessCategory.groceryStore:
        return const Color(0xFF4CAF50); // Green
      case BusinessCategory.restaurantCafe:
        return const Color(0xFFFF5722); // Orange
      case BusinessCategory.clothingStore:
        return const Color(0xFF9C27B0); // Purple
      case BusinessCategory.electronicsStore:
        return const Color(0xFF2196F3); // Blue
      case BusinessCategory.hardwareStore:
        return const Color(0xFF795548); // Brown
      case BusinessCategory.pharmacy:
        return const Color(0xFFE91E63); // Pink
      case BusinessCategory.stationeryStore:
        return const Color(0xFF607D8B); // Blue Grey
      case BusinessCategory.beautySalon:
        return const Color(0xFFFF9800); // Orange
      case BusinessCategory.autoPartsStore:
        return const Color(0xFF3F51B5); // Indigo
      case BusinessCategory.bakery:
        return const Color(0xFF8D6E63); // Brown
      case BusinessCategory.mobileRepairShop:
        return const Color(0xFF00BCD4); // Cyan
    }
  }

  String get description {
    switch (this) {
      case BusinessCategory.jewelryStore:
        return 'Create invoices with metal types, karat details, and hallmark certification';
      case BusinessCategory.groceryStore:
        return 'Manage inventory with barcode scanning and expiry tracking';
      case BusinessCategory.restaurantCafe:
        return 'Handle orders with table numbers and special instructions';
      case BusinessCategory.clothingStore:
        return 'Track sizes, colors, and brand details with return policies';
      case BusinessCategory.electronicsStore:
        return 'Manage warranties, serial numbers, and installation services';
      case BusinessCategory.hardwareStore:
        return 'Handle bulk pricing and project-based invoicing';
      case BusinessCategory.pharmacy:
        return 'Track prescriptions, dosages, and controlled substances';
      case BusinessCategory.stationeryStore:
        return 'Manage academic and corporate customers with bulk discounts';
      case BusinessCategory.beautySalon:
        return 'Schedule appointments and track service packages';
      case BusinessCategory.autoPartsStore:
        return 'Handle vehicle compatibility and core exchange values';
      case BusinessCategory.bakery:
        return 'Manage custom orders and delivery scheduling';
      case BusinessCategory.mobileRepairShop:
        return 'Track device repairs with IMEI and warranty details';
    }
  }

  List<String> get specificFeatures {
    switch (this) {
      case BusinessCategory.jewelryStore:
        return [
          'Metal type (Gold, Silver, Platinum)',
          'Karat/Purity fields',
          'Weight in grams',
          'Making charges',
          'Stone details',
          'Hallmark certification',
          'GST calculation',
          'Customer insurance details'
        ];
      case BusinessCategory.groceryStore:
        return [
          'Barcode scanning',
          'Quantity and unit types',
          'Expiry date tracking',
          'Batch number',
          'Category organization',
          'Discount calculations',
          'Multiple payment methods',
          'Loyalty points'
        ];
      case BusinessCategory.restaurantCafe:
        return [
          'Menu item selection',
          'Table number',
          'Order type (Dine-in, Takeaway, Delivery)',
          'Special instructions',
          'Tax calculations',
          'Split billing',
          'Tip calculation',
          'Kitchen order token (KOT)'
        ];
      case BusinessCategory.clothingStore:
        return [
          'Size and color specifications',
          'Brand details',
          'Season/Collection info',
          'Return policy terms',
          'Alteration charges',
          'GST rates for textiles',
          'Exchange policy details'
        ];
      case BusinessCategory.electronicsStore:
        return [
          'Model number and specifications',
          'Warranty period and terms',
          'Serial number tracking',
          'Installation charges',
          'Extended warranty options',
          'Return/exchange policy',
          'Service center details'
        ];
      case BusinessCategory.hardwareStore:
        return [
          'Product specifications',
          'Quantity in different units',
          'Brand and grade information',
          'Bulk pricing options',
          'Project-based invoicing',
          'Delivery charges',
          'Installation services'
        ];
      case BusinessCategory.pharmacy:
        return [
          'Medicine name and composition',
          'Dosage information',
          'Prescription number',
          'Doctor\'s name',
          'Batch number and expiry',
          'Generic/Brand options',
          'Insurance claim support',
          'Controlled substance tracking'
        ];
      case BusinessCategory.stationeryStore:
        return [
          'Product categories',
          'Bulk quantity discounts',
          'Academic/Corporate types',
          'Seasonal pricing',
          'Gift wrapping options',
          'Educational institution discounts'
        ];
      case BusinessCategory.beautySalon:
        return [
          'Service type selection',
          'Stylist/Therapist name',
          'Service duration',
          'Product used details',
          'Package deals',
          'Membership discounts',
          'Appointment scheduling'
        ];
      case BusinessCategory.autoPartsStore:
        return [
          'Vehicle compatibility',
          'Part number and specs',
          'OEM/Aftermarket classification',
          'Warranty information',
          'Installation charges',
          'Core exchange values',
          'Bulk pricing for garages'
        ];
      case BusinessCategory.bakery:
        return [
          'Product categories',
          'Custom order details',
          'Delivery date and time',
          'Special dietary info',
          'Decoration charges',
          'Advance booking system',
          'Seasonal item pricing'
        ];
      case BusinessCategory.mobileRepairShop:
        return [
          'Device model and IMEI',
          'Problem description',
          'Parts replaced',
          'Labor charges',
          'Warranty on repair',
          'Data backup/restore',
          'Pickup/delivery options'
        ];
    }
  }

  double get defaultTaxRate {
    switch (this) {
      case BusinessCategory.jewelryStore:
        return 3.0; // 3% GST for jewelry
      case BusinessCategory.groceryStore:
        return 5.0; // 5% GST for groceries
      case BusinessCategory.restaurantCafe:
        return 5.0; // 5% GST for restaurants
      case BusinessCategory.clothingStore:
        return 5.0; // 5% GST for textiles
      case BusinessCategory.electronicsStore:
        return 18.0; // 18% GST for electronics
      case BusinessCategory.hardwareStore:
        return 18.0; // 18% GST for hardware
      case BusinessCategory.pharmacy:
        return 5.0; // 5% GST for medicines
      case BusinessCategory.stationeryStore:
        return 18.0; // 18% GST for stationery
      case BusinessCategory.beautySalon:
        return 18.0; // 18% GST for services
      case BusinessCategory.autoPartsStore:
        return 18.0; // 18% GST for auto parts
      case BusinessCategory.bakery:
        return 5.0; // 5% GST for food items
      case BusinessCategory.mobileRepairShop:
        return 18.0; // 18% GST for services
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