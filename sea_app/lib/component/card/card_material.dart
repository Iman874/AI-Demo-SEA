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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        height: materials.length > 4 ? 240 : null,
        child: materials.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    "Belum ada materi yang dilampirkan.",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: materials.length > 4 ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
                itemCount: materials.length,
                itemBuilder: (context, i) {
                  final m = materials[i];
                  final isPdf = m.type == 'pdf';

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Ikon dinamis PDF / Teks
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isPdf
                                  ? Colors.red.withValues(alpha: 0.1)
                                  : Colors.blue.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isPdf ? Icons.picture_as_pdf_rounded : Icons.description_rounded,
                              color: isPdf ? Colors.red.shade400 : Colors.blue.shade400,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Judul Materi
                          Expanded(
                            child: Text(
                              m.title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Tombol Baca / Lihat
                          IconButton(
                            icon: Icon(
                              Icons.visibility_outlined,
                              color: isDark ? Colors.blue.shade300 : const Color(0xFF4B6A85),
                              size: 20,
                            ),
                            onPressed: onViewMaterial != null ? () => onViewMaterial!(m) : null,
                            tooltip: "Baca Materi",
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
