import 'package:flutter/material.dart';
import '../../models/material.dart';

class CardMaterialList extends StatelessWidget {
  final List<MaterialPdf> materials;
  final void Function(MaterialPdf)? onViewMaterial;

  const CardMaterialList({
    super.key,
    required this.materials,
    this.onViewMaterial,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        height: materials.length > 4 ? 220 : null,
        child: materials.isEmpty
            ? const Center(
                child: Text(
                  "No material added yet.",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: materials.length > 4
                    ? const AlwaysScrollableScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                itemCount: materials.length,
                itemBuilder: (context, i) {
                  final m = materials[i];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 2,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ganti Icon dengan Image.asset
                          Image.asset(
                            'assets/icon/pdf_icon.png',
                            width: 22,
                            height: 22,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              m.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 36,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(const Color(0xFF6B6B6B)),
                                elevation: MaterialStateProperty.all(0),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                padding: MaterialStateProperty.all(
                                  const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                ),
                              ),
                              onPressed: onViewMaterial != null
                                  ? () => onViewMaterial!(m)
                                  : null,
                              child: const Text(
                                "View Material",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
