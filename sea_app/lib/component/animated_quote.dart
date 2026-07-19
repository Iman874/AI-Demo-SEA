import 'dart:async';
import 'package:flutter/material.dart';

class AnimatedQuote extends StatefulWidget {
  final List<String> quotes;
  final TextStyle? style;
  final Duration interval;

  const AnimatedQuote({
    super.key,
    required this.quotes,
    this.style,
    this.interval = const Duration(seconds: 5),
  });

  @override
  State<AnimatedQuote> createState() => _AnimatedQuoteState();
}

class _AnimatedQuoteState extends State<AnimatedQuote> {
  int _index = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.interval, (_) {
      if (mounted) {
        setState(() => _index = (_index + 1) % widget.quotes.length);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.35),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: Text(
          widget.quotes[_index],
          key: ValueKey(_index),
          style: widget.style,
          textAlign: TextAlign.start,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
