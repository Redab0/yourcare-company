import 'package:flutter/material.dart';

class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
    this.margin,
    this.baseColor,
    this.highlightColor,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.baseColor ?? Colors.grey.shade300;
    final highlight = widget.highlightColor ?? Colors.grey.shade100;

    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: SizedBox(
        width: widget.width ?? double.infinity,
        height: widget.height,
        child: ClipRRect(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (ctx, _) {
              final t = _controller.value * 2 - 1;
              return ShaderMask(
                blendMode: BlendMode.srcATop,
                shaderCallback: (rect) {
                  return LinearGradient(
                    begin: Alignment(t - 1, 0),
                    end: Alignment(t + 1, 0),
                    colors: [base, highlight, base],
                  ).createShader(rect);
                },
                child: Container(color: base),
              );
            },
          ),
        ),
      ),
    );
  }
}
