// maintenance_page.dart — ULTRA PREMIUM v3
// ✅ Tema: Crimson Dark × Cyber Neon
// ✅ Animasi: Pulse icon, dual orbit ring, scanline, partikel, shimmer
// ✅ Logic: Auto re-check /getAppStatus, countdown, retry, openUrl
// ✅ UI: Card glassmorphism, tombol gradien, info dialog animasi
// ✅ Anti error — null safety 100%, dispose semua controller

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'api_config.dart';

// ════════════════════════════════════════════════════════════════
//  WIDGET UTAMA
// ════════════════════════════════════════════════════════════════
class MaintenancePage extends StatefulWidget {
  final String       message;
  final String       version;
  final String       downloadUrl;
  final VoidCallback onRetry;

  const MaintenancePage({
    super.key,
    required this.message,
    required this.version,
    required this.downloadUrl,
    required this.onRetry,
  });

  @override
  State<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage>
    with TickerProviderStateMixin {

  // ══════════════════════════════════════════════════════════════
  //  KONSTANTA WARNA
  // ══════════════════════════════════════════════════════════════
  static const Color _bgDeep      = Color(0xFF020004);
  static const Color _bgMid       = Color(0xFF07000F);
  static const Color _card        = Color(0xFF0F0016);
  static const Color _cardBorder  = Color(0xFF300020);

  static const Color _red         = Color(0xFFFF1744);
  static const Color _redLight    = Color(0xFFFF4D70);
  static const Color _redBright   = Color(0xFFFF6090);
  static const Color _redDim      = Color(0xFFAA1040);
  static const Color _redDeep     = Color(0xFF550018);
  static const Color _redGlow     = Color(0xFFFF003A);

  static const Color _pink        = Color(0xFFFF206E);
  static const Color _purple      = Color(0xFF6A0572);
  static const Color _purpleLight = Color(0xFF9C27B0);

  static const Color _textMain    = Color(0xFFF5D0DC);
  static const Color _textSub     = Color(0xFF7A4060);
  static const Color _textDim     = Color(0xFF3D1A28);
  static const Color _white       = Color(0xFFFCFCFC);

  // ══════════════════════════════════════════════════════════════
  //  ANIMATION CONTROLLERS
  // ══════════════════════════════════════════════════════════════
  late final AnimationController _pulseCtrl;
  late final Animation<double>   _pulseAnim;

  late final AnimationController _orbit1Ctrl;
  late final Animation<double>   _orbit1Anim;

  late final AnimationController _orbit2Ctrl;
  late final Animation<double>   _orbit2Anim;

  late final AnimationController _scanCtrl;
  late final Animation<double>   _scanAnim;

  late final AnimationController _fadeCtrl;
  late final Animation<double>   _fadeAnim;
  late final Animation<Offset>   _slideAnim;

  late final AnimationController _glowCtrl;
  late final Animation<double>   _glowAnim;

  late final AnimationController _shimmerCtrl;
  late final Animation<double>   _shimmerAnim;

  // Stagger animations untuk card items
  late final List<Animation<double>>   _staggerFade;
  late final List<Animation<Offset>>   _staggerSlide;

  // ══════════════════════════════════════════════════════════════
  //  STATE VARIABLES
  // ══════════════════════════════════════════════════════════════
  Timer? _recheckTimer;
  Timer? _countdownTimer;
  bool   _checking    = false;
  int    _countdown   = 30;
  bool   _btnPressed  = false;   // efek tap tombol download

  // ══════════════════════════════════════════════════════════════
  //  INIT
  // ══════════════════════════════════════════════════════════════
  @override
  void initState() {
    super.initState();

    // 1. Pulse icon utama (scale bounce)
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.90, end: 1.10).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // 2. Orbit ring luar (searah jarum jam, lambat)
    _orbit1Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
    _orbit1Anim = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _orbit1Ctrl, curve: Curves.linear),
    );

    // 3. Orbit ring dalam (berlawanan arah, lebih cepat)
    _orbit2Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat();
    _orbit2Anim = Tween<double>(begin: 2 * math.pi, end: 0).animate(
      CurvedAnimation(parent: _orbit2Ctrl, curve: Curves.linear),
    );

    // 4. Scanline background
    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _scanAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scanCtrl, curve: Curves.linear),
    );

    // 5. Entrance fade + slide
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic));

    // 6. Glow background radial pulse
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );

    // 7. Shimmer tombol download
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _shimmerAnim = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _shimmerCtrl, curve: Curves.linear),
    );

    // 8. Stagger (5 item: icon, title, card, buttons, footer)
    _staggerFade = List.generate(5, (i) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _fadeCtrl,
          curve: Interval(0.05 + i * 0.15, 0.55 + i * 0.10,
              curve: Curves.easeOut),
        ),
      );
    });
    _staggerSlide = List.generate(5, (i) {
      return Tween<Offset>(
        begin: const Offset(0, 0.12),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _fadeCtrl,
          curve: Interval(0.05 + i * 0.15, 0.55 + i * 0.10,
              curve: Curves.easeOutCubic),
        ),
      );
    });

    // 9. Auto re-check tiap 30 detik
    _recheckTimer =
        Timer.periodic(const Duration(seconds: 30), (_) => _checkStatus());

    // 10. Countdown display
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _countdown = _countdown > 0 ? _countdown - 1 : 30);
    });
  }

  // ══════════════════════════════════════════════════════════════
  //  DISPOSE — wajib dispose semua controller & timer
  // ══════════════════════════════════════════════════════════════
  @override
  void dispose() {
    _pulseCtrl.dispose();
    _orbit1Ctrl.dispose();
    _orbit2Ctrl.dispose();
    _scanCtrl.dispose();
    _fadeCtrl.dispose();
    _glowCtrl.dispose();
    _shimmerCtrl.dispose();
    _recheckTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════
  //  LOGIC: Cek status maintenance
  // ══════════════════════════════════════════════════════════════
  Future<void> _checkStatus() async {
    if (_checking || !mounted) return;
    setState(() {
      _checking  = true;
      _countdown = 30;
    });
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/api/app-status'),
          );
      if (!mounted) return;
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final isActive = data['maintenance'] == true;
        if (!isActive) {
          widget.onRetry();
          return;
        }
      }
    } on TimeoutException {
      // Timeout — tetap di halaman maintenance
    } on FormatException {
      // JSON parse error — abaikan
    } catch (_) {
      // Network error atau lainnya — abaikan
    }
    if (mounted) setState(() => _checking = false);
  }

  // ══════════════════════════════════════════════════════════════
  //  LOGIC: Buka URL download
  // ══════════════════════════════════════════════════════════════
  Future<void> _openUrl(String url) async {
    if (url.isEmpty) return;
    try {
      final uri = Uri.parse(url);
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Text('Tidak dapat membuka link'),
              ],
            ),
            backgroundColor: _redDim,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } on FormatException {
      // URL tidak valid
    } catch (_) {}
  }

  // ══════════════════════════════════════════════════════════════
  //  UI: Dialog Informasi Premium
  // ══════════════════════════════════════════════════════════════
  void _showInfoDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Info',
      barrierColor: Colors.black.withOpacity(0.88),
      transitionDuration: const Duration(milliseconds: 350),
      transitionBuilder: (ctx, anim, _, child) {
        final curved =
            CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curved,
          child: FadeTransition(opacity: anim, child: child),
        );
      },
      pageBuilder: (ctx, _, __) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 320,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(28),
              border:
                  Border.all(color: _red.withOpacity(0.45), width: 1.2),
              boxShadow: [
                BoxShadow(
                    color: _redGlow.withOpacity(0.20),
                    blurRadius: 50,
                    spreadRadius: 4),
                BoxShadow(
                    color: Colors.black.withOpacity(0.75),
                    blurRadius: 24),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Gradient header strip ──────────────────
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [_redDeep, _red, _pink, _redBright]),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
                  child: Column(
                    children: [
                      // Icon lingkaran gradien
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [_red, _redDeep, const Color(0xFF1A0008)],
                            stops: const [0.0, 0.55, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: _red.withOpacity(0.5),
                                blurRadius: 22,
                                spreadRadius: 2),
                          ],
                        ),
                        child: const Icon(Icons.info_outline_rounded,
                            color: Colors.white, size: 32),
                      ),

                      const SizedBox(height: 18),

                      // Judul
                      Text(
                        'Informasi Maintenance',
                        style: TextStyle(
                          color: _white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                          shadows: [
                            Shadow(
                                color: _red.withOpacity(0.4),
                                blurRadius: 12)
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 6),

                      // Divider tipis
                      Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Colors.transparent,
                            _red.withOpacity(0.4),
                            Colors.transparent,
                          ]),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Pesan
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _red.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: _red.withOpacity(0.18), width: 1),
                        ),
                        child: Text(
                          widget.message.isNotEmpty
                              ? widget.message
                              : 'Aplikasi sedang dalam pemeliharaan.\nMohon tunggu hingga proses selesai.',
                          style: TextStyle(
                            color: _textMain,
                            fontSize: 13,
                            height: 1.65,
                            letterSpacing: 0.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // Badge versi
                      if (widget.version.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              _red.withOpacity(0.18),
                              _redDim.withOpacity(0.18),
                            ]),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color: _red.withOpacity(0.4), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.new_releases_rounded,
                                  color: _redLight, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'Versi  ${widget.version}',
                                style: TextStyle(
                                  color: _redLight,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 22),

                      // Tombol Tutup
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_redDim, _red, _pink],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                  color: _red.withOpacity(0.45),
                                  blurRadius: 18,
                                  offset: const Offset(0, 4)),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'Tutup',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  HELPER: Stagger wrapper
  // ══════════════════════════════════════════════════════════════
  Widget _stagger(int i, Widget child) {
    return FadeTransition(
      opacity: _staggerFade[i],
      child: SlideTransition(position: _staggerSlide[i], child: child),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _bgDeep,
      body: Stack(
        children: [
          // ── Layer 1: Background gradient radial ──────────────
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.4),
                radius: 1.2,
                colors: [
                  const Color(0xFF120008),
                  const Color(0xFF07000C),
                  _bgDeep,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // ── Layer 2: Grid + scanline + partikel animasi ───────
          AnimatedBuilder(
            animation: Listenable.merge([_orbit1Anim, _scanAnim]),
            builder: (_, __) => CustomPaint(
              size: Size(size.width, size.height),
              painter: _CyberBgPainter(
                angle:    _orbit1Anim.value,
                scanProg: _scanAnim.value,
              ),
            ),
          ),

          // ── Layer 3: Radial glow tengah ───────────────────────
          AnimatedBuilder(
            animation: _glowAnim,
            builder: (_, __) => Center(
              child: Container(
                width: size.width * 0.85,
                height: size.width * 0.85,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _red.withOpacity(0.08 + 0.06 * _glowAnim.value),
                      _purple.withOpacity(0.04 + 0.03 * _glowAnim.value),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // ── Layer 4: Content ──────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: Column(
                    children: [
                      const SizedBox(height: 52),

                      // ── ICON ANIMASI ─────────────────────
                      _stagger(0, _buildAnimatedIcon()),

                      const SizedBox(height: 32),

                      // ── JUDUL & SUBTITLE ─────────────────
                      _stagger(1, _buildTitleSection()),

                      const SizedBox(height: 28),

                      // ── CARD KONTEN ──────────────────────
                      _stagger(2, _buildMainCard()),

                      const SizedBox(height: 22),

                      // ── TOMBOL & COUNTDOWN ───────────────
                      _stagger(3, _buildLaterSection()),

                      const SizedBox(height: 28),

                      // ── FOOTER ───────────────────────────
                      _stagger(4, _buildFooter()),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  SECTION: Animated Icon (dual orbit + pulse core)
  // ══════════════════════════════════════════════════════════════
  Widget _buildAnimatedIcon() {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnim, _orbit1Anim, _orbit2Anim, _glowAnim]),
        builder: (_, __) => SizedBox(
          width: 180,
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glow besar di belakang
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _red.withOpacity(0.14 * _glowAnim.value),
                      _purple.withOpacity(0.06 * _glowAnim.value),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // Orbit ring luar — searah jarum jam, lebih tipis
              Transform.rotate(
                angle: _orbit1Anim.value,
                child: Container(
                  width: 162,
                  height: 162,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _red.withOpacity(0.20),
                      width: 1.2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Dot besar orbit 1
                      Align(
                        alignment: const Alignment(0.9, -0.55),
                        child: _orbitDot(_red, 8, 14),
                      ),
                      // Dot kecil orbit 1 (ekor)
                      Align(
                        alignment: const Alignment(-0.6, 0.88),
                        child: _orbitDot(_redLight.withOpacity(0.5), 4, 6),
                      ),
                    ],
                  ),
                ),
              ),

              // Orbit ring tengah — berlawanan arah, dashed style
              Transform.rotate(
                angle: _orbit2Anim.value,
                child: Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _pink.withOpacity(0.18),
                      width: 1.0,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Align(
                        alignment: const Alignment(-0.85, 0.6),
                        child: _orbitDot(_pink, 6, 10),
                      ),
                      Align(
                        alignment: const Alignment(0.7, -0.8),
                        child: _orbitDot(_redBright.withOpacity(0.4), 3, 5),
                      ),
                    ],
                  ),
                ),
              ),

              // Inner static ring
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _red.withOpacity(0.12),
                    width: 1,
                  ),
                ),
              ),

              // Core icon — pulse + glow
              Transform.scale(
                scale: _pulseAnim.value,
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _red,
                        _redDim,
                        _redDeep,
                        const Color(0xFF1F000A),
                      ],
                      stops: const [0.0, 0.4, 0.7, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _redGlow.withOpacity(0.7 * _pulseAnim.value),
                        blurRadius: 40,
                        spreadRadius: 8,
                      ),
                      BoxShadow(
                        color: _red.withOpacity(0.25),
                        blurRadius: 80,
                        spreadRadius: 20,
                      ),
                      BoxShadow(
                        color: _purple.withOpacity(0.15),
                        blurRadius: 50,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.system_update_alt_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
              ),

              // Corner glow dots (4 sudut orbit)
              ..._buildCornerGlows(),
            ],
          ),
        ),
      ),
    );
  }

  // Dot orbit helper
  Widget _orbitDot(Color color, double size, double blur) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.8), blurRadius: blur),
        ],
      ),
    );
  }

  // 4 sudut glow kecil
  List<Widget> _buildCornerGlows() {
    const offsets = [
      Offset(-68, -68), Offset(68, -68),
      Offset(-68,  68), Offset( 68,  68),
    ];
    return offsets.map((pos) {
      return Positioned(
        left: 90 + pos.dx - 3,
        top:  90 + pos.dy - 3,
        child: AnimatedBuilder(
          animation: _pulseAnim,
          builder: (_, __) => Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _red.withOpacity(_pulseAnim.value * 0.6),
              boxShadow: [
                BoxShadow(
                    color: _red.withOpacity(0.4 * _pulseAnim.value),
                    blurRadius: 6),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  // ══════════════════════════════════════════════════════════════
  //  SECTION: Title + Subtitle
  // ══════════════════════════════════════════════════════════════
  Widget _buildTitleSection() {
    return Column(
      children: [
        // Judul utama dengan glow
        ShaderMask(
          shaderCallback: (b) => LinearGradient(
            colors: [_redBright, _redLight, _red],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(b),
          child: const Text(
            'Maintenance!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w900,
              fontFamily: 'Orbitron',
              letterSpacing: 2.5,
            ),
          ),
        ),

        const SizedBox(height: 4),

        // Subtitle
        Text(
          'Aplikasi sedang dalam pemeliharaan',
          style: TextStyle(
            color: _textSub,
            fontSize: 13,
            letterSpacing: 0.5,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 12),

        // Divider glow
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.transparent, _red.withOpacity(0.5)]),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _red,
                boxShadow: [BoxShadow(color: _red, blurRadius: 8)],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 40,
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [_red.withOpacity(0.5), Colors.transparent]),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  SECTION: Card Konten Utama
  // ══════════════════════════════════════════════════════════════
  Widget _buildMainCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _red.withOpacity(0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
              color: _red.withOpacity(0.12),
              blurRadius: 30,
              spreadRadius: 2),
          BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 20),
        ],
      ),
      child: Column(
        children: [
          // ── Top accent bar gradient ────────────────────────
          Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [_redDeep, _red, _pink, _redLight]),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28)),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
            child: Column(
              children: [
                // ── Pesan maintenance ──────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: _red.withOpacity(0.15), width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: _red.withOpacity(0.3), width: 1),
                        ),
                        child: const Icon(Icons.warning_amber_rounded,
                            color: _red, size: 17),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.message.isNotEmpty
                              ? widget.message
                              : 'Aplikasi sedang dalam pemeliharaan. Harap tunggu.',
                          style: TextStyle(
                            color: _textMain,
                            fontSize: 13.5,
                            height: 1.65,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Badge versi jika ada ───────────────────
                if (widget.version.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _buildVersionBadge(),
                ],

                const SizedBox(height: 20),

                // ── 2 Tombol: Information & Download ──────
                Row(
                  children: [
                    // Tombol Information
                    Expanded(
                      child: _buildInfoButton(),
                    ),
                    const SizedBox(width: 12),
                    // Tombol Download New Version
                    Expanded(
                      child: _buildDownloadButton(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Badge versi ─────────────────────────────────────────────
  Widget _buildVersionBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          _red.withOpacity(0.12),
          _redDim.withOpacity(0.10),
        ]),
        borderRadius: BorderRadius.circular(30),
        border:
            Border.all(color: _red.withOpacity(0.35), width: 1),
        boxShadow: [
          BoxShadow(
              color: _red.withOpacity(0.1),
              blurRadius: 12,
              spreadRadius: 0),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.new_releases_rounded,
              color: _redLight, size: 15),
          const SizedBox(width: 8),
          Text(
            'Version  ${widget.version}',
            style: TextStyle(
              color: _redLight,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // ── Tombol Information ────────────────────────────────────────
  Widget _buildInfoButton() {
    return GestureDetector(
      onTap: _showInfoDialog,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _red.withOpacity(0.5), width: 1.2),
          boxShadow: [
            BoxShadow(
                color: _red.withOpacity(0.08),
                blurRadius: 14,
                spreadRadius: 0),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: _red.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.info_outline_rounded,
                  color: _redLight, size: 14),
            ),
            const SizedBox(width: 8),
            Text(
              'information',
              style: TextStyle(
                color: _redLight,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tombol Download New Version (shimmer animasi) ─────────────
  Widget _buildDownloadButton() {
    final bool hasUrl = widget.downloadUrl.isNotEmpty;

    return GestureDetector(
      onTapDown: hasUrl ? (_) => setState(() => _btnPressed = true) : null,
      onTapUp: hasUrl ? (_) => setState(() => _btnPressed = false) : null,
      onTapCancel: hasUrl ? () => setState(() => _btnPressed = false) : null,
      onTap: hasUrl ? () => _openUrl(widget.downloadUrl) : null,
      child: AnimatedScale(
        scale: _btnPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedOpacity(
          opacity: hasUrl ? 1.0 : 0.35,
          duration: const Duration(milliseconds: 250),
          child: Container(
            height: 52,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_redDim, _red, _pink],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: hasUrl
                  ? [
                      BoxShadow(
                          color: _red.withOpacity(0.5),
                          blurRadius: 18,
                          offset: const Offset(0, 4)),
                      BoxShadow(
                          color: _pink.withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 0),
                    ]
                  : [],
            ),
            child: Stack(
              children: [
                // Shimmer efek (hanya jika ada URL)
                if (hasUrl)
                  AnimatedBuilder(
                    animation: _shimmerAnim,
                    builder: (_, __) => Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white
                                  .withOpacity(0.12),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                            transform: GradientRotation(
                                _shimmerAnim.value),
                          ),
                        ),
                      ),
                    ),
                  ),
                // Label
                Center(
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.download_rounded,
                          color: Colors.white, size: 17),
                      const SizedBox(width: 7),
                      const Flexible(
                        child: Text(
                          'Download New Version',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  SECTION: Tombol Later + Countdown
  // ══════════════════════════════════════════════════════════════
  Widget _buildLaterSection() {
    return Column(
      children: [
        // Tombol Later / Re-check
        GestureDetector(
          onTap: _checking ? null : _checkStatus,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 13),
            decoration: BoxDecoration(
              color: _checking
                  ? _red.withOpacity(0.08)
                  : Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _checking
                    ? _red.withOpacity(0.25)
                    : Colors.white.withOpacity(0.07),
                width: 1,
              ),
            ),
            child: _checking
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          color: _redLight,
                          strokeWidth: 1.8,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Memeriksa...',
                        style: TextStyle(
                            color: _textSub, fontSize: 12.5),
                      ),
                    ],
                  )
                : Text(
                    'Later',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.30),
                      fontSize: 13.5,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 18),

        // Auto recheck countdown
        AnimatedBuilder(
          animation: _glowAnim,
          builder: (_, __) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Blinking dot merah
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _red.withOpacity(
                      0.5 + 0.45 * _glowAnim.value),
                  boxShadow: [
                    BoxShadow(
                        color: _red.withOpacity(
                            0.7 * _glowAnim.value),
                        blurRadius: 8),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Auto check dalam  $_countdown  detik',
                style: TextStyle(
                  color: _textSub.withOpacity(0.7),
                  fontSize: 10.5,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  SECTION: Footer
  // ══════════════════════════════════════════════════════════════
  Widget _buildFooter() {
    return Column(
      children: [
        // Divider
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.transparent,
                    _red.withOpacity(0.2),
                  ]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _red.withOpacity(0.4),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    _red.withOpacity(0.2),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Copyright
        Text(
          '© NoMercy-Project  App System',
          style: TextStyle(
            color: Colors.white.withOpacity(0.09),
            fontSize: 10,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  CUSTOM PAINTER — Cyber Background
//  Grid merah gelap + scanline + floating particles
// ════════════════════════════════════════════════════════════════
class _CyberBgPainter extends CustomPainter {
  final double angle;
  final double scanProg;

  const _CyberBgPainter({required this.angle, required this.scanProg});

  static const Color _red   = Color(0xFFFF1744);
  static const Color _pink  = Color(0xFFFF206E);
  static const Color _purp  = Color(0xFF6A0572);

  @override
  void paint(Canvas canvas, Size size) {
    // ── Grid halus ──────────────────────────────────────────
    final gridPaint = Paint()
      ..color = _red.withOpacity(0.022)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    const g = 28.0;
    for (double x = 0; x <= size.width; x += g) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += g) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // ── Grid aksen (tiap 5 kotak) ────────────────────────────
    final accentPaint = Paint()
      ..color = _red.withOpacity(0.048)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    for (double x = 0; x <= size.width; x += g * 5) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), accentPaint);
    }
    for (double y = 0; y <= size.height; y += g * 5) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), accentPaint);
    }

    // ── Titik dot di persilangan ─────────────────────────────
    final dotPaint = Paint()..style = PaintingStyle.fill;
    for (double x = 0; x <= size.width; x += g) {
      for (double y = 0; y <= size.height; y += g) {
        final isAccent =
            (x % (g * 5) < 0.01) || (y % (g * 5) < 0.01);
        dotPaint.color = isAccent
            ? _red.withOpacity(0.10)
            : _red.withOpacity(0.03);
        canvas.drawCircle(Offset(x, y), isAccent ? 1.5 : 0.8, dotPaint);
      }
    }

    // ── Scanline merah bergerak dari atas ke bawah ───────────
    final double sy = size.height * scanProg;
    final scanPaintLine = Paint()
      ..color = _red.withOpacity(0.03)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, sy), Offset(size.width, sy), scanPaintLine);
    final scanGlow = Paint()
      ..color = _red.withOpacity(0.015)
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
        Offset(0, sy - 4), Offset(size.width, sy - 4), scanGlow);

    // ── Floating particles (seeded random — smooth float) ────
    final rng = math.Random(42);
    final t   = angle / (2 * math.pi);
    for (int i = 0; i < 18; i++) {
      final bx  = rng.nextDouble() * size.width;
      final by  = rng.nextDouble() * size.height;
      final ox  = math.cos(t * 2 * math.pi + i * 0.44) * 9;
      final oy  = math.sin(t * 2 * math.pi + i * 0.72) * 16;
      final r   = 0.8 + rng.nextDouble() * 1.6;
      final idx = i % 3;
      final clr = idx == 0
          ? _red.withOpacity(0.12)
          : idx == 1
              ? _pink.withOpacity(0.08)
              : _purp.withOpacity(0.07);
      final particlePaint = Paint()
        ..color = clr
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(bx + ox, by + oy), r, particlePaint);
    }
  }

  @override
  bool shouldRepaint(_CyberBgPainter old) =>
      old.angle != angle || old.scanProg != scanProg;
}
