// info_page.dart - FULL THEME PROVIDER SUPPORT
// + GRID BACKGROUND + GLOW 0.30

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'api_config.dart';
import 'theme_provider.dart';

// ─── GRID PATTERN PAINTER ────────────────────────────────────────────────────
class InfoGridPatternPainter extends CustomPainter {
  final Color color;
  final double spacing;

  InfoGridPatternPainter({this.color = Colors.white, this.spacing = 30.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final paintDiag = Paint()
      ..color = color.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4;

    for (double x = -size.height; x < size.width + size.height; x += spacing * 2) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), paintDiag);
    }
    for (double x = -size.height; x < size.width + size.height; x += spacing * 2) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), paintDiag);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Rules data ───────────────────────────────────────────────────────────────
const _rules = [
  _Rule(
    title: 'Larangan Barter Akun',
    desc: 'Akun tidak boleh ditukar dengan barang, jasa, atau akun lain dalam bentuk apa pun bego.',
    icon: Icons.swap_horiz_rounded,
    color: Color(0xFFF59E0B),
  ),
  _Rule(
    title: 'Larangan Membagikan Akun',
    desc: 'Setiap akun bersifat pribadi dan hanya boleh digunakan oleh pemilik akun yang terdaftar tolol.',
    icon: Icons.share_rounded,
    color: Color(0xFF60A5FA),
  ),
  _Rule(
    title: 'Larangan Menjual Akun',
    desc: 'Member TIDAK diperbolehkan menjual akun. Penjualan hanya boleh dilakukan oleh role yang diizinkan secara resmi member doang ya goblok.',
    icon: Icons.sell_rounded,
    color: Color(0xFFEF4444),
  ),
  _Rule(
    title: 'Larangan Jual Durasi Ilegal',
    desc: 'Dilarang menjual akses harian, mingguan, trial, atau sejenisnya di luar ketentuan yang telah ditetapkan liat ya anjing.',
    icon: Icons.timer_off_rounded,
    color: Color(0xFFFF4040),
  ),
  _Rule(
    title: 'Larangan Banting Harga',
    desc: 'Dilarang merusak atau menurunkan harga yang telah ditentukan di bawah ketentuan NeverSyx.',
    icon: Icons.trending_down_rounded,
    color: Color(0xFF34D399),
  ),
];

class _Rule {
  final String title;
  final String desc;
  final IconData icon;
  final Color color;
  const _Rule({required this.title, required this.desc,
      required this.icon, required this.color});
}

// ─── Fallback Data ────────────────────────────────────────────────────────────
const _fallbackServerInfo = {
  'name': 'CYNER Server',
  'version': '3..0',
  'status': 'online',
};

// ─── Page ─────────────────────────────────────────────────────────────────────
class InfoPage extends StatefulWidget {
  final String sessionKey;
  const InfoPage({super.key, required this.sessionKey});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> with TickerProviderStateMixin {
  Map<String, dynamic> serverInfo = _fallbackServerInfo;
  bool isLoading = false;

  bool   _apiOnline   = false;
  int    _pingMs      = 0;
  String _pingStatus  = 'Checking...';
  Timer? _pingTimer;

  // Animations
  late AnimationController _bgCtrl;
  late AnimationController _entranceCtrl;
  late AnimationController _pingDotCtrl;
  late AnimationController _sanctionCtrl;
  late AnimationController _pulseCtrl;

  late Animation<double> _entrance;
  late Animation<double> _pingDot;
  late Animation<double> _sanctionGlow;
  late Animation<double> _pulseAnim;

  int? _expandedRule;

  @override
  void initState() {
    super.initState();

    _bgCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 18))
      ..repeat();

    _entranceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _entrance = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic);

    _pingDotCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _pingDot = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _pingDotCtrl, curve: Curves.easeInOut));

    _sanctionCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _sanctionGlow = Tween<double>(begin: 0.2, end: 0.6)
        .animate(CurvedAnimation(parent: _sanctionCtrl, curve: Curves.easeInOut));

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _fetchServerInfo();
    _startPingLoop();
    
    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _pingTimer?.cancel();
    _bgCtrl.dispose();
    _entranceCtrl.dispose();
    _pingDotCtrl.dispose();
    _sanctionCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ─── API ────────────────────────────────────────────────────────────────────
  Future<void> _fetchServerInfo() async {
    try {
      final res = await http.get(Uri.parse(
          '$baseUrl/getServerInfo?key=${widget.sessionKey}'));
      if (res.statusCode == 200 && mounted) {
        setState(() { serverInfo = jsonDecode(res.body); });
      }
    } catch (_) {}
  }

  void _startPingLoop() {
    _checkPing();
    _pingTimer = Timer.periodic(const Duration(seconds: 5), (_) => _checkPing());
  }

  Future<void> _checkPing() async {
    final start = DateTime.now();
    try {
      final res = await http.get(Uri.parse(
              '$baseUrl/ping?key=${widget.sessionKey}'))
          .timeout(const Duration(seconds: 3));
      final ms = DateTime.now().difference(start).inMilliseconds;
      if (res.statusCode == 200 && mounted) {
        setState(() {
          _apiOnline  = true;
          _pingMs     = ms;
          _pingStatus = '${ms}ms';
        });
      } else {
        throw Exception();
      }
    } catch (_) {
      if (mounted) setState(() { 
        _apiOnline = false; 
        _pingMs = 0; 
        _pingStatus = 'Offline'; 
      });
    }
  }

  Color get _pingColor {
    if (!_apiOnline) return Colors.red;
    if (_pingMs < 200) return Colors.green;
    if (_pingMs < 500) return Colors.amber;
    return const Color(0xFFF97316);
  }

  String get _pingLabel {
    if (!_apiOnline) return 'OFFLINE';
    if (_pingMs < 200) return 'EXCELLENT';
    if (_pingMs < 500) return 'GOOD';
    return 'SLOW';
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: true,
          appBar: _buildAppBar(theme),
          body: Stack(
            children: [
              // ─── 1. BACKGROUND GRID ──────────────────────────────────────
              Positioned.fill(
                child: CustomPaint(
                  painter: InfoGridPatternPainter(
                    color: theme.primaryColor,
                    spacing: 30,
                  ),
                ),
              ),

              // ─── 2. GLOW KIRI ATAS (0.30) ──────────────────────────────
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topLeft,
                      radius: 0.9,
                      colors: [
                        theme.primaryColor.withOpacity(0.50),  // ✅ 0.30
                        theme.primaryColor.withOpacity(0.10),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ),

              // ─── 3. GLOW KEDUA (KANAN BAWAH) ────────────────────────────
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.bottomRight,
                      radius: 0.5,
                      colors: [
                        theme.accentColor.withOpacity(0.08),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                ),
              ),

              // ─── 4. OVERLAY GRADASI ──────────────────────────────────────
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.15),
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── 5. KONTEN ────────────────────────────────────────────────
              SafeArea(
                child: FadeTransition(
                  opacity: _entrance,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 48),
                    children: [
                      _buildHeroHeader(theme),
                      const SizedBox(height: 20),
                      _buildStatusCardModern(theme),
                      const SizedBox(height: 24),
                      _buildModernSectionHeader(theme),
                      const SizedBox(height: 16),
                      ..._rules.asMap().entries.map((e) =>
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ModernRuleCard(
                            rule: e.value,
                            number: e.key + 1,
                            isExpanded: _expandedRule == e.key,
                            onTap: () => setState(() {
                              _expandedRule = _expandedRule == e.key ? null : e.key;
                            }),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildSanctionCardModern(theme),
                      const SizedBox(height: 24),
                      _buildFooter(theme),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Hero Header ──────────────────────────────────────────────────────────
  Widget _buildHeroHeader(ThemeProvider theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (rect) => LinearGradient(
              colors: [theme.textPrimaryColor, theme.primaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(rect),
            child: const Text('Peraturan &\nInformasi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  letterSpacing: -0.5,
                )),
          ),
          const SizedBox(height: 8),
          Text('Patuhi aturan untuk kenyamanan bersama',
              style: TextStyle(color: theme.textSecondaryColor, fontSize: 13)),
        ],
      ),
    );
  }

  // ─── Status Card Modern ────────────────────────────────────────────────────
  Widget _buildStatusCardModern(ThemeProvider theme) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, __) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.cardColor, theme.backgroundColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _apiOnline ? _pingColor.withOpacity(0.3) : Colors.red.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (_apiOnline ? _pingColor : Colors.red).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        (_apiOnline ? _pingColor : Colors.red).withOpacity(0.15),
                        (_apiOnline ? _pingColor : Colors.red).withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _apiOnline ? Icons.check_circle_rounded : Icons.error_rounded,
                    color: _apiOnline ? _pingColor : Colors.red,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('API SERVER',
                          style: TextStyle(
                              color: theme.textSecondaryColor, fontSize: 11,
                              fontWeight: FontWeight.w600, letterSpacing: 1)),
                      const SizedBox(height: 4),
                      Text(_apiOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                              color: _apiOnline ? _pingColor : Colors.red,
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Container(
                  width: 56, height: 56,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 50, height: 50,
                        child: CircularProgressIndicator(
                          value: _apiOnline ? (_pingMs / 500).clamp(0.0, 1.0) : 0,
                          strokeWidth: 3,
                          backgroundColor: theme.borderColor,
                          color: _pingColor,
                        ),
                      ),
                      Text(_apiOnline ? '$_pingMs' : '0',
                          style: TextStyle(
                              color: _pingColor, fontSize: 14,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (!_apiOnline)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.wifi_off_rounded, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Koneksi ke server terputus',
                          style: TextStyle(color: theme.textSecondaryColor, fontSize: 12)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Modern Section Header ─────────────────────────────────────────────────
  Widget _buildModernSectionHeader(ThemeProvider theme) {
    return Row(
      children: [
        Container(
          width: 4, height: 28,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.primaryColor, theme.accentColor],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PERATURAN',
                style: TextStyle(color: theme.textPrimaryColor, fontSize: 18,
                    fontWeight: FontWeight.w800, letterSpacing: -0.3)),
            Text('Tap untuk melihat detail',
                style: TextStyle(color: theme.textSecondaryColor, fontSize: 11)),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('${_rules.length} ATURAN',
              style: TextStyle(color: theme.primaryColor, fontSize: 10,
                  fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  // ─── Sanction Card Modern ──────────────────────────────────────────────────
  Widget _buildSanctionCardModern(ThemeProvider theme) {
    return AnimatedBuilder(
      animation: _sanctionCtrl,
      builder: (_, __) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.cardColor.withOpacity(0.5), theme.backgroundColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.red.withOpacity(0.3 + _sanctionGlow.value * 0.2),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned(
                right: -20, top: -20,
                child: Icon(Icons.gavel_rounded,
                    size: 100, color: Colors.red.withOpacity(0.05)),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(Icons.warning_rounded,
                              color: Colors.red.withOpacity(0.8 + _sanctionGlow.value * 0.2),
                              size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text('SANKSI TEGAS',
                              style: TextStyle(color: Colors.red, fontSize: 16,
                                  fontWeight: FontWeight.w800, letterSpacing: 1)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.withOpacity(0.15)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.block_rounded, color: Colors.red, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text('Akun akan DIHAPUS secara permanen',
                                style: TextStyle(color: Colors.white, fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        _sanctionChip(theme, Icons.account_balance_wallet_rounded, 'Tanpa refund'),
                        _sanctionChip(theme, Icons.sync_disabled_rounded, 'Tanpa kompensasi'),
                        _sanctionChip(theme, Icons.person_off_rounded, 'Permanent ban'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sanctionChip(ThemeProvider theme, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.red.withOpacity(0.08),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.red, size: 12),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(color: theme.textSecondaryColor, fontSize: 10,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildFooter(ThemeProvider theme) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: theme.glassPrimary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.shield_moon_rounded, color: theme.primaryColor, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Dengan menggunakan aplikasi ini, pengguna dianggap telah '
                'menyetujui seluruh peraturan yang berlaku.',
                style: TextStyle(color: theme.textSecondaryColor, fontSize: 11, height: 1.5),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          height: 2, width: 30,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.primaryColor, theme.accentColor],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text('NeverSyx Lyoctra',
            style: TextStyle(color: theme.textSecondaryColor, fontSize: 10,
                fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        const SizedBox(width: 10),
        Container(
          height: 2, width: 30,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.primaryColor, theme.accentColor],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ]),
    ]);
  }

  PreferredSizeWidget _buildAppBar(ThemeProvider theme) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: const SizedBox.shrink(),
    );
  }
}

// ─── Modern Rule Card (Accordion) ────────────────────────────────────────────
class _ModernRuleCard extends StatelessWidget {
  final _Rule rule;
  final int number;
  final bool isExpanded;
  final VoidCallback onTap;

  const _ModernRuleCard({
    required this.rule,
    required this.number,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final color = rule.color;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isExpanded ? color.withOpacity(0.06) : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isExpanded ? color.withOpacity(0.4) : theme.borderColor,
            width: isExpanded ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: Text('$number',
                          style: TextStyle(color: color, fontSize: 14,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(rule.icon, color: color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(rule.title,
                        style: TextStyle(
                          color: isExpanded ? theme.textPrimaryColor : theme.textPrimaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        color: isExpanded ? color : theme.textSecondaryColor, size: 20),
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.glassPrimary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.borderColor),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 3, height: 30,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(rule.desc,
                            style: TextStyle(color: theme.textSecondaryColor, fontSize: 12,
                                height: 1.5)),
                      ),
                    ],
                  ),
                ),
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Animated Background ──────────────────────────────────────────────────────
class _AnimatedBg extends StatelessWidget {
  final AnimationController controller;
  final Color primaryColor;

  const _AnimatedBg({
    required this.controller,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) =>
          CustomPaint(painter: _BgPainter(controller.value, primaryColor)),
    );
  }
}

class _BgPainter extends CustomPainter {
  final double t;
  final Color primaryColor;

  _BgPainter(this.t, this.primaryColor);

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = primaryColor.withOpacity(0.06)
      ..strokeWidth = 0.5;
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final glow = Paint()
      ..shader = RadialGradient(colors: [
        primaryColor.withOpacity(0.06 + math.sin(t * math.pi * 2) * 0.02),
        Colors.transparent,
      ], radius: 0.9).createShader(Rect.fromCircle(
          center: Offset(size.width / 2, size.height * 0.15),
          radius: size.width * 0.7));
    canvas.drawCircle(
        Offset(size.width / 2, size.height * 0.15), size.width * 0.7, glow);
  }

  @override
  bool shouldRepaint(_BgPainter old) => old.t != t;
}