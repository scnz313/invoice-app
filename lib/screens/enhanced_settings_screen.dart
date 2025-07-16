import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/business_category.dart';
import '../theme/app_theme.dart';

class EnhancedSettingsScreen extends StatefulWidget {
  const EnhancedSettingsScreen({super.key});

  @override
  State<EnhancedSettingsScreen> createState() => _EnhancedSettingsScreenState();
}

class _EnhancedSettingsScreenState extends State<EnhancedSettingsScreen> {
  late BusinessCategory _selectedCategory;
  bool _isLoading = true;
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _autoBackupEnabled = true;
  String _selectedCurrency = 'USD';
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadBusinessCategory();
  }

  Future<void> _loadBusinessCategory() async {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    _selectedCategory = await settingsProvider.getBusinessCategory();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.ghost,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_getCategoryColor()),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.ghost,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildBusinessInfo(),
            const SizedBox(height: 24),
            _buildCategorySpecificSettings(),
            const SizedBox(height: 24),
            _buildGeneralSettings(),
            const SizedBox(height: 24),
            _buildNotificationSettings(),
            const SizedBox(height: 24),
            _buildDataSettings(),
            const SizedBox(height: 24),
            _buildSupportSection(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        '${_selectedCategory.displayName} Settings',
        style: AppTheme.headline4.copyWith(color: AppTheme.snow),
      ),
      backgroundColor: _getCategoryColor(),
      foregroundColor: AppTheme.snow,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: () => _saveSettings(),
        ),
      ],
    );
  }

  Widget _buildBusinessInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _selectedCategory.icon,
                  size: 32,
                  color: _getCategoryColor(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedCategory.displayName,
                        style: AppTheme.headline4,
                      ),
                      Text(
                        'Business Configuration',
                        style: AppTheme.body2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Business Type', _selectedCategory.displayName),
            _buildInfoRow('App Version', '1.0.0'),
            _buildInfoRow('Last Updated', 'Today'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.body2),
          Text(
            value,
            style: AppTheme.body2.copyWith(
              fontWeight: FontWeight.w600,
              color: _getCategoryColor(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySpecificSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_selectedCategory.displayName} Settings',
              style: AppTheme.headline4,
            ),
            const SizedBox(height: 16),
            _buildCategorySpecificContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySpecificContent() {
    switch (_selectedCategory) {
      case BusinessCategory.jewelryStore:
        return _buildJewelrySettings();
      case BusinessCategory.restaurantCafe:
        return _buildRestaurantSettings();
      case BusinessCategory.clothingStore:
        return _buildClothingSettings();
      case BusinessCategory.electronicsStore:
        return _buildElectronicsSettings();
      case BusinessCategory.hardwareStore:
        return _buildHardwareSettings();
      case BusinessCategory.bakery:
        return _buildBakerySettings();
      case BusinessCategory.stationeryStore:
        return _buildStationerySettings();
      case BusinessCategory.groceryStore:
        return _buildGrocerySettings();
      default:
        return _buildGenericSettings();
    }
  }

  Widget _buildJewelrySettings() {
    return Column(
      children: [
        _buildSettingTile(
          'Gemstone Certification',
          'Manage certification settings',
          Icons.diamond,
          () => _showJewelryCertificationSettings(),
        ),
        _buildSettingTile(
          'Warranty Management',
          'Configure warranty policies',
          Icons.security,
          () => _showWarrantySettings(),
        ),
        _buildSettingTile(
          'Appraisal Settings',
          'Set up appraisal workflows',
          Icons.assessment,
          () => _showAppraisalSettings(),
        ),
        _buildSettingTile(
          'Precious Metal Tracking',
          'Configure metal inventory',
          Icons.monetization_on,
          () => _showMetalTrackingSettings(),
        ),
      ],
    );
  }

  Widget _buildRestaurantSettings() {
    return Column(
      children: [
        _buildSettingTile(
          'Table Management',
          'Configure table settings',
          Icons.table_restaurant,
          () => _showTableSettings(),
        ),
        _buildSettingTile(
          'Menu Management',
          'Set up menu categories',
          Icons.restaurant_menu,
          () => _showMenuSettings(),
        ),
        _buildSettingTile(
          'Kitchen Orders',
          'Configure kitchen workflow',
          Icons.kitchen,
          () => _showKitchenSettings(),
        ),
        _buildSettingTile(
          'Server Management',
          'Manage server accounts',
          Icons.person,
          () => _showServerSettings(),
        ),
      ],
    );
  }

  Widget _buildClothingSettings() {
    return Column(
      children: [
        _buildSettingTile(
          'Size Management',
          'Configure size options',
          Icons.straighten,
          () => _showSizeSettings(),
        ),
        _buildSettingTile(
          'Color Management',
          'Set up color options',
          Icons.palette,
          () => _showColorSettings(),
        ),
        _buildSettingTile(
          'Brand Management',
          'Manage brand settings',
          Icons.branding_watermark,
          () => _showBrandSettings(),
        ),
        _buildSettingTile(
          'Seasonal Collections',
          'Configure seasonal settings',
          Icons.wb_sunny,
          () => _showSeasonalSettings(),
        ),
      ],
    );
  }

  Widget _buildElectronicsSettings() {
    return Column(
      children: [
        _buildSettingTile(
          'Warranty Tracking',
          'Configure warranty settings',
          Icons.security,
          () => _showWarrantySettings(),
        ),
        _buildSettingTile(
          'Technical Support',
          'Set up support workflows',
          Icons.support_agent,
          () => _showSupportSettings(),
        ),
        _buildSettingTile(
          'Installation Services',
          'Configure installation',
          Icons.build,
          () => _showInstallationSettings(),
        ),
        _buildSettingTile(
          'Trade-in Program',
          'Manage trade-in settings',
          Icons.swap_horiz,
          () => _showTradeInSettings(),
        ),
      ],
    );
  }

  Widget _buildHardwareSettings() {
    return Column(
      children: [
        _buildSettingTile(
          'Project Tracking',
          'Configure project settings',
          Icons.construction,
          () => _showProjectSettings(),
        ),
        _buildSettingTile(
          'Contractor Management',
          'Manage contractor accounts',
          Icons.person,
          () => _showContractorSettings(),
        ),
        _buildSettingTile(
          'Tool Rental',
          'Configure rental settings',
          Icons.handyman,
          () => _showRentalSettings(),
        ),
        _buildSettingTile(
          'Bulk Pricing',
          'Set up bulk pricing rules',
          Icons.shopping_cart,
          () => _showBulkPricingSettings(),
        ),
      ],
    );
  }

  Widget _buildBakerySettings() {
    return Column(
      children: [
        _buildSettingTile(
          'Production Schedule',
          'Configure production settings',
          Icons.schedule,
          () => _showProductionSettings(),
        ),
        _buildSettingTile(
          'Ingredient Management',
          'Manage ingredient tracking',
          Icons.kitchen,
          () => _showIngredientSettings(),
        ),
        _buildSettingTile(
          'Allergen Tracking',
          'Configure allergen settings',
          Icons.warning,
          () => _showAllergenSettings(),
        ),
        _buildSettingTile(
          'Custom Orders',
          'Set up custom order workflow',
          Icons.cake,
          () => _showCustomOrderSettings(),
        ),
      ],
    );
  }

  Widget _buildStationerySettings() {
    return Column(
      children: [
        _buildSettingTile(
          'School Supplies',
          'Configure school settings',
          Icons.school,
          () => _showSchoolSettings(),
        ),
        _buildSettingTile(
          'Office Supplies',
          'Manage office settings',
          Icons.business,
          () => _showOfficeSettings(),
        ),
        _buildSettingTile(
          'Art Materials',
          'Configure art settings',
          Icons.palette,
          () => _showArtSettings(),
        ),
        _buildSettingTile(
          'Bulk Orders',
          'Set up bulk order settings',
          Icons.shopping_cart,
          () => _showBulkOrderSettings(),
        ),
      ],
    );
  }

  Widget _buildGrocerySettings() {
    return Column(
      children: [
        _buildSettingTile(
          'Fresh Produce',
          'Configure produce settings',
          Icons.local_florist,
          () => _showProduceSettings(),
        ),
        _buildSettingTile(
          'Dairy Management',
          'Manage dairy settings',
          Icons.local_drink,
          () => _showDairySettings(),
        ),
        _buildSettingTile(
          'Loyalty Program',
          'Configure loyalty settings',
          Icons.card_membership,
          () => _showLoyaltySettings(),
        ),
        _buildSettingTile(
          'Expiry Tracking',
          'Set up expiry alerts',
          Icons.warning,
          () => _showExpirySettings(),
        ),
      ],
    );
  }

  Widget _buildGenericSettings() {
    return Column(
      children: [
        _buildSettingTile(
          'Business Profile',
          'Configure business details',
          Icons.business,
          () => _showBusinessProfileSettings(),
        ),
        _buildSettingTile(
          'Inventory Settings',
          'Manage inventory configuration',
          Icons.inventory,
          () => _showInventorySettings(),
        ),
        _buildSettingTile(
          'Customer Management',
          'Configure customer settings',
          Icons.people,
          () => _showCustomerSettings(),
        ),
        _buildSettingTile(
          'Reporting Settings',
          'Set up reporting preferences',
          Icons.analytics,
          () => _showReportingSettings(),
        ),
      ],
    );
  }

  Widget _buildSettingTile(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _getCategoryColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: _getCategoryColor(), size: 20),
      ),
      title: Text(title, style: AppTheme.body1.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: AppTheme.caption),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildGeneralSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'General Settings',
              style: AppTheme.headline4,
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              'Dark Mode',
              'Enable dark theme',
              Icons.dark_mode,
              _darkModeEnabled,
              (value) {
                setState(() {
                  _darkModeEnabled = value;
                });
              },
            ),
            _buildDropdownTile(
              'Currency',
              'Select your currency',
              Icons.attach_money,
              _selectedCurrency,
              ['USD', 'EUR', 'GBP', 'CAD', 'AUD'],
              (value) {
                setState(() {
                  _selectedCurrency = value;
                });
              },
            ),
            _buildDropdownTile(
              'Language',
              'Select your language',
              Icons.language,
              _selectedLanguage,
              ['English', 'Spanish', 'French', 'German', 'Chinese'],
              (value) {
                setState(() {
                  _selectedLanguage = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Settings',
              style: AppTheme.headline4,
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              'Push Notifications',
              'Receive push notifications',
              Icons.notifications,
              _notificationsEnabled,
              (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            _buildSettingTile(
              'Notification Preferences',
              'Configure notification types',
              Icons.settings,
              () => _showNotificationPreferences(),
            ),
            _buildSettingTile(
              'Email Notifications',
              'Set up email alerts',
              Icons.email,
              () => _showEmailSettings(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data & Backup',
              style: AppTheme.headline4,
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              'Auto Backup',
              'Automatically backup data',
              Icons.backup,
              _autoBackupEnabled,
              (value) {
                setState(() {
                  _autoBackupEnabled = value;
                });
              },
            ),
            _buildSettingTile(
              'Export Data',
              'Export your business data',
              Icons.download,
              () => _exportData(),
            ),
            _buildSettingTile(
              'Import Data',
              'Import data from file',
              Icons.upload,
              () => _importData(),
            ),
            _buildSettingTile(
              'Data Privacy',
              'Manage data privacy settings',
              Icons.privacy_tip,
              () => _showPrivacySettings(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Support & Help',
              style: AppTheme.headline4,
            ),
            const SizedBox(height: 16),
            _buildSettingTile(
              'Help Center',
              'Get help and tutorials',
              Icons.help,
              () => _showHelpCenter(),
            ),
            _buildSettingTile(
              'Contact Support',
              'Get in touch with support',
              Icons.support_agent,
              () => _contactSupport(),
            ),
            _buildSettingTile(
              'Feedback',
              'Send us your feedback',
              Icons.feedback,
              () => _sendFeedback(),
            ),
            _buildSettingTile(
              'About',
              'App information and version',
              Icons.info,
              () => _showAboutDialog(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _getCategoryColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: _getCategoryColor(), size: 20),
      ),
      title: Text(title, style: AppTheme.body1.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: AppTheme.caption),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: _getCategoryColor(),
      ),
    );
  }

  Widget _buildDropdownTile(String title, String subtitle, IconData icon, String value, List<String> options, Function(String) onChanged) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _getCategoryColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: _getCategoryColor(), size: 20),
      ),
      title: Text(title, style: AppTheme.body1.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: AppTheme.caption),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
      ),
    );
  }

  // Category-specific setting methods
  void _showJewelryCertificationSettings() {
    _showSettingsDialog('Jewelry Certification Settings', 'Configure gemstone certification workflows');
  }

  void _showWarrantySettings() {
    _showSettingsDialog('Warranty Settings', 'Configure warranty management policies');
  }

  void _showAppraisalSettings() {
    _showSettingsDialog('Appraisal Settings', 'Set up appraisal workflows and requirements');
  }

  void _showMetalTrackingSettings() {
    _showSettingsDialog('Metal Tracking Settings', 'Configure precious metal inventory tracking');
  }

  void _showTableSettings() {
    _showSettingsDialog('Table Management Settings', 'Configure table layout and management');
  }

  void _showMenuSettings() {
    _showSettingsDialog('Menu Management Settings', 'Set up menu categories and items');
  }

  void _showKitchenSettings() {
    _showSettingsDialog('Kitchen Settings', 'Configure kitchen order workflow');
  }

  void _showServerSettings() {
    _showSettingsDialog('Server Management Settings', 'Manage server accounts and permissions');
  }

  void _showSizeSettings() {
    _showSettingsDialog('Size Management Settings', 'Configure clothing size options');
  }

  void _showColorSettings() {
    _showSettingsDialog('Color Management Settings', 'Set up color options and variants');
  }

  void _showBrandSettings() {
    _showSettingsDialog('Brand Management Settings', 'Manage brand settings and categories');
  }

  void _showSeasonalSettings() {
    _showSettingsDialog('Seasonal Collection Settings', 'Configure seasonal collection management');
  }

  void _showSupportSettings() {
    _showSettingsDialog('Technical Support Settings', 'Configure support workflows and policies');
  }

  void _showInstallationSettings() {
    _showSettingsDialog('Installation Settings', 'Set up installation service configuration');
  }

  void _showTradeInSettings() {
    _showSettingsDialog('Trade-in Program Settings', 'Configure trade-in program policies');
  }

  void _showProjectSettings() {
    _showSettingsDialog('Project Tracking Settings', 'Configure project management workflows');
  }

  void _showContractorSettings() {
    _showSettingsDialog('Contractor Management Settings', 'Manage contractor accounts and permissions');
  }

  void _showRentalSettings() {
    _showSettingsDialog('Tool Rental Settings', 'Configure tool rental policies and pricing');
  }

  void _showBulkPricingSettings() {
    _showSettingsDialog('Bulk Pricing Settings', 'Set up bulk pricing rules and discounts');
  }

  void _showProductionSettings() {
    _showSettingsDialog('Production Schedule Settings', 'Configure production planning and scheduling');
  }

  void _showIngredientSettings() {
    _showSettingsDialog('Ingredient Management Settings', 'Set up ingredient tracking and alerts');
  }

  void _showAllergenSettings() {
    _showSettingsDialog('Allergen Tracking Settings', 'Configure allergen information management');
  }

  void _showCustomOrderSettings() {
    _showSettingsDialog('Custom Order Settings', 'Set up custom order workflow and pricing');
  }

  void _showSchoolSettings() {
    _showSettingsDialog('School Supplies Settings', 'Configure school supply categories and pricing');
  }

  void _showOfficeSettings() {
    _showSettingsDialog('Office Supplies Settings', 'Manage office supply categories and inventory');
  }

  void _showArtSettings() {
    _showSettingsDialog('Art Materials Settings', 'Configure art material categories and pricing');
  }

  void _showBulkOrderSettings() {
    _showSettingsDialog('Bulk Order Settings', 'Set up bulk order pricing and policies');
  }

  void _showProduceSettings() {
    _showSettingsDialog('Fresh Produce Settings', 'Configure produce categories and expiry tracking');
  }

  void _showDairySettings() {
    _showSettingsDialog('Dairy Management Settings', 'Set up dairy product tracking and alerts');
  }

  void _showLoyaltySettings() {
    _showSettingsDialog('Loyalty Program Settings', 'Configure loyalty program tiers and rewards');
  }

  void _showExpirySettings() {
    _showSettingsDialog('Expiry Tracking Settings', 'Set up expiry date alerts and management');
  }

  void _showBusinessProfileSettings() {
    _showSettingsDialog('Business Profile Settings', 'Configure business information and branding');
  }

  void _showInventorySettings() {
    _showSettingsDialog('Inventory Settings', 'Configure inventory management and alerts');
  }

  void _showCustomerSettings() {
    _showSettingsDialog('Customer Management Settings', 'Configure customer data and preferences');
  }

  void _showReportingSettings() {
    _showSettingsDialog('Reporting Settings', 'Configure report templates and schedules');
  }

  void _showSettingsDialog(String title, String description) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Settings updated'),
                  backgroundColor: _getCategoryColor(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _getCategoryColor(),
              foregroundColor: AppTheme.snow,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // General setting methods
  void _showNotificationPreferences() {
    _showSettingsDialog('Notification Preferences', 'Configure notification types and frequency');
  }

  void _showEmailSettings() {
    _showSettingsDialog('Email Settings', 'Configure email notification preferences');
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Data export started'),
        backgroundColor: _getCategoryColor(),
      ),
    );
  }

  void _importData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Data import started'),
        backgroundColor: _getCategoryColor(),
      ),
    );
  }

  void _showPrivacySettings() {
    _showSettingsDialog('Privacy Settings', 'Manage data privacy and security settings');
  }

  void _showHelpCenter() {
    _showSettingsDialog('Help Center', 'Access tutorials and frequently asked questions');
  }

  void _contactSupport() {
    _showSettingsDialog('Contact Support', 'Get in touch with our support team');
  }

  void _sendFeedback() {
    _showSettingsDialog('Send Feedback', 'Share your thoughts and suggestions with us');
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Invoice App'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            const SizedBox(height: 8),
            Text('Business Type: ${_selectedCategory.displayName}'),
            const SizedBox(height: 8),
            Text('A professional invoice management app designed for local merchants.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Settings saved successfully'),
        backgroundColor: _getCategoryColor(),
      ),
    );
  }

  Color _getCategoryColor() {
    switch (_selectedCategory) {
      case BusinessCategory.jewelryStore:
        return AppTheme.rausch;
      case BusinessCategory.restaurantCafe:
        return AppTheme.babu;
      case BusinessCategory.clothingStore:
        return AppTheme.arches;
      case BusinessCategory.electronicsStore:
        return Colors.indigo;
      case BusinessCategory.hardwareStore:
        return Colors.orange;
      case BusinessCategory.bakery:
        return Colors.brown;
      case BusinessCategory.stationeryStore:
        return Colors.teal;
      case BusinessCategory.groceryStore:
        return Colors.green;
      default:
        return AppTheme.rausch;
    }
  }
}