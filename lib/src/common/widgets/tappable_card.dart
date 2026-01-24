import 'package:flutter/material.dart';

/// A wrapper widget that provides visual tap feedback with a scale animation.
/// Use this to wrap interactive cards for better user experience.
class TappableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  /// Scale factor when pressed (1.0 = no scale, 0.95 = shrink to 95%)
  final double pressedScale;

  /// Duration of the scale animation
  final Duration animationDuration;

  const TappableCard({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.95,
    this.animationDuration = const Duration(milliseconds: 100),
  });

  @override
  State<TappableCard> createState() => _TappableCardState();
}

class _TappableCardState extends State<TappableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressedScale,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      // RepaintBoundary isolates the animation repaint area,
      // preventing unnecessary repaints of sibling widgets during scale animation
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(scale: _scaleAnimation.value, child: child);
          },
          child: widget.child,
        ),
      ),
    );
  }
}




