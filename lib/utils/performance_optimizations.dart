import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Performance optimization utilities for production builds
class PerformanceOptimizations {
  /// Conditionally disable debug animations in production
  static bool get shouldUseAnimations => kDebugMode;
  
  /// Reduced animation duration for production
  static Duration get optimizedAnimationDuration => 
      kDebugMode ? const Duration(milliseconds: 300) : const Duration(milliseconds: 150);
  
  /// Optimized scroll physics for better performance
  static ScrollPhysics get optimizedScrollPhysics => 
      kDebugMode ? const ClampingScrollPhysics() : const BouncingScrollPhysics();
  
  /// Memory-efficient image caching
  static int get maxImageCacheSize => kDebugMode ? 100 : 50;
  
  /// Optimized list view settings
  static bool get shouldCacheExtent => !kDebugMode;
  static double get cacheExtent => kDebugMode ? 250.0 : 500.0;
}

/// Optimized StatelessWidget that conditionally enables performance features
abstract class OptimizedStatelessWidget extends StatelessWidget {
  const OptimizedStatelessWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      // In production, wrap with RepaintBoundary for better performance
      return RepaintBoundary(child: buildOptimized(context));
    }
    return buildOptimized(context);
  }
  
  Widget buildOptimized(BuildContext context);
}

/// Optimized StatefulWidget that conditionally enables performance features
abstract class OptimizedStatefulWidget extends StatefulWidget {
  const OptimizedStatefulWidget({super.key});
  
  @override
  State<OptimizedStatefulWidget> createState() => createOptimizedState();
  
  State<OptimizedStatefulWidget> createOptimizedState();
}

/// Mixin for performance-optimized state management
mixin PerformanceOptimizedState<T extends StatefulWidget> on State<T> {
  bool _mounted = true;
  
  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }
  
  /// Safe setState that checks if widget is still mounted
  void safeSetState(VoidCallback fn) {
    if (_mounted && mounted) {
      setState(fn);
    }
  }
  
  /// Debounced setState for frequent updates
  void debouncedSetState(VoidCallback fn, [Duration delay = const Duration(milliseconds: 16)]) {
    Future.delayed(delay, () {
      if (_mounted && mounted) {
        setState(fn);
      }
    });
  }
}

/// Optimized ListView builder for large datasets
class OptimizedListView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final ScrollController? controller;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  
  const OptimizedListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics ?? PerformanceOptimizations.optimizedScrollPhysics,
      cacheExtent: PerformanceOptimizations.shouldCacheExtent ? PerformanceOptimizations.cacheExtent : null,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (!kDebugMode) {
          // In production, wrap items with OptimizedKeepAliveWidget for better scrolling performance
          return OptimizedKeepAliveWidget(
            child: itemBuilder(context, index),
          );
        }
        return itemBuilder(context, index);
      },
    );
  }
}

/// Widget that automatically keeps alive its child for performance
class OptimizedKeepAliveWidget extends StatefulWidget {
  final Widget child;
  
  const OptimizedKeepAliveWidget({super.key, required this.child});
  
  @override
  State<OptimizedKeepAliveWidget> createState() => _OptimizedKeepAliveWidgetState();
}

class _OptimizedKeepAliveWidgetState extends State<OptimizedKeepAliveWidget> 
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

/// Optimized AnimatedSwitcher with reduced animations in production
class OptimizedAnimatedSwitcher extends StatelessWidget {
  final Widget child;
  final Duration? duration;
  final Widget Function(Widget, Animation<double>)? transitionBuilder;
  
  const OptimizedAnimatedSwitcher({
    super.key,
    required this.child,
    this.duration,
    this.transitionBuilder,
  });
  
  @override
  Widget build(BuildContext context) {
    if (!PerformanceOptimizations.shouldUseAnimations) {
      return child;
    }
    
    return AnimatedSwitcher(
      duration: duration ?? PerformanceOptimizations.optimizedAnimationDuration,
      transitionBuilder: transitionBuilder ?? AnimatedSwitcher.defaultTransitionBuilder,
      child: child,
    );
  }
}

/// Memory-efficient image widget with optimized caching
class OptimizedImage extends StatelessWidget {
  final String? imageUrl;
  final String? assetPath;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  
  const OptimizedImage({
    super.key,
    this.imageUrl,
    this.assetPath,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
  });
  
  @override
  Widget build(BuildContext context) {
    if (assetPath != null) {
      return Image.asset(
        assetPath!,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: !kDebugMode ? (width?.toInt()) : null,
        cacheHeight: !kDebugMode ? (height?.toInt()) : null,
        errorBuilder: errorWidget != null ? (_, __, ___) => errorWidget! : null,
      );
    }
    
    if (imageUrl != null) {
      return Image.network(
        imageUrl!,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: !kDebugMode ? (width?.toInt()) : null,
        cacheHeight: !kDebugMode ? (height?.toInt()) : null,
        loadingBuilder: placeholder != null 
            ? (_, __, ___) => placeholder!
            : null,
        errorBuilder: errorWidget != null 
            ? (_, __, ___) => errorWidget!
            : null,
      );
    }
    
    return errorWidget ?? const SizedBox.shrink();
  }
} 