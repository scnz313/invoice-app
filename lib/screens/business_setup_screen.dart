import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/business_category.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'main_navigation_screen.dart';

class BusinessSetupScreen extends StatefulWidget {
  final BusinessCategoryData category;
  
  const BusinessSetupScreen({
    super.key,
    required this.category,
  });

  @override
  State<BusinessSetupScreen> createState() => _BusinessSetupScreenState();
}

class _BusinessSetupScreenState extends State<BusinessSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _gstNumberController = TextEditingController();
  final _panNumberController = TextEditingController();
  
  File? _logoFile;
  int _currentStep = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill some fields based on category
    _gstNumberController.text = widget.category.defaultTaxRate.toString();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _gstNumberController.dispose();
    _panNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ghost,
      appBar: AppBar(
        title: Text('Setup ${widget.category.displayName}'),
        backgroundColor: AppTheme.snow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            color: AppTheme.snow,
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Step ${_currentStep + 1} of 3',
                      style: AppTheme.body2.copyWith(
                        color: AppTheme.foggy,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${((_currentStep + 1) / 3 * 100).round()}%',
                      style: AppTheme.body2.copyWith(
                        color: AppTheme.rausch,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing12),
                LinearProgressIndicator(
                  value: (_currentStep + 1) / 3,
                  backgroundColor: AppTheme.foggy.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(widget.category.color),
                ),
              ],
            ),
          ),
          
          // Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              child: Form(
                key: _formKey,
                child: _buildCurrentStep(),
              ),
            ),
          ),
          
          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing24),
            color: AppTheme.snow,
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radius12),
                        ),
                      ),
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: AppTheme.spacing16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.category.color,
                      foregroundColor: AppTheme.snow,
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radius12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.snow),
                            ),
                          )
                        : Text(_currentStep == 2 ? 'Complete Setup' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildContactInfoStep();
      case 2:
        return _buildBusinessDetailsStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: widget.category.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radius12),
              ),
              child: Icon(
                widget.category.icon,
                color: widget.category.color,
                size: 24,
              ),
            ),
            const SizedBox(width: AppTheme.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Basic Information',
                    style: AppTheme.headline4.copyWith(
                      color: AppTheme.hof,
                    ),
                  ),
                  Text(
                    'Tell us about your business',
                    style: AppTheme.body2.copyWith(
                      color: AppTheme.foggy,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing32),
        
        // Business Logo
        Center(
          child: GestureDetector(
            onTap: _pickLogo,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.snow,
                borderRadius: BorderRadius.circular(AppTheme.radius16),
                border: Border.all(
                  color: AppTheme.foggy.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: _logoFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radius14),
                      child: Image.file(
                        _logoFile!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo,
                          size: 32,
                          color: AppTheme.foggy,
                        ),
                        const SizedBox(height: AppTheme.spacing8),
                        Text(
                          'Add Logo',
                          style: AppTheme.caption.copyWith(
                            color: AppTheme.foggy,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacing32),
        
        // Business Name
        TextFormField(
          controller: _businessNameController,
          decoration: const InputDecoration(
            labelText: 'Business Name *',
            hintText: 'Enter your business name',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Business name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: AppTheme.spacing20),
        
        // Owner Name
        TextFormField(
          controller: _ownerNameController,
          decoration: const InputDecoration(
            labelText: 'Owner Name *',
            hintText: 'Enter owner/proprietor name',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Owner name is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildContactInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: widget.category.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radius12),
              ),
              child: Icon(
                Icons.contact_phone,
                color: widget.category.color,
                size: 24,
              ),
            ),
            const SizedBox(width: AppTheme.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Information',
                    style: AppTheme.headline4.copyWith(
                      color: AppTheme.hof,
                    ),
                  ),
                  Text(
                    'How can customers reach you?',
                    style: AppTheme.body2.copyWith(
                      color: AppTheme.foggy,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing32),
        
        // Phone Number
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number *',
            hintText: 'Enter business phone number',
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Phone number is required';
            }
            if (value.length < 10) {
              return 'Please enter a valid phone number';
            }
            return null;
          },
        ),
        const SizedBox(height: AppTheme.spacing20),
        
        // Email
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email Address',
            hintText: 'Enter business email (optional)',
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email address';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: AppTheme.spacing20),
        
        // Address
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Business Address *',
            hintText: 'Enter complete business address',
            prefixIcon: Icon(Icons.location_on),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Business address is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBusinessDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: widget.category.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radius12),
              ),
              child: Icon(
                Icons.business,
                color: widget.category.color,
                size: 24,
              ),
            ),
            const SizedBox(width: AppTheme.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Business Details',
                    style: AppTheme.headline4.copyWith(
                      color: AppTheme.hof,
                    ),
                  ),
                  Text(
                    'Legal and tax information',
                    style: AppTheme.body2.copyWith(
                      color: AppTheme.foggy,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing32),
        
        // GST Number
        TextFormField(
          controller: _gstNumberController,
          decoration: const InputDecoration(
            labelText: 'GST Number',
            hintText: 'Enter GST number (optional)',
            prefixIcon: Icon(Icons.receipt),
          ),
        ),
        const SizedBox(height: AppTheme.spacing20),
        
        // PAN Number
        TextFormField(
          controller: _panNumberController,
          decoration: const InputDecoration(
            labelText: 'PAN Number',
            hintText: 'Enter PAN number (optional)',
            prefixIcon: Icon(Icons.credit_card),
          ),
        ),
        const SizedBox(height: AppTheme.spacing32),
        
        // Category-specific information
        Container(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          decoration: BoxDecoration(
            color: widget.category.color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(AppTheme.radius12),
            border: Border.all(
              color: widget.category.color.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    widget.category.icon,
                    color: widget.category.color,
                    size: 20,
                  ),
                  const SizedBox(width: AppTheme.spacing8),
                  Text(
                    '${widget.category.displayName} Features',
                    style: AppTheme.body1.copyWith(
                      fontWeight: FontWeight.w600,
                      color: widget.category.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing12),
              Text(
                'Default tax rate: ${widget.category.defaultTaxRate}%',
                style: AppTheme.body2.copyWith(
                  color: AppTheme.foggy,
                ),
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                'You\'ll have access to ${widget.category.features.length} category-specific features',
                style: AppTheme.body2.copyWith(
                  color: AppTheme.foggy,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickLogo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
    );
    
    if (image != null) {
      setState(() {
        _logoFile = File(image.path);
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _nextStep() async {
    if (_currentStep < 2) {
      if (_formKey.currentState!.validate()) {
        setState(() {
          _currentStep++;
        });
      }
    } else {
      await _completeSetup();
    }
  }

  Future<void> _completeSetup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate setup process
      await Future.delayed(const Duration(seconds: 2));
      
      // Complete onboarding
      final settingsProvider = context.read<SettingsProvider>();
      await settingsProvider.completeOnboarding(widget.category.category);
      
      // Save business information (you would implement this with your data layer)
      // await BusinessService.saveBusinessInfo(...);
      
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MainNavigationScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: AppTheme.normalAnimation,
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error setting up business: $e'),
            backgroundColor: AppTheme.rausch,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}