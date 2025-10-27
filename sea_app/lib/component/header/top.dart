import 'package:flutter/material.dart';

class TopHeader extends StatelessWidget {
  final String title;
  final Color backgroundColor;

  const TopHeader({
    super.key,
    required this.title,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 14),
      color: backgroundColor,
      child: Center(
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            color: Theme.of(context).appBarTheme.foregroundColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}