import 'package:flutter/material.dart';
import '../../models/result_understanding.dart';

class CardPercentageUnderstanding extends StatelessWidget {
  final List<ResultUnderstanding> items;

  const CardPercentageUnderstanding({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: items.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('No understanding results.'),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items
                  .map((r) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [Text('Type: ${r.type}'), Text('id: ${r.id}')],
                        ),
                      ))
                  .toList(),
            ),
    );
  }
}
