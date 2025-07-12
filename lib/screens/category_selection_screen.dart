import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/business_category.dart';
import '../theme/app_theme.dart';
import 'business_setup_screen.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<BusinessCategoryData> _allCategories = [];
  List<BusinessCategoryData> _filteredCategories = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _allCategories = BusinessCategoryData.getAllCategories();
    _filteredCategories = _allCategories;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredCategories = _allCategories;
      } else {
        _filteredCategories = _allCategories.where((category) {
          return category.displayName.toLowerCase().contains(_searchQuery) ||
                 category.description.toLowerCase().contains(_searchQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ghost,
      appBar: AppBar(
        title: const Text('Choose Your Business'),
        backgroundColor: AppTheme.snow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            color: AppTheme.snow,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search business categories...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.foggy),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppTheme.foggy),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radius12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppTheme.ghost,
              ),
            ),
          ),
          
          // Categories Grid
          Expanded(
            child: _filteredCategories.isEmpty
                ? _buildEmptyState()
                : _buildCategoriesGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppTheme.foggy,
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            'No categories found',
            style: AppTheme.headline4.copyWith(color: AppTheme.foggy),
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            'Try adjusting your search terms',
            style: AppTheme.body2.copyWith(color: AppTheme.foggy),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return AnimationLimiter(
      child: GridView.builder(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: AppTheme.spacing16,
          mainAxisSpacing: AppTheme.spacing16,
        ),
        itemCount: _filteredCategories.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: AppTheme.normalAnimation,
            columnCount: 2,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: _buildCategoryCard(_filteredCategories[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(BusinessCategoryData category) {
    return GestureDetector(
      onTap: () => _onCategorySelected(category),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.snow,
          borderRadius: BorderRadius.circular(AppTheme.radius16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.hof.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTheme.radius16),
            onTap: () => _onCategorySelected(category),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Category Icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radius16),
                    ),
                    child: Icon(
                      category.icon,
                      size: 32,
                      color: category.color,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  
                  // Category Name
                  Text(
                    category.displayName,
                    style: AppTheme.body1.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.hof,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  
                  // Category Description
                  Text(
                    category.description,
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.foggy,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onCategorySelected(BusinessCategoryData category) {
    // Show category details modal
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCategoryDetailsModal(category),
    );
  }

  Widget _buildCategoryDetailsModal(BusinessCategoryData category) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppTheme.snow,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppTheme.radius24),
          topRight: Radius.circular(AppTheme.radius24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: AppTheme.spacing12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.foggy.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing24),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radius12),
                  ),
                  child: Icon(
                    category.icon,
                    color: category.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppTheme.spacing16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.displayName,
                        style: AppTheme.headline4.copyWith(
                          color: AppTheme.hof,
                        ),
                      ),
                      Text(
                        'Default Tax Rate: ${category.defaultTaxRate}%',
                        style: AppTheme.body2.copyWith(
                          color: AppTheme.foggy,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Features List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing24),
              itemCount: category.features.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacing12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: category.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing12),
                      Expanded(
                        child: Text(
                          category.features[index],
                          style: AppTheme.body2.copyWith(
                            color: AppTheme.hof,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radius12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              BusinessSetupScreen(category: category),
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
                      backgroundColor: category.color,
                      foregroundColor: AppTheme.snow,
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radius12),
                      ),
                    ),
                    child: const Text('Select This Category'),
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