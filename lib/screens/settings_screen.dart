import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';
import '../models/company_settings.dart';
import '../services/feature_flags.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late FeatureFlags _featureFlags;

  @override
  void initState() {
    super.initState();
    _featureFlags = FeatureFlags.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Company Information'),
          _buildCompanyCard(),
          
          const SizedBox(height: 24),
          _buildSectionTitle('Appearance'),
          _buildThemeCard(),
          
          const SizedBox(height: 24),
          _buildSectionTitle('Features'),
          _buildFeatureFlags(),
          
          const SizedBox(height: 24),
          _buildSectionTitle('About App'),
          _buildAboutCard(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: context.colors.onSurface,
        ),
      ),
    );
  }

  Widget _buildCompanyCard() {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final settings = settingsProvider.companySettings;
        return Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.business,
                  color: context.colors.primary,
                ),
                title: Text(
                  settings.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Company details'),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
                onTap: () => _showCompanySettingsDialog(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.location_on, settings.address),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.email, settings.email),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.phone, settings.phone),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeCard() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: context.colors.primary,
                ),
                title: const Text('Theme Mode'),
                subtitle: Text(_getThemeModeText(themeProvider.themeMode)),
                trailing: PopupMenuButton<ThemeMode>(
                  icon: const Icon(Icons.arrow_drop_down),
                  onSelected: (ThemeMode mode) {
                    themeProvider.setThemeMode(mode);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: ThemeMode.system,
                      child: Text('System'),
                    ),
                    const PopupMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light'),
                    ),
                    const PopupMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureFlags() {
    return Card(
      child: Column(
        children: [
          _buildFeatureToggle(
            'Advanced Reports',
            'Detailed analytics and insights',
            Icons.analytics,
            _featureFlags.isAdvancedReportsEnabled,
            (value) async {
              await _featureFlags.setAdvancedReportsEnabled(value);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureToggle(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Future<void> Function(bool) onChanged, {
    bool disabled = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: disabled ? Colors.grey : context.colors.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: disabled ? Colors.grey : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: disabled ? Colors.grey : null,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: disabled ? null : (newValue) => onChanged(newValue),
      ),
    );
  }

  Widget _buildAboutCard() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.info_outline,
              color: context.colors.primary,
            ),
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.person,
              color: context.colors.primary,
            ),
            title: const Text('Developer'),
            subtitle: const Text('HASHIM (fin.)'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.restore,
              color: context.colors.error,
            ),
            title: const Text('Reset Settings'),
            subtitle: const Text('Restore default settings'),
            onTap: () => _showResetDialog(context),
          ),
        ],
      ),
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Follow system';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('This will restore all settings to their default values. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _featureFlags.resetToDefaults();
              if (mounted) {
                Navigator.pop(context);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings reset to defaults'),
                  ),
                );
              }
            },
            child: Text(
              'Reset',
              style: TextStyle(color: context.colors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showCompanySettingsDialog() {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final settings = settingsProvider.companySettings;
    
    final nameController = TextEditingController(text: settings.name);
    final addressController = TextEditingController(text: settings.address);
    final phoneController = TextEditingController(text: settings.phone);
    final emailController = TextEditingController(text: settings.email);
    final bankNameController = TextEditingController(text: settings.bankName);
    final bankAccountController = TextEditingController(text: settings.bankAccount);
    final bankIFSCController = TextEditingController(text: settings.bankIFSC);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Company Settings'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Company Name',
                    prefixIcon: Icon(Icons.business),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: bankNameController,
                  decoration: const InputDecoration(
                    labelText: 'Bank Name',
                    prefixIcon: Icon(Icons.account_balance),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: bankAccountController,
                  decoration: const InputDecoration(
                    labelText: 'Bank Account Number',
                    prefixIcon: Icon(Icons.credit_card),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: bankIFSCController,
                  decoration: const InputDecoration(
                    labelText: 'Bank IFSC Code',
                    prefixIcon: Icon(Icons.code),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newSettings = CompanySettings(
                name: nameController.text.trim(),
                address: addressController.text.trim(),
                phone: phoneController.text.trim(),
                email: emailController.text.trim(),
                bankName: bankNameController.text.trim(),
                bankAccount: bankAccountController.text.trim(),
                bankIFSC: bankIFSCController.text.trim(),
              );

              await settingsProvider.updateCompanySettings(newSettings);
              
              if (mounted) {
                Navigator.pop(context);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Company settings updated successfully'),
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
} 