import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/validation_helper.dart';

enum FieldVariant { outlined, filled, underlined }

enum ValidationTiming { onChange, onFocusLost, onSubmit, realTime }

class AdvancedFormField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String fieldName;
  final TextEditingController? controller;
  final String? initialValue;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final bool required;
  final FieldVariant variant;
  final ValidationTiming validationTiming;
  final List<TextInputFormatter>? customFormatters;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onFieldSubmitted;
  final String? Function(String?)? customValidator;
  final bool showCharacterCount;
  final bool showValidationIcon;
  final bool enableSuggestions;
  final bool autocorrect;
  final TextCapitalization textCapitalization;
  final EdgeInsets? contentPadding;
  final Color? focusColor;
  final Color? fillColor;
  final BorderRadius? borderRadius;
  final double? borderWidth;
  final bool showClearButton;
  final bool enableFloatingLabel;
  final Duration animationDuration;
  final List<String>? suggestions;
  final bool enableVoiceInput;
  final FocusNode? focusNode;

  const AdvancedFormField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    required this.fieldName,
    this.controller,
    this.initialValue,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.required = false,
    this.variant = FieldVariant.outlined,
    this.validationTiming = ValidationTiming.onChange,
    this.customFormatters,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.onFieldSubmitted,
    this.customValidator,
    this.showCharacterCount = false,
    this.showValidationIcon = true,
    this.enableSuggestions = true,
    this.autocorrect = true,
    this.textCapitalization = TextCapitalization.none,
    this.contentPadding,
    this.focusColor,
    this.fillColor,
    this.borderRadius,
    this.borderWidth,
    this.showClearButton = true,
    this.enableFloatingLabel = true,
    this.animationDuration = const Duration(milliseconds: 200),
    this.suggestions,
    this.enableVoiceInput = false,
    this.focusNode,
  });

  @override
  State<AdvancedFormField> createState() => _AdvancedFormFieldState();
}

class _AdvancedFormFieldState extends State<AdvancedFormField>
    with TickerProviderStateMixin {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  ValidationResult? _validationResult;
  bool _isFocused = false;
  bool _hasValue = false;
  bool _showPassword = false;
  final ValidationHelper _validator = ValidationHelper();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    _hasValue = _controller.text.isNotEmpty;
    
    _setupAnimations();
    _setupListeners();
    
    // Initial validation if field has value
    if (_hasValue) {
      _validateField(_controller.text);
    }
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  void _setupListeners() {
    _focusNode.addListener(_onFocusChanged);
    _controller.addListener(_onTextChanged);
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    
    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
      if (widget.validationTiming == ValidationTiming.onFocusLost) {
        _validateField(_controller.text);
      }
    }
  }

  void _onTextChanged() {
    final hasValue = _controller.text.isNotEmpty;
    if (hasValue != _hasValue) {
      setState(() {
        _hasValue = hasValue;
      });
    }

    if (widget.validationTiming == ValidationTiming.onChange ||
        widget.validationTiming == ValidationTiming.realTime) {
      _validateField(_controller.text);
    }

    widget.onChanged?.call(_controller.text);
  }

  void _validateField(String value) {
    ValidationResult result;
    
    if (widget.customValidator != null) {
      final customError = widget.customValidator!(value);
      if (customError != null) {
        result = ValidationResult.invalid(customError, ValidationError.invalid);
      } else {
        result = _validator.validate(value, widget.fieldName);
      }
    } else {
      result = _validator.validate(value, widget.fieldName);
    }

    if (mounted) {
      setState(() {
        _validationResult = result;
      });
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormField(context, theme, colorScheme),
        if (_shouldShowHelper())
          _buildHelperArea(theme, colorScheme),
      ],
    );
  }

  Widget _buildFormField(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          obscureText: widget.obscureText && !_showPassword,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          textCapitalization: widget.textCapitalization,
          enableSuggestions: widget.enableSuggestions,
          autocorrect: widget.autocorrect,
          inputFormatters: _getInputFormatters(),
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,
          validator: widget.validationTiming == ValidationTiming.onSubmit 
              ? (value) => _validateOnSubmit(value)
              : null,
          decoration: _buildInputDecoration(theme, colorScheme),
        );
      },
    );
  }

  InputDecoration _buildInputDecoration(ThemeData theme, ColorScheme colorScheme) {
    final borderColor = _getBorderColor(colorScheme);
    final focusedBorderColor = widget.focusColor ?? colorScheme.primary;
    final errorBorderColor = colorScheme.error;
    
    return InputDecoration(
      labelText: widget.enableFloatingLabel ? _getLabel() : null,
      hintText: widget.hint,
      prefixIcon: _buildPrefixIcon(colorScheme),
      suffixIcon: _buildSuffixIcon(colorScheme),
      filled: widget.variant == FieldVariant.filled,
      fillColor: widget.fillColor ?? 
          (widget.variant == FieldVariant.filled 
              ? colorScheme.surfaceVariant.withOpacity(0.5)
              : null),
      contentPadding: widget.contentPadding ?? _getDefaultPadding(),
      
      // Border configuration based on variant
      border: _buildBorder(borderColor),
      enabledBorder: _buildBorder(borderColor),
      focusedBorder: _buildBorder(focusedBorderColor),
      errorBorder: _buildBorder(errorBorderColor),
      focusedErrorBorder: _buildBorder(errorBorderColor),
      
      // Error handling
      errorText: _getErrorText(),
      errorMaxLines: 2,
      
      // Counter
      counterText: widget.showCharacterCount ? null : '',
      
      // Label styling
      labelStyle: TextStyle(
        color: _isFocused ? focusedBorderColor : colorScheme.onSurfaceVariant,
      ),
      hintStyle: TextStyle(
        color: colorScheme.onSurfaceVariant.withOpacity(0.6),
      ),
    );
  }

  Widget? _buildPrefixIcon(ColorScheme colorScheme) {
    if (widget.prefixIcon == null) return null;
    
    return AnimatedContainer(
      duration: widget.animationDuration,
      child: Icon(
        widget.prefixIcon,
        color: _isFocused 
            ? colorScheme.primary 
            : colorScheme.onSurfaceVariant.withOpacity(0.6),
      ),
    );
  }

  Widget? _buildSuffixIcon(ColorScheme colorScheme) {
    final icons = <Widget>[];
    
    // Validation icon
    if (widget.showValidationIcon && _validationResult != null) {
      icons.add(_buildValidationIcon(colorScheme));
    }
    
    // Clear button
    if (widget.showClearButton && _hasValue && widget.enabled && !widget.readOnly) {
      icons.add(_buildClearButton(colorScheme));
    }
    
    // Password visibility toggle
    if (widget.obscureText) {
      icons.add(_buildPasswordToggle(colorScheme));
    }
    
    // Voice input
    if (widget.enableVoiceInput) {
      icons.add(_buildVoiceButton(colorScheme));
    }
    
    // Custom suffix icon
    if (widget.suffixIcon != null) {
      icons.add(widget.suffixIcon!);
    }
    
    if (icons.isEmpty) return null;
    
    if (icons.length == 1) {
      return icons.first;
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: icons.map((icon) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: icon,
      )).toList(),
    );
  }

  Widget _buildValidationIcon(ColorScheme colorScheme) {
    if (_validationResult == null) return const SizedBox.shrink();
    
    return AnimatedSwitcher(
      duration: widget.animationDuration,
      child: Icon(
        _validationResult!.isValid ? Icons.check_circle : Icons.error,
        key: ValueKey(_validationResult!.isValid),
        color: _validationResult!.isValid ? Colors.green : colorScheme.error,
        size: 20,
      ),
    );
  }

  Widget _buildClearButton(ColorScheme colorScheme) {
    return IconButton(
      icon: Icon(
        Icons.clear,
        size: 20,
        color: colorScheme.onSurfaceVariant.withOpacity(0.6),
      ),
      onPressed: () {
        _controller.clear();
        _focusNode.requestFocus();
      },
      visualDensity: VisualDensity.compact,
      tooltip: 'Clear',
    );
  }

  Widget _buildPasswordToggle(ColorScheme colorScheme) {
    return IconButton(
      icon: Icon(
        _showPassword ? Icons.visibility_off : Icons.visibility,
        size: 20,
        color: colorScheme.onSurfaceVariant.withOpacity(0.6),
      ),
      onPressed: () {
        setState(() {
          _showPassword = !_showPassword;
        });
      },
      visualDensity: VisualDensity.compact,
      tooltip: _showPassword ? 'Hide password' : 'Show password',
    );
  }

  Widget _buildVoiceButton(ColorScheme colorScheme) {
    return IconButton(
      icon: Icon(
        Icons.mic,
        size: 20,
        color: colorScheme.onSurfaceVariant.withOpacity(0.6),
      ),
      onPressed: () {
        // TODO: Implement voice input
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voice input not yet implemented')),
        );
      },
      visualDensity: VisualDensity.compact,
      tooltip: 'Voice input',
    );
  }



  Widget _buildHelperArea(ThemeData theme, ColorScheme colorScheme) {
    return AnimatedContainer(
      duration: widget.animationDuration,
      padding: const EdgeInsets.only(top: 4, left: 12, right: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildHelperText(theme, colorScheme),
          ),
          if (widget.showCharacterCount && widget.maxLength != null)
            _buildCharacterCount(theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildHelperText(ThemeData theme, ColorScheme colorScheme) {
    String? text;
    Color? color;
    
    if (_validationResult != null && !_validationResult!.isValid) {
      text = _validationResult!.errorMessage;
      color = colorScheme.error;
    } else if (widget.helperText != null) {
      text = widget.helperText;
      color = colorScheme.onSurfaceVariant.withOpacity(0.6);
    }
    
    if (text == null) return const SizedBox.shrink();
    
    return AnimatedSwitcher(
      duration: widget.animationDuration,
      child: Text(
        text,
        key: ValueKey(text),
        style: theme.textTheme.bodySmall?.copyWith(color: color),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildCharacterCount(ThemeData theme, ColorScheme colorScheme) {
    final currentLength = _controller.text.length;
    final maxLength = widget.maxLength!;
    final isOverLimit = currentLength > maxLength;
    
    return Text(
      '$currentLength/$maxLength',
      style: theme.textTheme.bodySmall?.copyWith(
        color: isOverLimit 
            ? colorScheme.error 
            : colorScheme.onSurfaceVariant.withOpacity(0.6),
      ),
    );
  }

  // Helper methods
  String? _getLabel() {
    if (widget.label == null) return null;
    return widget.required ? '${widget.label} *' : widget.label;
  }

  Color _getBorderColor(ColorScheme colorScheme) {
    if (_validationResult != null && !_validationResult!.isValid) {
      return colorScheme.error;
    }
    return colorScheme.outline;
  }

  InputBorder _buildBorder(Color color) {
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(8);
    final borderWidth = widget.borderWidth ?? 1.0;
    
    switch (widget.variant) {
      case FieldVariant.outlined:
        return OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: color, width: borderWidth),
        );
      case FieldVariant.filled:
        return OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: color, width: borderWidth),
        );
      case FieldVariant.underlined:
        return UnderlineInputBorder(
          borderSide: BorderSide(color: color, width: borderWidth),
        );
    }
  }

  EdgeInsets _getDefaultPadding() {
    switch (widget.variant) {
      case FieldVariant.outlined:
      case FieldVariant.filled:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case FieldVariant.underlined:
        return const EdgeInsets.symmetric(horizontal: 0, vertical: 8);
    }
  }

  String? _getErrorText() {
    if (_validationResult != null && !_validationResult!.isValid) {
      return null; // We handle errors in helper area for better control
    }
    return null;
  }

  List<TextInputFormatter> _getInputFormatters() {
    final formatters = <TextInputFormatter>[];
    
    // Add field-specific formatters
    formatters.addAll(_validator.getInputFormatters(widget.fieldName));
    
    // Add custom formatters
    if (widget.customFormatters != null) {
      formatters.addAll(widget.customFormatters!);
    }
    
    return formatters;
  }

  bool _shouldShowHelper() {
    return widget.helperText != null || 
           (_validationResult != null && !_validationResult!.isValid) ||
           (widget.showCharacterCount && widget.maxLength != null);
  }

  String? _validateOnSubmit(String? value) {
    _validateField(value ?? '');
    return _validationResult?.isValid == false ? _validationResult!.errorMessage : null;
  }
}

// Pre-configured form fields for common use cases
class EmailFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? initialValue;
  final bool required;
  final ValueChanged<String>? onChanged;

  const EmailFormField({
    super.key,
    this.controller,
    this.label,
    this.initialValue,
    this.required = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AdvancedFormField(
      fieldName: 'email',
      controller: controller,
      label: label ?? 'Email',
      initialValue: initialValue,
      required: required,
      keyboardType: TextInputType.emailAddress,
      prefixIcon: Icons.email_outlined,
      textCapitalization: TextCapitalization.none,
      autocorrect: false,
      onChanged: onChanged,
    );
  }
}

class PhoneFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? initialValue;
  final bool required;
  final ValueChanged<String>? onChanged;

  const PhoneFormField({
    super.key,
    this.controller,
    this.label,
    this.initialValue,
    this.required = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AdvancedFormField(
      fieldName: 'phone',
      controller: controller,
      label: label ?? 'Phone',
      initialValue: initialValue,
      required: required,
      keyboardType: TextInputType.phone,
      prefixIcon: Icons.phone_outlined,
      onChanged: onChanged,
    );
  }
}

class AmountFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? initialValue;
  final bool required;
  final ValueChanged<String>? onChanged;

  const AmountFormField({
    super.key,
    this.controller,
    this.label,
    this.initialValue,
    this.required = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AdvancedFormField(
      fieldName: 'amount',
      controller: controller,
      label: label ?? 'Amount',
      initialValue: initialValue,
      required: required,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      prefixIcon: Icons.attach_money,
      onChanged: onChanged,
    );
  }
}

class PasswordFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? initialValue;
  final bool required;
  final ValueChanged<String>? onChanged;

  const PasswordFormField({
    super.key,
    this.controller,
    this.label,
    this.initialValue,
    this.required = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AdvancedFormField(
      fieldName: 'password',
      controller: controller,
      label: label ?? 'Password',
      initialValue: initialValue,
      required: required,
      obscureText: true,
      prefixIcon: Icons.lock_outlined,
      autocorrect: false,
      enableSuggestions: false,
      onChanged: onChanged,
    );
  }
} 