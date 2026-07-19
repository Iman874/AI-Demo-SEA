import 'package:flutter/material.dart';

class StaggeredSlideUp extends StatefulWidget {
  final int index;
  final Widget child;
  final Duration duration;
  final double beginOffset;
  final int delayMs;

  const StaggeredSlideUp({
    super.key,
    required this.index,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.beginOffset = 0.25,
    this.delayMs = 60,
  });

  @override
  State<StaggeredSlideUp> createState() => _StaggeredSlideUpState();
}

class _StaggeredSlideUpState extends State<StaggeredSlideUp> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset(0, widget.beginOffset),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    Future.delayed(Duration(milliseconds: widget.index * widget.delayMs), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: widget.child,
      ),
    );
  }
}
