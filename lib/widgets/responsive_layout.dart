import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// A comprehensive responsive layout system that adapts to different screen sizes,
/// orientations, and platforms.
class ResponsiveLayout extends StatelessWidget {
  /// Widget to display on mobile devices (small screens)
  final Widget mobile;
  
  /// Widget to display on tablet devices (medium screens)
  final Widget? tablet;
  
  /// Widget to display on desktop devices (large screens)
  final Widget? desktop;
  
  /// Widget to display on large desktop devices (extra large screens)
  final Widget? largeDesktop;
  
  /// Custom breakpoints to override the default ones
  final ResponsiveBreakpoints? breakpoints;
  
  /// Whether to use the device's physical size rather than the window size
  /// This is useful for web applications
  final bool useDeviceSize;
  
  /// Whether to consider the device orientation when determining the layout
  final bool considerOrientation;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
    this.breakpoints,
    this.useDeviceSize = false,
    this.considerOrientation = true,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final breakpoints = this.breakpoints ?? ResponsiveBreakpoints.standard();
    
    // Get the effective screen size based on settings
    final size = useDeviceSize ? mediaQuery.size : mediaQuery.size;
    final orientation = mediaQuery.orientation;
    
    // Determine the width to use for breakpoint calculations
    final width = considerOrientation && orientation == Orientation.portrait
        ? size.width
        : size.height;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use the most constrained dimension between the layout constraints
        // and the screen size for the most accurate responsive behavior
        final effectiveWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : width;
        
        if (effectiveWidth >= breakpoints.largeDesktop) {
          return largeDesktop ?? desktop ?? tablet ?? mobile;
        } else if (effectiveWidth >= breakpoints.desktop) {
          return desktop ?? tablet ?? mobile;
        } else if (effectiveWidth >= breakpoints.tablet) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Defines the breakpoints for different device sizes
class ResponsiveBreakpoints {
  /// Breakpoint for mobile devices (small screens)
  final double mobile;
  
  /// Breakpoint for tablet devices (medium screens)
  final double tablet;
  
  /// Breakpoint for desktop devices (large screens)
  final double desktop;
  
  /// Breakpoint for large desktop devices (extra large screens)
  final double largeDesktop;

  const ResponsiveBreakpoints({
    required this.mobile,
    required this.tablet,
    required this.desktop,
    required this.largeDesktop,
  });

  /// Standard breakpoints based on Material Design guidelines
  factory ResponsiveBreakpoints.standard() {
    return const ResponsiveBreakpoints(
      mobile: 600,
      tablet: 905,
      desktop: 1240,
      largeDesktop: 1440,
    );
  }
  
  /// Breakpoints optimized for dashboard layouts
  factory ResponsiveBreakpoints.dashboard() {
    return const ResponsiveBreakpoints(
      mobile: 650,
      tablet: 960,
      desktop: 1280,
      largeDesktop: 1600,
    );
  }
  
  /// Breakpoints optimized for content-heavy applications
  factory ResponsiveBreakpoints.contentFocused() {
    return const ResponsiveBreakpoints(
      mobile: 480,
      tablet: 800,
      desktop: 1100,
      largeDesktop: 1500,
    );
  }
  
  /// Breakpoints optimized for form-based applications
  factory ResponsiveBreakpoints.formFocused() {
    return const ResponsiveBreakpoints(
      mobile: 550,
      tablet: 850,
      desktop: 1200,
      largeDesktop: 1400,
    );
  }
}

/// Extension methods for BuildContext to easily check the current device type
extension ResponsiveContext on BuildContext {
  /// The current MediaQuery data
  MediaQueryData get _mediaQuery => MediaQuery.of(this);
  
  /// The current screen size
  Size get screenSize => _mediaQuery.size;
  
  /// The current screen width
  double get width => screenSize.width;
  
  /// The current screen height
  double get height => screenSize.height;
  
  /// The current screen orientation
  Orientation get orientation => _mediaQuery.orientation;
  
  /// Whether the device is in portrait mode
  bool get isPortrait => orientation == Orientation.portrait;
  
  /// Whether the device is in landscape mode
  bool get isLandscape => orientation == Orientation.landscape;
  
  /// Whether the current platform is mobile (iOS or Android)
  bool get isMobilePlatform => !kIsWeb && (Platform.isIOS || Platform.isAndroid);
  
  /// Whether the current platform is desktop (Windows, macOS, or Linux)
  bool get isDesktopPlatform => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
  
  /// Whether the current platform is web
  bool get isWebPlatform => kIsWeb;
  
  /// Whether the current screen size is mobile (small)
  bool get isMobile => width < ResponsiveBreakpoints.standard().tablet;
  
  /// Whether the current screen size is tablet (medium)
  bool get isTablet => width >= ResponsiveBreakpoints.standard().tablet && 
                     width < ResponsiveBreakpoints.standard().desktop;
  
  /// Whether the current screen size is desktop (large)
  bool get isDesktop => width >= ResponsiveBreakpoints.standard().desktop &&
                      width < ResponsiveBreakpoints.standard().largeDesktop;
  
  /// Whether the current screen size is large desktop (extra large)
  bool get isLargeDesktop => width >= ResponsiveBreakpoints.standard().largeDesktop;
  
  /// Whether the current screen size is mobile or tablet
  bool get isMobileOrTablet => isMobile || isTablet;
  
  /// Whether the current screen size is tablet or desktop
  bool get isTabletOrDesktop => isTablet || isDesktop || isLargeDesktop;
  
  /// Whether the current screen is touch-based (mobile or tablet)
  bool get isTouchDevice => isMobilePlatform || isTablet;
  
  /// Get the appropriate value based on the current screen size
  T responsiveValue<T>({
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    if (isLargeDesktop) return largeDesktop ?? desktop ?? tablet ?? mobile;
    if (isDesktop) return desktop ?? tablet ?? mobile;
    if (isTablet) return tablet ?? mobile;
    return mobile;
  }
  
  /// Get the appropriate padding based on the current screen size
  EdgeInsets get responsivePadding => responsiveValue<EdgeInsets>(
    mobile: const EdgeInsets.all(16),
    tablet: const EdgeInsets.all(24),
    desktop: const EdgeInsets.all(32),
    largeDesktop: const EdgeInsets.all(48),
  );
  
  /// Get the appropriate horizontal padding based on the current screen size
  EdgeInsets get responsiveHorizontalPadding => responsiveValue<EdgeInsets>(
    mobile: const EdgeInsets.symmetric(horizontal: 16),
    tablet: const EdgeInsets.symmetric(horizontal: 24),
    desktop: const EdgeInsets.symmetric(horizontal: 32),
    largeDesktop: const EdgeInsets.symmetric(horizontal: 48),
  );
  
  /// Get the appropriate vertical padding based on the current screen size
  EdgeInsets get responsiveVerticalPadding => responsiveValue<EdgeInsets>(
    mobile: const EdgeInsets.symmetric(vertical: 16),
    tablet: const EdgeInsets.symmetric(vertical: 24),
    desktop: const EdgeInsets.symmetric(vertical: 32),
    largeDesktop: const EdgeInsets.symmetric(vertical: 48),
  );
  
  /// Get the appropriate font size for headlines based on the current screen size
  double get headlineFontSize => responsiveValue<double>(
    mobile: 24,
    tablet: 28,
    desktop: 32,
    largeDesktop: 36,
  );
  
  /// Get the appropriate font size for titles based on the current screen size
  double get titleFontSize => responsiveValue<double>(
    mobile: 18,
    tablet: 20,
    desktop: 22,
    largeDesktop: 24,
  );
  
  /// Get the appropriate font size for body text based on the current screen size
  double get bodyFontSize => responsiveValue<double>(
    mobile: 14,
    tablet: 15,
    desktop: 16,
    largeDesktop: 16,
  );
  
  /// Get the appropriate icon size based on the current screen size
  double get iconSize => responsiveValue<double>(
    mobile: 24,
    tablet: 28,
    desktop: 32,
    largeDesktop: 36,
  );
  
  /// Get the appropriate button height based on the current screen size
  double get buttonHeight => responsiveValue<double>(
    mobile: 44,
    tablet: 48,
    desktop: 52,
    largeDesktop: 56,
  );
}

/// A responsive grid layout that adapts to different screen sizes
class ResponsiveGrid extends StatelessWidget {
  /// The children to display in the grid
  final List<Widget> children;
  
  /// The number of columns for mobile devices (small screens)
  final int mobileColumns;
  
  /// The number of columns for tablet devices (medium screens)
  final int tabletColumns;
  
  /// The number of columns for desktop devices (large screens)
  final int desktopColumns;
  
  /// The number of columns for large desktop devices (extra large screens)
  final int largeDesktopColumns;
  
  /// The spacing between items
  final double spacing;
  
  /// The padding around the grid
  final EdgeInsets? padding;
  
  /// Whether to maintain aspect ratio for items
  final bool maintainAspectRatio;
  
  /// The aspect ratio for items (width / height)
  final double aspectRatio;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.largeDesktopColumns = 4,
    this.spacing = 16,
    this.padding,
    this.maintainAspectRatio = false,
    this.aspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = context.responsiveValue<int>(
          mobile: mobileColumns,
          tablet: tabletColumns,
          desktop: desktopColumns,
          largeDesktop: largeDesktopColumns,
        );
        
        return Padding(
          padding: padding ?? context.responsivePadding,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: maintainAspectRatio ? aspectRatio : 1.0,
            ),
            itemCount: children.length,
            itemBuilder: (context, index) => children[index],
          ),
        );
      },
    );
  }
}

/// A responsive container that adapts its width based on screen size
class ResponsiveContainer extends StatelessWidget {
  /// The child widget
  final Widget child;
  
  /// The maximum width for mobile devices (small screens)
  final double? mobileMaxWidth;
  
  /// The maximum width for tablet devices (medium screens)
  final double? tabletMaxWidth;
  
  /// The maximum width for desktop devices (large screens)
  final double? desktopMaxWidth;
  
  /// The maximum width for large desktop devices (extra large screens)
  final double? largeDesktopMaxWidth;
  
  /// The padding around the container
  final EdgeInsets? padding;
  
  /// The alignment of the container
  final Alignment alignment;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.mobileMaxWidth,
    this.tabletMaxWidth,
    this.desktopMaxWidth,
    this.largeDesktopMaxWidth,
    this.padding,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = context.responsiveValue<double?>(
      mobile: mobileMaxWidth,
      tablet: tabletMaxWidth,
      desktop: desktopMaxWidth,
      largeDesktop: largeDesktopMaxWidth,
    );
    
    return Container(
      constraints: maxWidth != null ? BoxConstraints(maxWidth: maxWidth) : null,
      padding: padding ?? context.responsivePadding,
      alignment: alignment,
      child: child,
    );
  }
}

/// A responsive navigation scaffold that adapts between bottom navigation (mobile)
/// and side navigation (tablet/desktop)
class ResponsiveNavigationScaffold extends StatelessWidget {
  /// The title of the app
  final String title;
  
  /// The pages/screens to display
  final List<ResponsiveNavigationDestination> destinations;
  
  /// The currently selected index
  final int selectedIndex;
  
  /// Callback when a destination is selected
  final ValueChanged<int> onDestinationSelected;
  
  /// The app bar to display (optional)
  final PreferredSizeWidget? appBar;
  
  /// The floating action button (optional)
  final Widget? floatingActionButton;
  
  /// The drawer to display on mobile (optional)
  final Widget? drawer;
  
  /// The end drawer to display on mobile (optional)
  final Widget? endDrawer;
  
  /// Whether to show the navigation rail on tablet
  final bool showNavigationRailOnTablet;
  
  /// Whether to show labels on the bottom navigation bar
  final bool showBottomNavigationLabels;
  
  /// The background color of the navigation
  final Color? navigationBackgroundColor;
  
  /// The selected item color
  final Color? selectedItemColor;
  
  /// The unselected item color
  final Color? unselectedItemColor;
  
  /// The width of the navigation rail/drawer
  final double navigationWidth;
  
  /// Whether to show the title in the navigation rail/drawer
  final bool showNavigationTitle;

  const ResponsiveNavigationScaffold({
    super.key,
    required this.title,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.appBar,
    this.floatingActionButton,
    this.drawer,
    this.endDrawer,
    this.showNavigationRailOnTablet = true,
    this.showBottomNavigationLabels = true,
    this.navigationBackgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.navigationWidth = 240,
    this.showNavigationTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(context),
      tablet: _buildTabletLayout(context),
      desktop: _buildDesktopLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      endDrawer: endDrawer,
      body: IndexedStack(
        index: selectedIndex,
        children: destinations.map((destination) => destination.screen).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onDestinationSelected,
        backgroundColor: navigationBackgroundColor,
        selectedItemColor: selectedItemColor ?? Theme.of(context).colorScheme.primary,
        unselectedItemColor: unselectedItemColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
        showSelectedLabels: showBottomNavigationLabels,
        showUnselectedLabels: showBottomNavigationLabels,
        type: BottomNavigationBarType.fixed,
        items: destinations.map((destination) => BottomNavigationBarItem(
          icon: Icon(destination.icon),
          activeIcon: Icon(destination.selectedIcon ?? destination.icon),
          label: destination.label,
        )).toList(),
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    if (!showNavigationRailOnTablet) {
      return _buildMobileLayout(context);
    }
    
    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      endDrawer: endDrawer,
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            backgroundColor: navigationBackgroundColor,
            selectedIconTheme: IconThemeData(
              color: selectedItemColor ?? Theme.of(context).colorScheme.primary,
            ),
            unselectedIconTheme: IconThemeData(
              color: unselectedItemColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            labelType: NavigationRailLabelType.selected,
            leading: showNavigationTitle ? Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ) : null,
            destinations: destinations.map((destination) => NavigationRailDestination(
              icon: Icon(destination.icon),
              selectedIcon: destination.selectedIcon != null 
                  ? Icon(destination.selectedIcon) 
                  : null,
              label: Text(destination.label),
            )).toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              children: destinations.map((destination) => destination.screen).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Row(
        children: [
          SizedBox(
            width: navigationWidth,
            child: Drawer(
              backgroundColor: navigationBackgroundColor,
              elevation: 0,
              child: Column(
                children: [
                  if (showNavigationTitle) Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: destinations.length,
                      itemBuilder: (context, index) {
                        final destination = destinations[index];
                        final isSelected = index == selectedIndex;
                        
                        return ListTile(
                          leading: Icon(
                            isSelected 
                                ? destination.selectedIcon ?? destination.icon 
                                : destination.icon,
                            color: isSelected
                                ? selectedItemColor ?? Theme.of(context).colorScheme.primary
                                : unselectedItemColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          title: Text(
                            destination.label,
                            style: TextStyle(
                              color: isSelected
                                  ? selectedItemColor ?? Theme.of(context).colorScheme.primary
                                  : unselectedItemColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedTileColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
                          onTap: () => onDestinationSelected(index),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              children: destinations.map((destination) => destination.screen).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

/// A destination for the responsive navigation scaffold
class ResponsiveNavigationDestination {
  /// The screen/page to display
  final Widget screen;
  
  /// The label for the destination
  final String label;
  
  /// The icon for the destination
  final IconData icon;
  
  /// The selected icon for the destination (optional)
  final IconData? selectedIcon;

  const ResponsiveNavigationDestination({
    required this.screen,
    required this.label,
    required this.icon,
    this.selectedIcon,
  });
}

/// A responsive dashboard layout that adapts to different screen sizes
class ResponsiveDashboardLayout extends StatelessWidget {
  /// The header widget
  final Widget header;
  
  /// The main content widget
  final Widget content;
  
  /// The sidebar widget (optional)
  final Widget? sidebar;
  
  /// The footer widget (optional)
  final Widget? footer;
  
  /// The spacing between elements
  final double spacing;
  
  /// The padding around the dashboard
  final EdgeInsets? padding;
  
  /// The sidebar width on desktop
  final double sidebarWidth;
  
  /// The sidebar position (left or right)
  final SidebarPosition sidebarPosition;
  
  /// Whether to collapse the sidebar on tablet
  final bool collapseSidebarOnTablet;

  const ResponsiveDashboardLayout({
    super.key,
    required this.header,
    required this.content,
    this.sidebar,
    this.footer,
    this.spacing = 16,
    this.padding,
    this.sidebarWidth = 280,
    this.sidebarPosition = SidebarPosition.right,
    this.collapseSidebarOnTablet = true,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(context),
      tablet: _buildTabletLayout(context),
      desktop: _buildDesktopLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: padding ?? context.responsivePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          SizedBox(height: spacing),
          content,
          if (sidebar != null) ...[
            SizedBox(height: spacing),
            sidebar!,
          ],
          if (footer != null) ...[
            SizedBox(height: spacing),
            footer!,
          ],
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    if (collapseSidebarOnTablet || sidebar == null) {
      return _buildMobileLayout(context);
    }
    
    return Padding(
      padding: padding ?? context.responsivePadding,
      child: Column(
        children: [
          header,
          SizedBox(height: spacing),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: sidebarPosition == SidebarPosition.left
                  ? [
                      SizedBox(
                        width: sidebarWidth,
                        child: sidebar!,
                      ),
                      SizedBox(width: spacing),
                      Expanded(child: content),
                    ]
                  : [
                      Expanded(child: content),
                      SizedBox(width: spacing),
                      SizedBox(
                        width: sidebarWidth,
                        child: sidebar!,
                      ),
                    ],
            ),
          ),
          if (footer != null) ...[
            SizedBox(height: spacing),
            footer!,
          ],
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    if (sidebar == null) {
      return Padding(
        padding: padding ?? context.responsivePadding,
        child: Column(
          children: [
            header,
            SizedBox(height: spacing),
            Expanded(child: content),
            if (footer != null) ...[
              SizedBox(height: spacing),
              footer!,
            ],
          ],
        ),
      );
    }
    
    return Padding(
      padding: padding ?? context.responsivePadding,
      child: Column(
        children: [
          header,
          SizedBox(height: spacing),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: sidebarPosition == SidebarPosition.left
                  ? [
                      SizedBox(
                        width: sidebarWidth,
                        child: sidebar!,
                      ),
                      SizedBox(width: spacing),
                      Expanded(child: content),
                    ]
                  : [
                      Expanded(child: content),
                      SizedBox(width: spacing),
                      SizedBox(
                        width: sidebarWidth,
                        child: sidebar!,
                      ),
                    ],
            ),
          ),
          if (footer != null) ...[
            SizedBox(height: spacing),
            footer!,
          ],
        ],
      ),
    );
  }
}

/// The position of the sidebar in a dashboard layout
enum SidebarPosition {
  /// Sidebar on the left
  left,
  
  /// Sidebar on the right
  right,
}

/// A responsive scaffold that adapts to different screen sizes and orientations
class AdaptiveScaffold extends StatelessWidget {
  /// The title of the app
  final String title;
  
  /// The body of the scaffold
  final Widget body;
  
  /// The app bar to display (optional)
  final PreferredSizeWidget? appBar;
  
  /// The floating action button (optional)
  final Widget? floatingActionButton;
  
  /// The drawer to display (optional)
  final Widget? drawer;
  
  /// The end drawer to display (optional)
  final Widget? endDrawer;
  
  /// The bottom navigation bar (optional)
  final Widget? bottomNavigationBar;
  
  /// Whether to show the app bar on mobile
  final bool showAppBarOnMobile;
  
  /// Whether to show the app bar on tablet
  final bool showAppBarOnTablet;
  
  /// Whether to show the app bar on desktop
  final bool showAppBarOnDesktop;
  
  /// Whether to use a centered layout on desktop
  final bool useCenteredLayoutOnDesktop;
  
  /// The maximum width for the centered layout
  final double centeredLayoutMaxWidth;
  
  /// Whether to adapt to the device orientation
  final bool adaptToOrientation;

  const AdaptiveScaffold({
    super.key,
    required this.title,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.drawer,
    this.endDrawer,
    this.bottomNavigationBar,
    this.showAppBarOnMobile = true,
    this.showAppBarOnTablet = true,
    this.showAppBarOnDesktop = true,
    this.useCenteredLayoutOnDesktop = true,
    this.centeredLayoutMaxWidth = 1200,
    this.adaptToOrientation = true,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      considerOrientation: adaptToOrientation,
      mobile: _buildMobileLayout(context),
      tablet: _buildTabletLayout(context),
      desktop: _buildDesktopLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: showAppBarOnMobile ? (appBar ?? _buildDefaultAppBar(context)) : null,
      drawer: drawer,
      endDrawer: endDrawer,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Scaffold(
      appBar: showAppBarOnTablet ? (appBar ?? _buildDefaultAppBar(context)) : null,
      drawer: drawer,
      endDrawer: endDrawer,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final scaffold = Scaffold(
      appBar: showAppBarOnDesktop ? (appBar ?? _buildDefaultAppBar(context)) : null,
      drawer: drawer,
      endDrawer: endDrawer,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
    
    if (useCenteredLayoutOnDesktop) {
      return Center(
        child: SizedBox(
          width: centeredLayoutMaxWidth,
          child: scaffold,
        ),
      );
    }
    
    return scaffold;
  }

  PreferredSizeWidget _buildDefaultAppBar(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: context.isDesktop,
    );
  }
}

/// A responsive padding widget that adapts to different screen sizes
class ResponsivePadding extends StatelessWidget {
  /// The child widget
  final Widget child;
  
  /// The padding for mobile devices (small screens)
  final EdgeInsets? mobilePadding;
  
  /// The padding for tablet devices (medium screens)
  final EdgeInsets? tabletPadding;
  
  /// The padding for desktop devices (large screens)
  final EdgeInsets? desktopPadding;
  
  /// The padding for large desktop devices (extra large screens)
  final EdgeInsets? largeDesktopPadding;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
    this.largeDesktopPadding,
  });

  @override
  Widget build(BuildContext context) {
    final padding = context.responsiveValue<EdgeInsets>(
      mobile: mobilePadding ?? const EdgeInsets.all(16),
      tablet: tabletPadding ?? const EdgeInsets.all(24),
      desktop: desktopPadding ?? const EdgeInsets.all(32),
      largeDesktop: largeDesktopPadding ?? const EdgeInsets.all(48),
    );
    
    return Padding(
      padding: padding,
      child: child,
    );
  }
}

/// A responsive text widget that adapts its style based on screen size
class ResponsiveText extends StatelessWidget {
  /// The text to display
  final String text;
  
  /// The text style for mobile devices (small screens)
  final TextStyle? mobileStyle;
  
  /// The text style for tablet devices (medium screens)
  final TextStyle? tabletStyle;
  
  /// The text style for desktop devices (large screens)
  final TextStyle? desktopStyle;
  
  /// The text style for large desktop devices (extra large screens)
  final TextStyle? largeDesktopStyle;
  
  /// The text alignment
  final TextAlign? textAlign;
  
  /// The maximum number of lines
  final int? maxLines;
  
  /// The text overflow behavior
  final TextOverflow? overflow;

  const ResponsiveText({
    super.key,
    required this.text,
    this.mobileStyle,
    this.tabletStyle,
    this.desktopStyle,
    this.largeDesktopStyle,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final style = context.responsiveValue<TextStyle?>(
      mobile: mobileStyle,
      tablet: tabletStyle,
      desktop: desktopStyle,
      largeDesktop: largeDesktopStyle,
    );
    
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
