import 'dart:ui';
import 'package:flutter/material.dart';
import 'manage_server.dart';
import 'wifi_internal.dart';
import 'wifi_external.dart';
import 'ddos_panel.dart';
import 'nik_check.dart';
import 'tiktok_page.dart';
import 'instagram_page.dart';
import 'qr_gen.dart';
import 'domain_page.dart';
import 'spam_ngl.dart';
import 'gemini_ai_page.dart';
import 'ip_scanner.dart';
import 'port_scanner.dart';
import 'phone_lookup.dart';
import 'device_dashboard.dart';
import 'obf_page.dart';
import 'youtube_tool.dart';

class ToolsPage extends StatefulWidget {
  final String sessionKey;
  final String userRole;
  final List<Map<String, dynamic>> listDoos;

  const ToolsPage({
    super.key,
    required this.sessionKey,
    required this.userRole,
    required this.listDoos,
  });

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage>
    with TickerProviderStateMixin {
  late String sessionKey;
  late String userRole;
  late List<Map<String, dynamic>> listDoos;

  late AnimationController _glowController;
  late AnimationController _shimmerController;
  late AnimationController _entranceController;

  // --- Warna Tema (sama seperti Dashboard) ---
  final Color bgDark = const Color(0xFF000000);
  final Color primaryPurple = const Color(0xFF7B2FF7);
  final Color accentPurple = const Color(0xFFB388FF);
  final Color lightPurple = const Color(0xFFD1B3FF);
  final Color primaryWhite = Colors.white;
  final Color accentGrey = Colors.grey.shade400;
  final Color cardGlass = Colors.white.withOpacity(0.05);
  final Color borderGlass = Colors.white.withOpacity(0.1);
  final Color modalDark = const Color(0xFF0D0616);

  @override
  void initState() {
    super.initState();
    sessionKey = widget.sessionKey;
    userRole = widget.userRole;
    listDoos = widget.listDoos;

    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2, milliseconds: 200),
      vsync: this,
    )..repeat();

    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _glowController.dispose();
    _shimmerController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  Widget _buildStaggeredEntry({
    required int index,
    required Widget child,
  }) {
    final int total = 6;
    final double start = (index / total) * 0.6;
    final double end = (start + 0.4).clamp(0.0, 1.0);
    final Animation<double> curved = CurvedAnimation(
      parent: _entranceController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: curved,
      builder: (context, _) {
        final double t = curved.value;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 40 * (1 - t)),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildGlowBorder({
    required Widget child,
    double borderRadius = 22,
    double borderWidth = 1.6,
  }) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, _) {
        return Container(
          padding: EdgeInsets.all(borderWidth),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: SweepGradient(
              transform: GradientRotation(_glowController.value * 6.2832),
              colors: [
                accentPurple.withOpacity(0.0),
                accentPurple.withOpacity(0.0),
                lightPurple,
                accentPurple,
                primaryPurple,
                accentPurple.withOpacity(0.0),
                accentPurple.withOpacity(0.0),
              ],
              stops: const [0.0, 0.35, 0.45, 0.5, 0.55, 0.65, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: accentPurple.withOpacity(0.15),
                blurRadius: 10,
                spreadRadius: 0.5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius - borderWidth),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildShimmerText(String text, {double fontSize = 22}) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        final double t = _shimmerController.value;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-2.0 + 4.0 * t, -0.3),
              end: Alignment(-1.0 + 4.0 * t, 0.3),
              colors: const [
                Colors.white,
                Colors.white,
                Colors.white70,
                Colors.white,
                Colors.white,
              ],
              stops: const [0.0, 0.40, 0.5, 0.60, 1.0],
            ).createShader(bounds);
          },
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontFamily: 'Orbitron',
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isOwner = userRole.toLowerCase() == "owner";

    return Scaffold(
      backgroundColor: bgDark,
      body: Stack(
        children: [
          // === GRID BACKGROUND ===
          Positioned.fill(
            child: CustomPaint(
              painter: _ToolsGridPainter(lineColor: borderGlass),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // === HEADER ===
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cardGlass,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderGlass),
                          boxShadow: [
                            BoxShadow(
                              color: accentPurple.withOpacity(0.25),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Icon(Icons.grid_view_rounded,
                            color: accentPurple, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildShimmerText("Tools Gateway", fontSize: 22),
                            const SizedBox(height: 4),
                            Text(
                              "Select your weapon",
                              style: TextStyle(
                                color: accentGrey,
                                fontSize: 13,
                                fontFamily: 'ShareTechMono',
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isOwner)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: cardGlass,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color: accentPurple.withOpacity(0.6)),
                            boxShadow: [
                              BoxShadow(
                                color: accentPurple.withOpacity(0.2),
                                blurRadius: 8,
                                spreadRadius: 0.5,
                              ),
                            ],
                          ),
                          child: Text(
                            "OWNER",
                            style: TextStyle(
                              color: accentPurple,
                              fontSize: 12,
                              fontFamily: 'Orbitron',
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // === CATEGORY LIST ===
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      _buildStaggeredEntry(
                        index: 0,
                        child: _buildToolCard(
                          icon: Icons.flash_on,
                          title: "DDoS Panel",
                          subtitle: "L4/L7 Stress Test Attack",
                          onTap: () => _showDDoSTools(context),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStaggeredEntry(
                        index: 1,
                        child: _buildToolCard(
                          icon: Icons.wifi_tethering,
                          title: "Network Tools",
                          subtitle: "WiFi Killer & Spam NGL",
                          onTap: () => _showNetworkTools(context),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStaggeredEntry(
                        index: 2,
                        child: _buildToolCard(
                          icon: Icons.travel_explore,
                          title: "OSINT Tools",
                          subtitle: "NIK Checker, Domain, IP",
                          onTap: () => _showOSINTTools(context),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStaggeredEntry(
                        index: 3,
                        child: _buildToolCard(
                          icon: Icons.download_rounded,
                          title: "Media Downloader",
                          subtitle: "TikTok & Instagram No Watermark",
                          onTap: () => _showDownloaderTools(context),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStaggeredEntry(
                        index: 4,
                        child: _buildToolCard(
                          icon: Icons.auto_fix_high,
                          title: "Generator Tools",
                          subtitle: "QR Generator & Utilities",
                          onTap: () => _showUtilityTools(context),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStaggeredEntry(
                        index: 5,
                        child: _buildToolCard(
                          icon: Icons.rocket_launch,
                          title: "Quick Access",
                          subtitle: "Favorites",
                          onTap: () => _showQuickAccess(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, double scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: _buildGlowBorder(
          borderRadius: 22,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryPurple.withOpacity(0.28),
                  bgDark,
                ],
              ),
            ),
            child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardGlass,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderGlass),
                ),
                child: Icon(icon, color: accentPurple, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: primaryWhite,
                        fontSize: 16,
                        fontFamily: 'Orbitron',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: accentGrey,
                        fontSize: 12,
                        fontFamily: 'ShareTechMono',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cardGlass,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderGlass),
                ),
                child: Icon(Icons.chevron_right_rounded,
                    color: accentPurple, size: 20),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== QUICK ACCESS ====================
  void _showQuickAccess(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: modalDark,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          border: Border.all(color: primaryPurple.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: primaryPurple.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryPurple, accentPurple],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.star_rounded, color: primaryWhite),
                  const SizedBox(width: 12),
                  Text(
                    "⚡ Quick Access",
                    style: TextStyle(
                      color: primaryWhite,
                      fontSize: 20,
                      fontFamily: 'Orbitron',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "FAVORITES",
                      style: TextStyle(
                        color: primaryWhite,
                        fontSize: 10,
                        fontFamily: 'Orbitron',
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Tools List
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // 🔥 GEMINI AI
                      _buildToolOption(
                        icon: Icons.auto_awesome_rounded,
                        label: "🤖 Gemini AI",
                        color: const Color(0xFF00D4FF),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const GeminiAIPage(),
                            ),
                          );
                        },
                      ),
                      
                      // 🔥 OBFUSCATOR
                      _buildToolOption(
                        icon: Icons.security_rounded,
                        label: "🔐 Obfuscator",
                        color: const Color(0xFFFF6B35),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ObfPage(),
                            ),
                          );
                        },
                      ),
                      
                      // 🔥 RAT CONTROL
                      _buildToolOption(
                        icon: Icons.devices_rounded,
                        label: "🖥️ Rat Control",
                        color: const Color(0xFFFF0000),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DeviceDashboardPage(
                                sessionKey: sessionKey,
                                userRole: userRole,
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Info card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primaryPurple.withOpacity(0.15),
                              accentPurple.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: primaryPurple.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: accentPurple,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Akses cepat ke tools favoritmu!',
                                style: TextStyle(
                                  color: accentGrey,
                                  fontSize: 12,
                                  fontFamily: 'ShareTechMono',
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
          ],
        ),
      ),
    );
  }

  // ==================== DDoS TOOLS ====================
  void _showDDoSTools(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: modalDark,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          border: Border.all(color: primaryPurple.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: primaryPurple.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryPurple, accentPurple],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.flash_on, color: primaryWhite),
                  const SizedBox(width: 12),
                  Text(
                    "DDoS Tools",
                    style: TextStyle(
                      color: primaryWhite,
                      fontSize: 20,
                      fontFamily: 'Orbitron',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildToolOption(
                      icon: Icons.flash_on,
                      label: "Attack Panel",
                      color: lightPurple,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AttackPanel(
                              sessionKey: sessionKey,
                              listDoos: listDoos,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildToolOption(
                      icon: Icons.dns,
                      label: "Manage Server",
                      color: lightPurple,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ManageServerPage(keyToken: sessionKey),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== NETWORK TOOLS ====================
  void _showNetworkTools(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: modalDark,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          border: Border.all(color: primaryPurple.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: primaryPurple.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryPurple, accentPurple],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.wifi, color: primaryWhite),
                  const SizedBox(width: 12),
                  Text(
                    "Network Tools",
                    style: TextStyle(
                      color: primaryWhite,
                      fontSize: 20,
                      fontFamily: 'Orbitron',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildToolOption(
                      icon: Icons.newspaper_outlined,
                      label: "Spam NGL",
                      color: lightPurple,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => NglPage()),
                        );
                      },
                    ),
                    _buildToolOption(
                      icon: Icons.wifi_off,
                      label: "WiFi Killer (Internal)",
                      color: lightPurple,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => WifiKillerPage()),
                        );
                      },
                    ),
                    if (userRole == "vip" || userRole == "owner")
                      _buildToolOption(
                        icon: Icons.router,
                        label: "WiFi Killer (External)",
                        color: lightPurple,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WifiInternalPage(sessionKey: sessionKey),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== OSINT TOOLS ====================
  void _showOSINTTools(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: modalDark,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          border: Border.all(color: primaryPurple.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: primaryPurple.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryPurple, accentPurple],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: primaryWhite),
                  const SizedBox(width: 12),
                  Text(
                    "OSINT Tools",
                    style: TextStyle(
                      color: primaryWhite,
                      fontSize: 20,
                      fontFamily: 'Orbitron',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildToolOption(
                      icon: Icons.badge,
                      label: "NIK Detail",
                      color: lightPurple,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NikCheckerPage()),
                        );
                      },
                    ),
                    _buildToolOption(
                      icon: Icons.domain,
                      label: "Domain OSINT",
                      color: lightPurple,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const DomainOsintPage()),
                        );
                      },
                    ),
                    _buildToolOption(
                      icon: Icons.person_search,
                      label: "Phone LookUp",
                      color: lightPurple,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PhoneLookupPage()),
                        );
                      },
                    ),
                    _buildToolOption(
                      icon: Icons.email,
                      label: "Email Osint",
                      color: lightPurple,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EmailOsintPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== DOWNLOADER TOOLS ====================
  void _showDownloaderTools(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: modalDark,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          border: Border.all(color: primaryPurple.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: primaryPurple.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryPurple, accentPurple],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.download, color: primaryWhite),
                  const SizedBox(width: 12),
                  Text(
                    "Media Downloader",
                    style: TextStyle(
                      color: primaryWhite,
                      fontSize: 20,
                      fontFamily: 'Orbitron',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildToolOption(
                      icon: Icons.video_library,
                      label: "TikTok Downloader",
                      color: lightPurple,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TiktokDownloaderPage()),
                        );
                      },
                    ),
                    _buildToolOption(
                      icon: Icons.play_arrow_rounded,
                      label: "Youtube",
                      color: lightPurple,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const YouTubeToolPage()),
                        );
                      },
                    ),
                    _buildToolOption(
                      icon: Icons.camera_alt,
                      label: "Instagram Downloader",
                      color: lightPurple,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const InstagramDownloaderPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== UTILITY TOOLS ====================
  void _showUtilityTools(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: modalDark,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          border: Border.all(color: primaryPurple.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: primaryPurple.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryPurple, accentPurple],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.build, color: primaryWhite),
                  const SizedBox(width: 12),
                  Text(
                    "Utility Tools",
                    style: TextStyle(
                      color: primaryWhite,
                      fontSize: 20,
                      fontFamily: 'Orbitron',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildToolOption(
                      icon: Icons.qr_code,
                      label: "QR Generator",
                      color: lightPurple,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const QrGeneratorPage()),
                        );
                      },
                    ),
                    _buildToolOption(
                      icon: Icons.security,
                      label: "IP Scanner",
                      color: lightPurple,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PortScannerPage()),
                        );
                      },
                    ),
                    _buildToolOption(
                      icon: Icons.network_check,
                      label: "Port Scanner",
                      color: lightPurple,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const IpScannerPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== BUILD TOOL OPTION ====================
  Widget _buildToolOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: cardGlass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGlass),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryPurple.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: primaryPurple.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: primaryWhite,
            fontFamily: 'Orbitron',
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: primaryPurple.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.arrow_forward_ios, color: color, size: 14),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.hourglass_top, color: primaryWhite),
            const SizedBox(width: 8),
            Text(
              'Feature Coming Soon!',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontWeight: FontWeight.bold,
                color: primaryWhite,
              ),
            ),
          ],
        ),
        backgroundColor: primaryPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ==================== GRID PAINTER ====================
class _ToolsGridPainter extends CustomPainter {
  final Color lineColor;
  final double cellSize;

  _ToolsGridPainter({required this.lineColor, this.cellSize = 28});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += cellSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += cellSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ToolsGridPainter oldDelegate) =>
      oldDelegate.lineColor != lineColor || oldDelegate.cellSize != cellSize;
}