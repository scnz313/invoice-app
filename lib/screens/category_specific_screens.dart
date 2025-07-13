import 'package:flutter/material.dart';
import '../models/business_category.dart';
import '../models/jewelry_product.dart';
import '../models/restaurant_product.dart';
import '../models/clothing_product.dart';
import '../models/electronics_product.dart';
import '../models/hardware_product.dart';
import '../models/bakery_product.dart';
import '../models/stationery_product.dart';
import '../theme/app_theme.dart';
import 'invoice_creation_screen.dart';

// Jewelry Store Screens
class JewelryInvoiceCreationScreen extends StatefulWidget {
  final BusinessCategory category;

  const JewelryInvoiceCreationScreen({
    super.key,
    required this.category,
  });

  @override
  State<JewelryInvoiceCreationScreen> createState() => _JewelryInvoiceCreationScreenState();
}

class _JewelryInvoiceCreationScreenState extends State<JewelryInvoiceCreationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Jewelry Invoice'),
        backgroundColor: AppTheme.rausch,
        foregroundColor: AppTheme.snow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildJewelrySpecificFields(),
            const SizedBox(height: 24),
            _buildStandardInvoiceFields(),
          ],
        ),
      ),
    );
  }

  Widget _buildJewelrySpecificFields() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jewelry Details',
              style: AppTheme.headline4,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Gemstone Certification',
                hintText: 'Enter certification number',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Precious Metal Type',
                hintText: 'Gold, Silver, Platinum, etc.',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Warranty Period',
                hintText: 'e.g., 2 years',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Appraisal Value',
                hintText: 'Enter appraisal amount',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardInvoiceFields() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invoice Details',
              style: AppTheme.headline4,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Customer Name',
                hintText: 'Enter customer name',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Item Description',
                hintText: 'Describe the jewelry item',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Price',
                hintText: 'Enter price',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class JewelryReportsScreen extends StatelessWidget {
  final BusinessCategory category;

  const JewelryReportsScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jewelry Reports'),
        backgroundColor: AppTheme.rausch,
        foregroundColor: AppTheme.snow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildReportCard('Gemstone Sales', Icons.diamond, 'Track gemstone sales'),
            _buildReportCard('Precious Metal Inventory', Icons.monetization_on, 'Monitor metal stock'),
            _buildReportCard('Warranty Claims', Icons.security, 'Warranty management'),
            _buildReportCard('Appraisal Reports', Icons.assessment, 'Appraisal tracking'),
            _buildReportCard('Customer Preferences', Icons.favorite, 'Customer insights'),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(String title, IconData icon, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.rausch, size: 32),
        title: Text(title, style: AppTheme.headline4),
        subtitle: Text(description, style: AppTheme.body2),
        trailing: Icon(Icons.arrow_forward_ios, color: AppTheme.foggy),
        onTap: () {
          // Navigate to specific report
        },
      ),
    );
  }
}

// Restaurant/Café Screens
class RestaurantInvoiceCreationScreen extends StatefulWidget {
  final BusinessCategory category;

  const RestaurantInvoiceCreationScreen({
    super.key,
    required this.category,
  });

  @override
  State<RestaurantInvoiceCreationScreen> createState() => _RestaurantInvoiceCreationScreenState();
}

class _RestaurantInvoiceCreationScreenState extends State<RestaurantInvoiceCreationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Restaurant Invoice'),
        backgroundColor: AppTheme.babu,
        foregroundColor: AppTheme.snow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRestaurantSpecificFields(),
            const SizedBox(height: 24),
            _buildStandardInvoiceFields(),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantSpecificFields() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Restaurant Details',
              style: AppTheme.headline4,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Table Number',
                hintText: 'Enter table number',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Server Name',
                hintText: 'Enter server name',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Order Type',
                hintText: 'Dine-in, Takeaway, Delivery',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Special Instructions',
                hintText: 'Any special requests',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardInvoiceFields() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Details',
              style: AppTheme.headline4,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Customer Name',
                hintText: 'Enter customer name',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Items Ordered',
                hintText: 'List of ordered items',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Total Amount',
                hintText: 'Enter total amount',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RestaurantReportsScreen extends StatelessWidget {
  final BusinessCategory category;

  const RestaurantReportsScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurant Reports'),
        backgroundColor: AppTheme.babu,
        foregroundColor: AppTheme.snow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildReportCard('Menu Performance', Icons.restaurant_menu, 'Popular dishes analysis'),
            _buildReportCard('Table Turnover', Icons.table_restaurant, 'Table efficiency'),
            _buildReportCard('Kitchen Orders', Icons.kitchen, 'Order management'),
            _buildReportCard('Server Performance', Icons.person, 'Server analytics'),
            _buildReportCard('Peak Hours', Icons.schedule, 'Busy time analysis'),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(String title, IconData icon, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.babu, size: 32),
        title: Text(title, style: AppTheme.headline4),
        subtitle: Text(description, style: AppTheme.body2),
        trailing: Icon(Icons.arrow_forward_ios, color: AppTheme.foggy),
        onTap: () {
          // Navigate to specific report
        },
      ),
    );
  }
}

// Clothing Store Screens
class ClothingInvoiceCreationScreen extends StatefulWidget {
  final BusinessCategory category;

  const ClothingInvoiceCreationScreen({
    super.key,
    required this.category,
  });

  @override
  State<ClothingInvoiceCreationScreen> createState() => _ClothingInvoiceCreationScreenState();
}

class _ClothingInvoiceCreationScreenState extends State<ClothingInvoiceCreationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Clothing Invoice'),
        backgroundColor: AppTheme.arches,
        foregroundColor: AppTheme.snow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildClothingSpecificFields(),
            const SizedBox(height: 24),
            _buildStandardInvoiceFields(),
          ],
        ),
      ),
    );
  }

  Widget _buildClothingSpecificFields() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Clothing Details',
              style: AppTheme.headline4,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Size',
                hintText: 'XS, S, M, L, XL, XXL',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Color',
                hintText: 'Enter color',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Brand',
                hintText: 'Enter brand name',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Season',
                hintText: 'Spring, Summer, Fall, Winter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardInvoiceFields() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invoice Details',
              style: AppTheme.headline4,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Customer Name',
                hintText: 'Enter customer name',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Item Description',
                hintText: 'Describe the clothing item',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Price',
                hintText: 'Enter price',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClothingReportsScreen extends StatelessWidget {
  final BusinessCategory category;

  const ClothingReportsScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clothing Reports'),
        backgroundColor: AppTheme.arches,
        foregroundColor: AppTheme.snow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildReportCard('Size Analytics', Icons.straighten, 'Size preference analysis'),
            _buildReportCard('Color Trends', Icons.palette, 'Popular color analysis'),
            _buildReportCard('Brand Performance', Icons.branding_watermark, 'Brand sales'),
            _buildReportCard('Seasonal Sales', Icons.wb_sunny, 'Seasonal trends'),
            _buildReportCard('Inventory by Size', Icons.inventory, 'Size-based inventory'),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(String title, IconData icon, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.arches, size: 32),
        title: Text(title, style: AppTheme.headline4),
        subtitle: Text(description, style: AppTheme.body2),
        trailing: Icon(Icons.arrow_forward_ios, color: AppTheme.foggy),
        onTap: () {
          // Navigate to specific report
        },
      ),
    );
  }
}

// Electronics Store Screens
class ElectronicsInvoiceCreationScreen extends StatefulWidget {
  final BusinessCategory category;

  const ElectronicsInvoiceCreationScreen({
    super.key,
    required this.category,
  });

  @override
  State<ElectronicsInvoiceCreationScreen> createState() => _ElectronicsInvoiceCreationScreenState();
}

class _ElectronicsInvoiceCreationScreenState extends State<ElectronicsInvoiceCreationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Electronics Invoice'),
        backgroundColor: Colors.indigo,
        foregroundColor: AppTheme.snow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildElectronicsSpecificFields(),
            const SizedBox(height: 24),
            _buildStandardInvoiceFields(),
          ],
        ),
      ),
    );
  }

  Widget _buildElectronicsSpecificFields() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Electronics Details',
              style: AppTheme.headline4,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Warranty Period',
                hintText: 'e.g., 1 year, 2 years',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Serial Number',
                hintText: 'Enter serial number',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Installation Required',
                hintText: 'Yes/No',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Technical Support',
                hintText: 'Support package details',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardInvoiceFields() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invoice Details',
              style: AppTheme.headline4,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Customer Name',
                hintText: 'Enter customer name',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Product Description',
                hintText: 'Describe the electronics item',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Price',
                hintText: 'Enter price',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ElectronicsReportsScreen extends StatelessWidget {
  final BusinessCategory category;

  const ElectronicsReportsScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Electronics Reports'),
        backgroundColor: Colors.indigo,
        foregroundColor: AppTheme.snow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildReportCard('Warranty Claims', Icons.security, 'Warranty tracking'),
            _buildReportCard('Technical Support', Icons.support_agent, 'Support requests'),
            _buildReportCard('Installation Services', Icons.build, 'Installation tracking'),
            _buildReportCard('Product Returns', Icons.undo, 'Return analysis'),
            _buildReportCard('Trade-in Program', Icons.swap_horiz, 'Trade-in analytics'),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(String title, IconData icon, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: Colors.indigo, size: 32),
        title: Text(title, style: AppTheme.headline4),
        subtitle: Text(description, style: AppTheme.body2),
        trailing: Icon(Icons.arrow_forward_ios, color: AppTheme.foggy),
        onTap: () {
          // Navigate to specific report
        },
      ),
    );
  }
}

// Hardware Store Screens
class HardwareInvoiceCreationScreen extends StatefulWidget {
  final BusinessCategory category;

  const HardwareInvoiceCreationScreen({
    super.key,
    required this.category,
  });

  @override
  State<HardwareInvoiceCreationScreen> createState() => _HardwareInvoiceCreationScreenState();
}

class _HardwareInvoiceCreationScreenState extends State<HardwareInvoiceCreationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Hardware Invoice'),
        backgroundColor: Colors.orange,
        foregroundColor: AppTheme.snow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHardwareSpecificFields(),
            const SizedBox(height: 24),
            _buildStandardInvoiceFields(),
          ],
        ),
      ),
    );
  }

  Widget _buildHardwareSpecificFields() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hardware Details',
              style: AppTheme.headline4,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Project Type',
                hintText: 'Home improvement, Construction, etc.',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Contractor Account',
                hintText: 'Contractor name or ID',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Tool Rental',
                hintText: 'Rental period if applicable',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Bulk Pricing',
                hintText: 'Bulk discount applied',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardInvoiceFields() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invoice Details',
              style: AppTheme.headline4,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Customer Name',
                hintText: 'Enter customer name',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Item Description',
                hintText: 'Describe the hardware items',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Price',
                hintText: 'Enter price',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HardwareReportsScreen extends StatelessWidget {
  final BusinessCategory category;

  const HardwareReportsScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hardware Reports'),
        backgroundColor: Colors.orange,
        foregroundColor: AppTheme.snow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildReportCard('Project Tracking', Icons.construction, 'Project analytics'),
            _buildReportCard('Contractor Accounts', Icons.person, 'Contractor performance'),
            _buildReportCard('Tool Rental', Icons.handyman, 'Rental tracking'),
            _buildReportCard('Material Usage', Icons.inventory, 'Material analytics'),
            _buildReportCard('Bulk Sales', Icons.shopping_cart, 'Bulk order analysis'),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(String title, IconData icon, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: Colors.orange, size: 32),
        title: Text(title, style: AppTheme.headline4),
        subtitle: Text(description, style: AppTheme.body2),
        trailing: Icon(Icons.arrow_forward_ios, color: AppTheme.foggy),
        onTap: () {
          // Navigate to specific report
        },
      ),
    );
  }
}

// Bakery Screens
class BakeryInvoiceCreationScreen extends StatefulWidget {
  final BusinessCategory category;

  const BakeryInvoiceCreationScreen({
    super.key,
    required this.category,
  });

  @override
  State<BakeryInvoiceCreationScreen> createState() => _BakeryInvoiceCreationScreenState();
}

class _BakeryInvoiceCreationScreenState extends State<BakeryInvoiceCreationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Bakery Invoice'),
        backgroundColor: Colors.brown,
        foregroundColor: AppTheme.snow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBakerySpecificFields(),
            const SizedBox(height: 24),
            _buildStandardInvoiceFields(),
          ],
        ),
      ),
    );
  }

  Widget _buildBakerySpecificFields() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bakery Details',
              style: AppTheme.headline4,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Production Date',
                hintText: 'Date of production',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Allergen Information',
                hintText: 'Contains nuts, dairy, etc.',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Dietary Options',
                hintText: 'Vegan, Gluten-free, etc.',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Custom Order',
                hintText: 'Special requirements',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardInvoiceFields() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invoice Details',
              style: AppTheme.headline4,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Customer Name',
                hintText: 'Enter customer name',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Item Description',
                hintText: 'Describe the bakery items',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Price',
                hintText: 'Enter price',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BakeryReportsScreen extends StatelessWidget {
  final BusinessCategory category;

  const BakeryReportsScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bakery Reports'),
        backgroundColor: Colors.brown,
        foregroundColor: AppTheme.snow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildReportCard('Production Schedule', Icons.schedule, 'Production planning'),
            _buildReportCard('Ingredient Usage', Icons.kitchen, 'Ingredient tracking'),
            _buildReportCard('Custom Orders', Icons.cake, 'Custom order analytics'),
            _buildReportCard('Allergen Tracking', Icons.warning, 'Allergen management'),
            _buildReportCard('Dietary Preferences', Icons.restaurant, 'Dietary analytics'),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(String title, IconData icon, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: Colors.brown, size: 32),
        title: Text(title, style: AppTheme.headline4),
        subtitle: Text(description, style: AppTheme.body2),
        trailing: Icon(Icons.arrow_forward_ios, color: AppTheme.foggy),
        onTap: () {
          // Navigate to specific report
        },
      ),
    );
  }
}

// Stationery Store Screens
class StationeryInvoiceCreationScreen extends StatefulWidget {
  final BusinessCategory category;

  const StationeryInvoiceCreationScreen({
    super.key,
    required this.category,
  });

  @override
  State<StationeryInvoiceCreationScreen> createState() => _StationeryInvoiceCreationScreenState();
}

class _StationeryInvoiceCreationScreenState extends State<StationeryInvoiceCreationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Stationery Invoice'),
        backgroundColor: Colors.teal,
        foregroundColor: AppTheme.snow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStationerySpecificFields(),
            const SizedBox(height: 24),
            _buildStandardInvoiceFields(),
          ],
        ),
      ),
    );
  }

  Widget _buildStationerySpecificFields() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stationery Details',
              style: AppTheme.headline4,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Category',
                hintText: 'School, Office, Art supplies',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Bulk Order',
                hintText: 'Quantity for bulk pricing',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Seasonal Item',
                hintText: 'Back to school, Holiday, etc.',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Educational Use',
                hintText: 'Student, Teacher, Business',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardInvoiceFields() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invoice Details',
              style: AppTheme.headline4,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Customer Name',
                hintText: 'Enter customer name',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Item Description',
                hintText: 'Describe the stationery items',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Price',
                hintText: 'Enter price',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StationeryReportsScreen extends StatelessWidget {
  final BusinessCategory category;

  const StationeryReportsScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stationery Reports'),
        backgroundColor: Colors.teal,
        foregroundColor: AppTheme.snow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildReportCard('School Supplies', Icons.school, 'School supply analytics'),
            _buildReportCard('Office Supplies', Icons.business, 'Office supply tracking'),
            _buildReportCard('Art Materials', Icons.palette, 'Art supply sales'),
            _buildReportCard('Bulk Orders', Icons.shopping_cart, 'Bulk order analysis'),
            _buildReportCard('Seasonal Trends', Icons.calendar_today, 'Seasonal sales'),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(String title, IconData icon, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal, size: 32),
        title: Text(title, style: AppTheme.headline4),
        subtitle: Text(description, style: AppTheme.body2),
        trailing: Icon(Icons.arrow_forward_ios, color: AppTheme.foggy),
        onTap: () {
          // Navigate to specific report
        },
      ),
    );
  }
}

// Generic Reports Screen for fallback
class GenericReportsScreen extends StatelessWidget {
  final BusinessCategory category;

  const GenericReportsScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${category.displayName} Reports'),
        backgroundColor: AppTheme.rausch,
        foregroundColor: AppTheme.snow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildReportCard('Sales Analytics', Icons.analytics, 'Sales performance'),
            _buildReportCard('Inventory Reports', Icons.inventory, 'Stock management'),
            _buildReportCard('Customer Insights', Icons.people, 'Customer analytics'),
            _buildReportCard('Financial Reports', Icons.account_balance, 'Financial overview'),
            _buildReportCard('Product Performance', Icons.trending_up, 'Product analytics'),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(String title, IconData icon, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.rausch, size: 32),
        title: Text(title, style: AppTheme.headline4),
        subtitle: Text(description, style: AppTheme.body2),
        trailing: Icon(Icons.arrow_forward_ios, color: AppTheme.foggy),
        onTap: () {
          // Navigate to specific report
        },
      ),
    );
  }
}