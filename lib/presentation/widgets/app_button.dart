import 'package:flutter/material.dart';
import 'package:flutter_order_manager/core/theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, outline }
enum AppButtonSize { small, medium, large }

class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Size configurations
    final double height;
    final double fontSize;
    final double iconSize;
    final EdgeInsets padding;

    switch (widget.size) {
      case AppButtonSize.small:
        height = 32;
        fontSize = 12;
        iconSize = 16;
        padding = const EdgeInsets.symmetric(horizontal: 12);
        break;
      case AppButtonSize.large:
        height = 56;
        fontSize = 16;
        iconSize = 24;
        padding = const EdgeInsets.symmetric(horizontal: 24);
        break;
      case AppButtonSize.medium:
      default:
        height = 44;
        fontSize = 14;
        iconSize = 20;
        padding = const EdgeInsets.symmetric(horizontal: 16);
    }

    // Style configurations based on variant
    final Color backgroundColor;
    final Color textColor;
    final Color? borderColor;
    final double elevation;

    switch (widget.variant) {
      case AppButtonVariant.secondary:
        backgroundColor = AppColors.primaryLight;
        textColor = AppColors.primary;
        borderColor = null;
        elevation = 0;
        break;
      case AppButtonVariant.outline:
        backgroundColor = Colors.transparent;
        textColor = AppColors.primary;
        borderColor = AppColors.primary;
        elevation = 0;
        break;
      case AppButtonVariant.primary:
      default:
        backgroundColor = AppColors.primary;
        textColor = Colors.white;
        borderColor = null;
        elevation = _isPressed ? 2 : 4;
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: Container(
              height: height,
              width: widget.fullWidth ? double.infinity : null,
              decoration: BoxDecoration(
                color: widget.onPressed == null 
                    ? backgroundColor.withOpacity(0.5) 
                    : backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: borderColor != null 
                    ? Border.all(color: borderColor) 
                    : null,
                boxShadow: [
                  if (elevation > 0)
                    BoxShadow(
                      color: AppColors.shadow.withOpacity(0.1),
                      blurRadius: elevation * 2,
                      offset: Offset(0, elevation),
                    ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: padding,
                    child: Row(
                      mainAxisSize: widget.fullWidth 
                          ? MainAxisSize.max 
                          : MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.isLoading)
                          SizedBox(
                            width: iconSize,
                            height: iconSize,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(textColor),
                            ),
                          )
                        else if (widget.icon != null)
                          Icon(widget.icon, 
                            size: iconSize, 
                            color: textColor,
                          ),
                        if ((widget.isLoading || widget.icon != null) && 
                            widget.text.isNotEmpty)
                          SizedBox(width: 8),
                        Text(
                          widget.text,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: textColor,
                            fontSize: fontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

