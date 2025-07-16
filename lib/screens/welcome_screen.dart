import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_theme.dart';
import 'category_selection_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _bounceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: AppTheme.slowAnimation,
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: AppTheme.normalAnimation,
      vsync: this,
    );
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
    
    await Future.delayed(const Duration(milliseconds: 500));
    _slideController.forward();
    
    await Future.delayed(const Duration(milliseconds: 300));
    _bounceController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.rausch.withOpacity(0.1),
              AppTheme.babu.withOpacity(0.05),
              AppTheme.ghost,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildHeroSection(),
                ),
              ),
              Expanded(
                flex: 2,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildContentSection(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App Logo/Icon
          ScaleTransition(
            scale: _bounceAnimation,
            child: Container(
              width: 120,
              height: 120,
              decoration: AppTheme.gradientDecoration,
              child: const Icon(
                Icons.receipt_long,
                size: 60,
                color: AppTheme.snow,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacing32),
          
          // App Name
          Text(
            'Invoice',
            style: AppTheme.headline1.copyWith(
              color: AppTheme.hof,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppTheme.spacing8),
          
          // Tagline
          Text(
            'Invoice made simple for local merchants',
            style: AppTheme.body1.copyWith(
              color: AppTheme.foggy,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Features list
          _buildFeatureItem(
            icon: Icons.store,
            title: 'Business Category Specific',
            description: 'Tailored features for your business type',
          ),
          const SizedBox(height: AppTheme.spacing20),
          
          _buildFeatureItem(
            icon: Icons.offline_bolt,
            title: 'Works Offline',
            description: 'No internet required for daily operations',
          ),
          const SizedBox(height: AppTheme.spacing20),
          
          _buildFeatureItem(
            icon: Icons.analytics,
            title: 'Smart Analytics',
            description: 'Track sales, customers, and business growth',
          ),
          const SizedBox(height: AppTheme.spacing40),
          
          // Get Started Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const CategorySelectionScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      );
                    },
                    transitionDuration: AppTheme.normalAnimation,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.rausch,
                foregroundColor: AppTheme.snow,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radius16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing8),
                  const Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.snow,
        borderRadius: BorderRadius.circular(AppTheme.radius16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.hof.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.rausch.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radius12),
            ),
            child: Icon(
              icon,
              color: AppTheme.rausch,
              size: 24,
            ),
          ),
          const SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.body1.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.hof,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing4),
                Text(
                  description,
                  style: AppTheme.body2.copyWith(
                    color: AppTheme.foggy,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}