import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';
import '../models/company_settings.dart';
import '../services/feature_flags.dart';
import '../services/image_service.dart';
import '../theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late FeatureFlags _featureFlags;
  final ImageService _imageService = ImageService();

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
                                          color: context.colors.onSurfaceVariant,
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
          color: context.colors.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: context.colors.onSurfaceVariant,
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
        color: disabled ? context.colors.onSurfaceVariant : context.colors.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: disabled ? context.colors.onSurfaceVariant : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: disabled ? context.colors.onSurfaceVariant : null,
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
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.delete_forever,
              color: context.colors.error,
            ),
            title: const Text('Clear All Data'),
            subtitle: const Text('Emergency: Clear all app data and restart'),
            onTap: () => _showClearAllDataDialog(context),
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
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Settings'),
          content: const Text(
            'Are you sure you want to reset all settings to their default values? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                // Reset all providers to defaults
                if (context.mounted) {
                  await context.read<SettingsProvider>().resetToDefaults();
                  await context.read<ThemeProvider>().setThemeMode(ThemeMode.system);
                  await FeatureFlags.instance.resetToDefaults();
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Settings reset to defaults')),
                    );
                  }
                }
              },
              style: TextButton.styleFrom(foregroundColor: context.colors.error),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  void _showClearAllDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Data'),
          content: const Text(
            'This will permanently delete ALL app data including:\n\n'
            '• All invoices\n'
            '• All clients\n'
            '• All settings\n'
            '• App preferences\n\n'
            'This action cannot be undone and the app will restart.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                // Show loading dialog
                if (context.mounted) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const AlertDialog(
                      content: Row(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 16),
                          Text('Clearing data...'),
                        ],
                      ),
                    ),
                  );
                  
                  try {
                    // Clear all SharedPreferences data
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    
                    // Show success and restart
                    if (context.mounted) {
                      Navigator.of(context).pop(); // Close loading dialog
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('All data cleared. App will restart...'),
                          backgroundColor: context.colors.tertiary,
                        ),
                      );
                      
                      // Restart the app after a brief delay
                      await Future.delayed(const Duration(seconds: 1));
                      if (context.mounted) {
                        // Force app restart by navigating to a new instance of the main app
                        runApp(
                          MaterialApp(
                            home: Scaffold(
                              body: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const CircularProgressIndicator(),
                                    const SizedBox(height: 16),
                                    const Text('Restarting app...'),
                                    const SizedBox(height: 32),
                                    ElevatedButton(
                                      onPressed: () {
                                        // Manual restart trigger
                                        SystemNavigator.pop();
                                      },
                                      child: const Text('Tap to complete restart'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.of(context).pop(); // Close loading dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error clearing data: $e'),
                          backgroundColor: context.colors.error,
                        ),
                      );
                    }
                  }
                }
              },
              style: TextButton.styleFrom(foregroundColor: context.colors.error),
              child: const Text('CLEAR ALL DATA'),
            ),
          ],
        );
      },
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
      builder: (context) => _CompanySettingsDialog(
        nameController: nameController,
        addressController: addressController,
        phoneController: phoneController,
        emailController: emailController,
        bankNameController: bankNameController,
        bankAccountController: bankAccountController,
        bankIFSCController: bankIFSCController,
        currentSettings: settings,
        imageService: _imageService,
        onSave: (newSettings) async {
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
      ),
    );
  }
}

class _CompanySettingsDialog extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController addressController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController bankNameController;
  final TextEditingController bankAccountController;
  final TextEditingController bankIFSCController;
  final CompanySettings currentSettings;
  final ImageService imageService;
  final Function(CompanySettings) onSave;

  const _CompanySettingsDialog({
    required this.nameController,
    required this.addressController,
    required this.phoneController,
    required this.emailController,
    required this.bankNameController,
    required this.bankAccountController,
    required this.bankIFSCController,
    required this.currentSettings,
    required this.imageService,
    required this.onSave,
  });

  @override
  State<_CompanySettingsDialog> createState() => _CompanySettingsDialogState();
}

class _CompanySettingsDialogState extends State<_CompanySettingsDialog> {
  String? _selectedLogoPath;
  bool _isUploadingLogo = false;

  @override
  void initState() {
    super.initState();
    _selectedLogoPath = widget.currentSettings.logoPath;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Company Settings'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Company Logo Section
              _buildLogoSection(),
              const SizedBox(height: 24),
              
              // Company Details
              TextField(
                controller: widget.nameController,
                decoration: const InputDecoration(
                  labelText: 'Company Name',
                  prefixIcon: Icon(Icons.business),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: widget.addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: widget.phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: widget.emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: widget.bankNameController,
                decoration: const InputDecoration(
                  labelText: 'Bank Name',
                  prefixIcon: Icon(Icons.account_balance),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: widget.bankAccountController,
                decoration: const InputDecoration(
                  labelText: 'Bank Account Number',
                  prefixIcon: Icon(Icons.credit_card),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: widget.bankIFSCController,
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
          onPressed: _isUploadingLogo ? null : _handleSave,
          child: _isUploadingLogo 
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildLogoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.image, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Company Logo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Logo Preview
          Center(
            child: Container(
              width: 120,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade50,
              ),
              child: _buildLogoPreview(),
            ),
          ),
          const SizedBox(height: 12),
          
          // Logo Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _isUploadingLogo ? null : _pickLogo,
                icon: const Icon(Icons.upload, size: 18),
                label: const Text('Upload'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
              if (_selectedLogoPath != null && _selectedLogoPath!.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: _isUploadingLogo ? null : _removeLogo,
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Remove'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Recommended: PNG or JPG, max 2MB, 1024x1024px',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoPreview() {
    if (_isUploadingLogo) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_selectedLogoPath != null && _selectedLogoPath!.isNotEmpty) {
      final file = File(_selectedLogoPath!);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.file(
            file,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder();
            },
          ),
        );
      }
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade400,
            Colors.blue.shade600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Center(
        child: Text(
          'LOGO',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Future<void> _pickLogo() async {
    try {
      setState(() {
        _isUploadingLogo = true;
      });

      final logoPath = await widget.imageService.pickCompanyLogo();
      if (logoPath != null) {
        setState(() {
          _selectedLogoPath = logoPath;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logo uploaded successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      // Extract the actual error message
      String errorMessage = e.toString();
      if (e.toString().contains('ImageValidationException:')) {
        errorMessage = e.toString().replaceAll('ImageValidationException: ', '');
      } else if (e.toString().contains('ImageSaveException:')) {
        errorMessage = e.toString().replaceAll('ImageSaveException: ', '');
      } else if (e.toString().contains('Exception:')) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload logo: $errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingLogo = false;
        });
      }
    }
  }

  Future<void> _removeLogo() async {
    try {
      if (_selectedLogoPath != null && _selectedLogoPath!.isNotEmpty) {
        await widget.imageService.deleteImage(_selectedLogoPath!);
      }
      
      setState(() {
        _selectedLogoPath = null;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logo removed successfully'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove logo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleSave() async {
    final newSettings = CompanySettings(
      name: widget.nameController.text.trim(),
      address: widget.addressController.text.trim(),
      phone: widget.phoneController.text.trim(),
      email: widget.emailController.text.trim(),
      bankName: widget.bankNameController.text.trim(),
      bankAccount: widget.bankAccountController.text.trim(),
      bankIFSC: widget.bankIFSCController.text.trim(),
      logoPath: _selectedLogoPath,
    );

    widget.onSave(newSettings);
  }
}