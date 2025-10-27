import 'package:flutter/material.dart';
import '../../models/class.dart';

class CardClassList extends StatelessWidget {
  final List<ClassModel> classes;
  const CardClassList({super.key, required this.classes});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        height: classes.length > 4 ? 220 : null,
        child: ListView.builder(
          shrinkWrap: true,
          physics: classes.length > 4
              ? const ScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          itemCount: classes.length,
          itemBuilder: (context, i) {
            final c = classes[i];
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25), // Replaced withAlpha
                    blurRadius: 2,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    c.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w200,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "class code: ${c.codeClass}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
