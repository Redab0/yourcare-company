import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isDisabled;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double borderRadius;
  final IconData? icon;
  final double? width;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isDisabled = false,
    this.backgroundColor,
    this.textColor,
    this.height = 50.0,
    this.borderRadius = 12.0,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Use ConstrainedBox instead of SizedBox with infinite width
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: width ?? 1.0, // If width is null, use minWidth of 1.0
        maxWidth: width ??
            double
                .infinity, // If width is null, allow expanding to available space
        minHeight: height,
      ),
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading || isDisabled ? null : onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: isDisabled ? Colors.grey : theme.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              child: _buildButtonContent(theme),
            )
          : ElevatedButton(
              onPressed: isLoading || isDisabled ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDisabled
                    ? Colors.grey[300]
                    : (backgroundColor ?? theme.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              child: _buildButtonContent(theme),
            ),
    );
  }

  Widget _buildButtonContent(ThemeData theme) {
    if (isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      );
    }

    // Text color based on button state and style
    final Color textColorToUse = isDisabled
        ? Colors.grey[600]!
        : (isOutlined
            ? (textColor ?? theme.primaryColor)
            : (textColor ?? Colors.white));

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize
            .min, // Add this to prevent row from expanding infinitely
        children: [
          Icon(
            icon,
            size: 18,
            color: textColorToUse,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: textColorToUse,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        color: textColorToUse,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
