import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'animated_counter.dart';

enum CardSize { small, medium, large }

enum CardVariant { elevated, outlined, filled }

class EnhancedDashboardCard extends StatefulWidget {
  final String title;
  final dynamic value;
  final IconData icon;
  final Color? primaryColor;
  final Color? backgroundColor;
  final String? subtitle;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;
  final bool isLoading;
  final String? errorMessage;
  final CardSize size;
  final CardVariant variant;
  final bool showAnimation;
  final Duration animationDuration;
  final bool enableHapticFeedback;
  final String? semanticLabel;
  final String? tooltip;
  final Widget? customContent;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? customShadows;
  final bool showProgress;
  final double? progressValue;
  final String? trend;
  final double? trendValue;

  const EnhancedDashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.primaryColor,
    this.backgroundColor,
    this.subtitle,
    this.onTap,
    this.onLongPress,
    this.trailing,
    this.isLoading = false,
    this.errorMessage,
    this.size = CardSize.medium,
    this.variant = CardVariant.elevated,
    this.showAnimation = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.enableHapticFeedback = true,
    this.semanticLabel,
    this.tooltip,
    this.customContent,
    this.padding,
    this.borderRadius,
    this.customShadows,
    this.showProgress = false,
    this.progressValue,
    this.trend,
    this.trendValue,
  });

  @override
  State<EnhancedDashboardCard> createState() => _EnhancedDashboardCardState();
}

class _EnhancedDashboardCardState extends State<EnhancedDashboardCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    if (widget.showAnimation) {
      _startEntryAnimation();
    }
  }

  void _setupAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  void _startEntryAnimation() {
    Future.delayed(Duration(milliseconds: 100 * _getAnimationDelay()), () {
      if (mounted) {
        _slideController.forward();
        _fadeController.forward();
      }
    });
  }

  int _getAnimationDelay() {
    // Add some randomness to prevent all cards animating at once
    return (widget.title.hashCode % 5);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
    
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  void _handleTap() {
    if (widget.enableHapticFeedback) {
      HapticFeedback.selectionClick();
    }
    widget.onTap?.call();
  }

  void _handleLongPress() {
    if (widget.enableHapticFeedback) {
      HapticFeedback.mediumImpact();
    }
    widget.onLongPress?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Widget cardContent = _buildCardContent(context, theme, colorScheme);
    
    if (widget.showAnimation) {
      cardContent = SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: cardContent,
        ),
      );
    }

    if (widget.onTap != null || widget.onLongPress != null) {
      cardContent = ScaleTransition(
        scale: _scaleAnimation,
        child: cardContent,
      );
    }

    if (widget.tooltip != null) {
      cardContent = Tooltip(
        message: widget.tooltip!,
        child: cardContent,
      );
    }

    return Semantics(
      label: widget.semanticLabel ?? '${widget.title}: ${widget.value}',
      button: widget.onTap != null,
      child: cardContent,
    );
  }

  Widget _buildCardContent(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    final dimensions = _getCardDimensions();
    final colors = _getCardColors(colorScheme);
    final decoration = _getCardDecoration(colors, theme);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: widget.onTap != null ? _handleTapDown : null,
        onTapUp: widget.onTap != null ? _handleTapUp : null,
        onTapCancel: widget.onTap != null ? _handleTapCancel : null,
        onTap: widget.onTap != null ? _handleTap : null,
        onLongPress: widget.onLongPress != null ? _handleLongPress : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: dimensions.width,
          height: dimensions.height,
          padding: widget.padding ?? _getDefaultPadding(),
          decoration: decoration,
          child: widget.customContent ?? _buildDefaultContent(context, theme, colors),
        ),
      ),
    );
  }

  Size _getCardDimensions() {
    switch (widget.size) {
      case CardSize.small:
        return const Size(120, 80);
      case CardSize.medium:
        return const Size(160, 120);
      case CardSize.large:
        return const Size(200, 140);
    }
  }

  _CardColors _getCardColors(ColorScheme colorScheme) {
    final primaryColor = widget.primaryColor ?? colorScheme.primary;
    final backgroundColor = widget.backgroundColor ?? 
        (_isHovered ? colorScheme.primaryContainer.withOpacity(0.1) : colorScheme.surface);
    
    return _CardColors(
      primary: primaryColor,
      background: backgroundColor,
      onBackground: colorScheme.onSurface,
      accent: primaryColor.withOpacity(0.1),
    );
  }

  BoxDecoration _getCardDecoration(_CardColors colors, ThemeData theme) {
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(16);
    
    switch (widget.variant) {
      case CardVariant.elevated:
        return BoxDecoration(
          color: colors.background,
          borderRadius: borderRadius,
          boxShadow: widget.customShadows ?? [
            BoxShadow(
              color: colors.primary.withOpacity(_isHovered ? 0.15 : 0.08),
              blurRadius: _isHovered ? 12 : 8,
              offset: Offset(0, _isHovered ? 6 : 4),
            ),
          ],
        );
      
      case CardVariant.outlined:
        return BoxDecoration(
          color: colors.background,
          borderRadius: borderRadius,
          border: Border.all(
            color: _isHovered ? colors.primary : colors.primary.withOpacity(0.3),
            width: _isHovered ? 2 : 1,
          ),
        );
      
      case CardVariant.filled:
        return BoxDecoration(
          color: _isHovered ? colors.primary.withOpacity(0.9) : colors.primary,
          borderRadius: borderRadius,
        );
    }
  }

  EdgeInsets _getDefaultPadding() {
    switch (widget.size) {
      case CardSize.small:
        return const EdgeInsets.all(12);
      case CardSize.medium:
        return const EdgeInsets.all(16);
      case CardSize.large:
        return const EdgeInsets.all(20);
    }
  }

  Widget _buildDefaultContent(BuildContext context, ThemeData theme, _CardColors colors) {
    if (widget.isLoading) {
      return _buildLoadingContent(colors);
    }

    if (widget.errorMessage != null) {
      return _buildErrorContent(colors);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildHeader(colors),
        _buildValue(colors),
        if (widget.subtitle != null || widget.showProgress) 
          _buildFooter(colors),
      ],
    );
  }

  Widget _buildLoadingContent(_CardColors colors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Loading...',
          style: TextStyle(
            color: colors.onBackground.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorContent(_CardColors colors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          widget.errorMessage!,
          style: TextStyle(
            color: Colors.red,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildHeader(_CardColors colors) {
    final isFilledVariant = widget.variant == CardVariant.filled;
    final iconColor = isFilledVariant ? Colors.white : colors.primary;
    final titleColor = isFilledVariant ? Colors.white.withOpacity(0.9) : colors.onBackground;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            widget.title,
            style: TextStyle(
              color: titleColor,
              fontSize: _getTitleFontSize(),
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.trailing != null) ...[
              widget.trailing!,
              const SizedBox(width: 8),
            ],
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                widget.icon,
                color: iconColor,
                size: _getIconSize(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildValue(_CardColors colors) {
    final isFilledVariant = widget.variant == CardVariant.filled;
    final valueColor = isFilledVariant ? Colors.white : colors.onBackground;

    Widget valueWidget;
    
    if (widget.value is num) {
      valueWidget = AnimatedCounter(
        value: widget.value.toDouble(),
        textStyle: TextStyle(
          color: valueColor,
          fontSize: _getValueFontSize(),
          fontWeight: FontWeight.bold,
        ),
        duration: widget.animationDuration,
      );
    } else {
      valueWidget = Text(
        widget.value.toString(),
        style: TextStyle(
          color: valueColor,
          fontSize: _getValueFontSize(),
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    if (widget.trend != null && widget.trendValue != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          valueWidget,
          const SizedBox(height: 4),
          _buildTrendIndicator(colors),
        ],
      );
    }

    return valueWidget;
  }

  Widget _buildTrendIndicator(_CardColors colors) {
    final isPositive = widget.trendValue! > 0;
    final trendColor = isPositive ? Colors.green : Colors.red;
    final trendIcon = isPositive ? Icons.trending_up : Icons.trending_down;

    return Row(
      children: [
        Icon(
          trendIcon,
          color: trendColor,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          '${widget.trendValue!.abs().toStringAsFixed(1)}%',
          style: TextStyle(
            color: trendColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          widget.trend!,
          style: TextStyle(
            color: colors.onBackground.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(_CardColors colors) {
    final isFilledVariant = widget.variant == CardVariant.filled;
    final subtitleColor = isFilledVariant 
        ? Colors.white.withOpacity(0.7) 
        : colors.onBackground.withOpacity(0.6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showProgress && widget.progressValue != null) ...[
          LinearProgressIndicator(
            value: widget.progressValue!,
            backgroundColor: subtitleColor.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              isFilledVariant ? Colors.white : colors.primary,
            ),
          ),
          const SizedBox(height: 4),
        ],
        if (widget.subtitle != null)
          Text(
            widget.subtitle!,
            style: TextStyle(
              color: subtitleColor,
              fontSize: _getSubtitleFontSize(),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  double _getTitleFontSize() {
    switch (widget.size) {
      case CardSize.small:
        return 12;
      case CardSize.medium:
        return 14;
      case CardSize.large:
        return 16;
    }
  }

  double _getValueFontSize() {
    switch (widget.size) {
      case CardSize.small:
        return 18;
      case CardSize.medium:
        return 24;
      case CardSize.large:
        return 28;
    }
  }

  double _getSubtitleFontSize() {
    switch (widget.size) {
      case CardSize.small:
        return 10;
      case CardSize.medium:
        return 12;
      case CardSize.large:
        return 14;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case CardSize.small:
        return 16;
      case CardSize.medium:
        return 20;
      case CardSize.large:
        return 24;
    }
  }
}

class _CardColors {
  final Color primary;
  final Color background;
  final Color onBackground;
  final Color accent;

  const _CardColors({
    required this.primary,
    required this.background,
    required this.onBackground,
    required this.accent,
  });
}

// Enhanced Dashboard Card Collection for showing multiple cards
class DashboardCardGrid extends StatelessWidget {
  final List<EnhancedDashboardCard> cards;
  final int crossAxisCount;
  final double spacing;
  final double runSpacing;
  final EdgeInsets padding;
  final bool staggerAnimation;

  const DashboardCardGrid({
    super.key,
    required this.cards,
    this.crossAxisCount = 2,
    this.spacing = 16,
    this.runSpacing = 16,
    this.padding = const EdgeInsets.all(16),
    this.staggerAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: runSpacing,
          childAspectRatio: 1.4,
        ),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          
          if (staggerAnimation) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 300 + (index * 100)),
              child: card,
            );
          }
          
          return card;
        },
      ),
    );
  }
}

// Responsive Dashboard Card that adapts to screen size
class ResponsiveDashboardCard extends StatelessWidget {
  final EnhancedDashboardCard card;

  const ResponsiveDashboardCard({
    super.key,
    required this.card,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        CardSize size;
        if (constraints.maxWidth < 150) {
          size = CardSize.small;
        } else if (constraints.maxWidth < 200) {
          size = CardSize.medium;
        } else {
          size = CardSize.large;
        }

        return EnhancedDashboardCard(
          title: card.title,
          value: card.value,
          icon: card.icon,
          primaryColor: card.primaryColor,
          backgroundColor: card.backgroundColor,
          subtitle: card.subtitle,
          onTap: card.onTap,
          onLongPress: card.onLongPress,
          trailing: card.trailing,
          isLoading: card.isLoading,
          errorMessage: card.errorMessage,
          size: size,
          variant: card.variant,
          showAnimation: card.showAnimation,
          animationDuration: card.animationDuration,
          enableHapticFeedback: card.enableHapticFeedback,
          semanticLabel: card.semanticLabel,
          tooltip: card.tooltip,
          customContent: card.customContent,
          padding: card.padding,
          borderRadius: card.borderRadius,
          customShadows: card.customShadows,
          showProgress: card.showProgress,
          progressValue: card.progressValue,
          trend: card.trend,
          trendValue: card.trendValue,
        );
      },
    );
  }
} 