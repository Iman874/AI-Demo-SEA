import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:sea_app/services/api_service.dart';
import 'package:sea_app/theme/app_colors.dart';
import 'package:sea_app/theme/app_text_styles.dart';
import 'package:sea_app/theme/app_spacing.dart';
import 'package:sea_app/theme/app_decorations.dart';
import 'page_choice_user.dart';

class ConnectionConfigPage extends StatefulWidget {
  final VoidCallback onConfigured;
  const ConnectionConfigPage({super.key, required this.onConfigured});

  @override
  State<ConnectionConfigPage> createState() => _ConnectionConfigPageState();
}

class _ConnectionConfigPageState extends State<ConnectionConfigPage> {
  final _hostCtrl = TextEditingController(text: ApiService.host);
  final _portCtrl = TextEditingController(text: ApiService.port);
  bool _checking = false;
  bool? _ok;
  String? _message;
  bool _noPort = ApiService.port.isEmpty;
  String _scheme = ApiService.scheme;

  Future<void> _check() async {
    setState(() { _checking = true; _ok = null; _message = null; });
    final effectivePort = _noPort ? '' : _portCtrl.text;
    await ApiService.setConfig(host: _hostCtrl.text, port: effectivePort, scheme: _scheme);
    final ok = await ApiService.checkConnection();
    setState(() { _checking = false; _ok = ok; _message = ok ? 'Tersambung' : 'Gagal terhubung'; });
  }

  Future<void> _saveAndContinue() async {
    final effectivePort = _noPort ? '' : _portCtrl.text;
    await ApiService.setConfig(host: _hostCtrl.text, port: effectivePort, scheme: _scheme);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ChoiceUserPage()),
    );
  }

  void _quitWithoutSaving() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ChoiceUserPage()),
    );
  }

  @override
  void dispose() {
    _hostCtrl.dispose();
    _portCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = AppColors.primary;
    final accentGradient = AppColors.teacherGradient;

    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          children: [
            // ── GRADIENT HEADER ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: accentGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                boxShadow: AppDecorations.shadowGlow(
                  color: accentColor,
                  opacity: 0.15,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      PhosphorIconsRegular.cloudArrowDown,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  AppSpacing.hLg,
                  Text(
                    "Konfigurasi Server",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  AppSpacing.hXs,
                  Text(
                    "Atur koneksi ke backend server SEA App",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.hXxxl,

            // ── FORM CARD ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: AppDecorations.elevatedCard(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Alamat Server ──
                    Text(
                      "Alamat Server",
                      style: AppTextStyles.labelMd(context).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    AppSpacing.hSm,
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.2),
                            ),
                          ),
                          child: DropdownButton<String>(
                            value: _scheme,
                            dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
                            underline: const SizedBox.shrink(),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: accentColor,
                            ),
                            onChanged: (val) {
                              if (val == null) return;
                              setState(() { _scheme = val; });
                            },
                            items: const [
                              DropdownMenuItem(value: 'http', child: Text('http')),
                              DropdownMenuItem(value: 'https', child: Text('https')),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "://",
                          style: AppTextStyles.bodyMd(context).copyWith(
                            color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: TextField(
                            controller: _hostCtrl,
                            style: AppTextStyles.bodyMd(context),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: isDark
                                  ? Colors.white.withValues(alpha: 0.04)
                                  : const Color(0xFFF8FAFC),
                              hintText: "127.0.0.1",
                              hintStyle: TextStyle(
                                color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                                fontSize: 13,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: accentColor, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.hMd,

                    // ── Port ──
                    Row(
                      children: [
                        SizedBox(
                          width: 24,
                          child: Checkbox(
                            value: _noPort,
                            activeColor: accentColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            onChanged: (v) {
                              setState(() {
                                _noPort = v ?? false;
                                if (_noPort) _portCtrl.text = '';
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Default port (80/443)",
                          style: AppTextStyles.bodySm(context).copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.hSm,
                    TextField(
                      controller: _portCtrl,
                      enabled: !_noPort,
                      style: AppTextStyles.bodyMd(context),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withValues(alpha: _noPort ? 0.02 : 0.04)
                            : _noPort ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
                        hintText: "8000",
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(
                          PhosphorIconsRegular.plug,
                          size: 18,
                          color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: accentColor, width: 1.5),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.borderDark.withValues(alpha: 0.4)
                                : const Color(0xFFE2E8F0).withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),

                    AppSpacing.hXl,

                    // ── CHECK CONNECTION ──
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: FilledButton.icon(
                              onPressed: _checking ? null : _check,
                              icon: _checking
                                  ? SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(PhosphorIconsRegular.wifiHigh, size: 18),
                              label: Text(
                                _checking ? "Memeriksa..." : "Uji Koneksi",
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: accentColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (_ok != null) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _ok!
                                  ? AppColors.success.withValues(alpha: 0.12)
                                  : AppColors.error.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _ok! ? PhosphorIconsRegular.checkCircle : PhosphorIconsRegular.warningCircle,
                              color: _ok! ? AppColors.success : AppColors.error,
                              size: 22,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (_message != null) ...[
                      AppSpacing.hSm,
                      Text(
                        _message!,
                        style: AppTextStyles.bodySm(context).copyWith(
                          color: _ok! ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            AppSpacing.hXxxl,

            // ── ACTION BUTTONS ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: FilledButton(
                        onPressed: _saveAndContinue,
                        style: FilledButton.styleFrom(
                          backgroundColor: accentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Simpan & Lanjutkan",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(PhosphorIconsRegular.arrowRight, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.hMd,
            TextButton(
              onPressed: _quitWithoutSaving,
              child: Text(
                "Lewati",
                style: AppTextStyles.bodyMd(context).copyWith(
                  color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
