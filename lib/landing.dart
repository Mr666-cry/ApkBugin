// landing.dart - THEME PROVIDER FULLY INTEGRATED
// SEMUA WARNA IKUT BERUBAH SESUAI THEME
// 🎬 DENGAN VIDEO BANNER - MODIFIED BY SAM AI V8
// ✅ FIXED: MAINTENANCE PAGE INTEGRATION

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'api_config.dart';
import 'login_page.dart';
import 'buy_akses_sheet.dart';
import 'theme_provider.dart';
import 'maintenance_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late AnimationController _floatCtrl;
  
  // 🎬 VIDEO PLAYER
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;
  
  // 🔥 MAINTENANCE STATE
  bool _isCheckingMaintenance = false;
  bool _isMaintenanceMode = false;

  @override
  void initState() {
    super.initState();
    
    // 🔥 CEK MAINTENANCE DULU
    _checkMaintenance();
    
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic);
    
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeCtrl.forward();
    });
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🔥 MAINTENANCE CHECK
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Future<void> _checkMaintenance() async {
    if (_isCheckingMaintenance) return;
    _isCheckingMaintenance = true;

    try {
      final response = await http.get(
  Uri.parse('$baseUrl/api/app-status'),
);

      if (!mounted) {
        _isCheckingMaintenance = false;
        return;
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final isMaintenance = data['maintenance'] == true;

        if (isMaintenance) {
          // 🔥 TAMPILKAN MAINTENANCE PAGE
          _isMaintenanceMode = true;
          _isCheckingMaintenance = false;
          
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => MaintenancePage(
                    message: data['message'] ?? 'Aplikasi sedang dalam pemeliharaan.',
                    version: data['version'] ?? '2.0.0',
                    downloadUrl: data['downloadUrl'] ?? '',
                    onRetry: () {
                      // Cek ulang maintenance
                      _checkMaintenance();
                    },
                  ),
                ),
              );
            }
          });
          return;
        }
      }

      // Jika tidak maintenance, lanjutkan ke video
      _isCheckingMaintenance = false;
      _initVideo();

    } catch (e) {
      // Jika gagal cek maintenance, lanjutkan ke video
      debugPrint('⚠️ Maintenance check failed: $e');
      _isCheckingMaintenance = false;
      _initVideo();
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🎬 VIDEO INIT
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  void _initVideo() {
    _videoController = VideoPlayerController.asset(
      'assets/videos/banner_video.mp4',
    )..initialize().then((_) {
      if (!mounted) return;
      setState(() {
        _isVideoInitialized = true;
      });
      _videoController.setLooping(true);
      _videoController.play();
    }).catchError((e) {
      print('Error loading video: $e');
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _fadeCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 JIKA MAINTENANCE MODE, TAMPILKAN MAINTENANCE PAGE
    if (_isMaintenanceMode) {
      return const SizedBox.shrink(); // Sudah diganti di _checkMaintenance
    }

    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return Scaffold(
          backgroundColor: theme.backgroundColor,
          body: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 1.2,
                colors: [
                  theme.primaryColor.withOpacity(0.15),
                  theme.primaryColor.withOpacity(0.05),
                  theme.backgroundColor,
                  theme.backgroundColor,
                ],
                stops: const [0, 0.2, 0.5, 1],
              ),
            ),
            child: SafeArea(
              child: _isCheckingMaintenance
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Color(0xFFFF0040),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Memeriksa status aplikasi...',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  : FadeTransition(
                      opacity: _fadeAnim,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 24),
                            _buildLogoBox(theme),
                            const SizedBox(height: 32),
                            _buildBigTitle(theme),
                            const SizedBox(height: 28),
                            _buildDescCard(theme),
                            const SizedBox(height: 20),
                            _buildLoginButton(theme),
                            const SizedBox(height: 14),
                            _buildBuyAksesButton(theme),
                            const SizedBox(height: 14),
                            _buildContactSupportButton(theme),
                            const SizedBox(height: 28),
                            _buildSocialSection(theme),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  // 🎬 BUILD VIDEO PLAYER
  Widget _buildVideoPlayer(ThemeProvider theme) {
    if (!_isVideoInitialized) {
      return Container(
        color: Colors.black26,
        child: Center(
          child: CircularProgressIndicator(
            color: theme.primaryColor,
          ),
        ),
      );
    }
    
    return VideoPlayer(_videoController);
  }

  // 🎬 LOGO BOX DENGAN VIDEO
  Widget _buildLogoBox(ThemeProvider theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedBuilder(
        animation: _floatCtrl,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 5 * _floatCtrl.value),
            child: Container(
              width: double.infinity,
              height: 210,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.glassPrimary,
                    theme.glassSecondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: theme.primaryColor.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.15),
                    blurRadius: 30,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildVideoPlayer(theme),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            theme.backgroundColor.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(28),
                          ),
                          gradient: RadialGradient(
                            center: Alignment.topLeft,
                            radius: 0.8,
                            colors: [
                              theme.primaryColor.withOpacity(0.2),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBigTitle(ThemeProvider theme) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              theme.textPrimaryColor,
              theme.primaryColor,
              theme.textPrimaryColor,
            ],
            stops: const [0.0, 0.6, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          child: Text(
            'NeverSyx Lyoctra',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.textPrimaryColor,
              fontSize: 44,
              fontWeight: FontWeight.w900,
              fontFamily: 'Orbitron',
              letterSpacing: 4,
              height: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 140,
          height: 2.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                theme.primaryColor,
                theme.accentColor,
                Colors.transparent,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.5),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.primaryColor.withOpacity(0.1),
                theme.accentColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
          ),
          child: Text(
            'P R E M I U M   •   T E R U P D A T E   •   C A N G G I H',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.primaryColor,
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
              fontFamily: 'Orbitron',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescCard(ThemeProvider theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.glassPrimary,
              theme.glassSecondary,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.primaryColor.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.accentColor.withOpacity(0.6),
                    theme.primaryColor.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: theme.primaryColor.withOpacity(0.5), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.shield_outlined,
                  color: theme.primaryColor,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [theme.primaryColor, theme.accentColor],
              ).createShader(bounds),
              child: const Text(
                'LYOCTRA BUG',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Orbitron',
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Aplikasi dengan design elegant dan fitur terbaru.\nPengembangan langsung oleh TEAM LYOCTRA.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.textSecondaryColor,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton(ThemeProvider theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.primaryColor.withOpacity(0.15),
              theme.accentColor.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.primaryColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => LoginPage()),
            ),
            borderRadius: BorderRadius.circular(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rocket_launch_rounded, color: theme.primaryColor, size: 20),
                const SizedBox(width: 12),
                Text(
                  'LOGIN TO LYOCTRA',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Orbitron',
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactSupportButton(ThemeProvider theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: theme.glassPrimary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.textSecondaryColor.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openUrl('https://t.me/Renn_XyvXd'),
            borderRadius: BorderRadius.circular(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.headset_mic_rounded, color: theme.textSecondaryColor, size: 20),
                const SizedBox(width: 12),
                Text(
                  'CONTACT SUPPORT',
                  style: TextStyle(
                    color: theme.textSecondaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Orbitron',
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialSection(ThemeProvider theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.glassPrimary,
              theme.glassSecondary,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.textSecondaryColor.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
              ),
              child: Text(
                'HUBUNGI KAMI',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 11,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSocialItem(
                  theme: theme,
                  icon: FontAwesomeIcons.telegram,
                  bgColor: theme.primaryColor,
                  label: 'Telegram',
                  onTap: () => _openUrl('https://t.me/rennxyvxdd'),
                ),
                _buildSocialItem(
                  theme: theme,
                  icon: FontAwesomeIcons.tiktok,
                  bgColor: theme.accentColor,
                  label: 'TikTok',
                  onTap: () => _openUrl('https://tiktok.com/'),
                ),
                _buildSocialItem(
                  theme: theme,
                  icon: FontAwesomeIcons.whatsapp,
                  bgColor: const Color(0xFF25D366),
                  label: 'Whatsapp',
                  onTap: () => _openUrl('https://wa.me/6283875055337'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialItem({
    required ThemeProvider theme,
    required IconData icon,
    required Color bgColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bgColor.withOpacity(0.15),
              border: Border.all(color: bgColor.withOpacity(0.8), width: 2),
              boxShadow: [
                BoxShadow(
                  color: bgColor.withOpacity(0.35),
                  blurRadius: 14,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: FaIcon(icon, color: bgColor, size: 26),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: theme.textSecondaryColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  void _showBuyAksesSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _BuyAksesSheet(
        onBuy: (url) async {
          Navigator.pop(context);
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        },
      ),
    );
  }

  Widget _buildBuyAksesButton(ThemeProvider theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.primaryColor, theme.accentColor],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _showBuyAksesSheet,
            borderRadius: BorderRadius.circular(16),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text(
                  'BUY AKSES',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Orbitron',
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Buy Akses Bottom Sheet ──────────────────
class _BuyAksesSheet extends StatefulWidget {
  final Future<void> Function(String url) onBuy;
  const _BuyAksesSheet({required this.onBuy});

  @override
  State<_BuyAksesSheet> createState() => _BuyAksesSheetState();
}

class _BuyAksesSheetState extends State<_BuyAksesSheet> {
  int _selectedPackage = 0;
  String _selectedRole = 'member';

  final _telegramUrl = 'https://t.me/Renn_XyvXd';

  final Map<String, Map<String, dynamic>> _packages = {
    'member': {
      'label': 'MEMBER',
      'desc': 'Paket member standar',
      'color': const Color(0xFFB06060),
      'plans': [
        {'name': 'Trial Sehari',  'price': 'Rp 3.000',  'icon': Icons.access_time_rounded},
        {'name': 'Trial Sebulan', 'price': 'Rp 10.000', 'icon': Icons.calendar_month_rounded},
        {'name': 'Permanen',      'price': 'Rp 15.000', 'icon': Icons.all_inclusive_rounded},
      ],
    },
    'reseller': {
      'label': 'RESELLER',
      'desc': 'Bisa create akun Member',
      'color': const Color(0xFF22C55E),
      'plans': [
        {'name': 'Permanen', 'price': 'Rp 35.000', 'icon': Icons.all_inclusive_rounded},
      ],
    },
    'vip': {
      'label': 'VIP',
      'desc': 'Get Rat + Sender Global',
      'color': const Color(0xFFE50914),
      'plans': [
        {'name': 'Permanen', 'price': 'Rp 25.000', 'icon': Icons.all_inclusive_rounded},
      ],
    },
    'tk': {
      'label': 'TK',
      'desc': 'Tangan Kanan Apk',
      'color': const Color(0xFFF59E0B),
      'plans': [
        {'name': 'Permanen', 'price': 'Rp 45.000', 'icon': Icons.all_inclusive_rounded},
      ],
    },
    'owner': {
      'label': 'OWNER',
      'desc': 'Bisa create sampai TK',
      'color': const Color(0xFFFF6600),
      'plans': [
        {'name': 'Permanen', 'price': 'Rp 65.000', 'icon': Icons.all_inclusive_rounded},
      ],
    },
    'founder': {
      'label': 'FOUNDER',
      'desc': 'Bisa create sampai Owner',
      'color': const Color(0xFFFF4500),
      'plans': [
        {'name': 'Permanen', 'price': 'Rp 75.000', 'icon': Icons.all_inclusive_rounded},
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    final pkg = _packages[_selectedRole]!;
    final plans = pkg['plans'] as List;
    final color = pkg['color'] as Color;

    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: theme.backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(top: BorderSide(color: theme.primaryColor.withOpacity(0.3))),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.primaryColor.withOpacity(0.4)),
                      ),
                      child: Icon(Icons.shopping_bag_rounded, color: theme.primaryColor, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BUY AKSES',
                          style: TextStyle(
                            color: theme.textPrimaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Orbitron',
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          'Pilih paket yang sesuai',
                          style: TextStyle(color: theme.textSecondaryColor, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: _packages.entries.map((e) {
                    final isSelected = _selectedRole == e.key;
                    final c = e.value['color'] as Color;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _selectedRole = e.key;
                        _selectedPackage = 0;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? c.withOpacity(0.2) : theme.glassPrimary,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? c : theme.primaryColor.withOpacity(0.3),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          e.value['label'] as String,
                          style: TextStyle(
                            color: isSelected ? c : theme.textSecondaryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Orbitron',
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: color.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.workspace_premium_rounded, color: color, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pkg['label'] as String,
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Orbitron',
                                  ),
                                ),
                                Text(
                                  pkg['desc'] as String,
                                  style: TextStyle(color: theme.textSecondaryColor, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...plans.asMap().entries.map((entry) {
                        final i = entry.key;
                        final plan = entry.value as Map;
                        final isSelected = _selectedPackage == i;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedPackage = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? color.withOpacity(0.1)
                                  : theme.glassPrimary,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? color : theme.primaryColor.withOpacity(0.3),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28, height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? color.withOpacity(0.2)
                                        : theme.glassSecondary,
                                    border: Border.all(
                                      color: isSelected ? color : theme.primaryColor.withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? Icon(Icons.check_rounded, color: color, size: 16)
                                      : null,
                                ),
                                const SizedBox(width: 14),
                                Icon(plan['icon'] as IconData, color: isSelected ? color : theme.textSecondaryColor, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  plan['name'] as String,
                                  style: TextStyle(
                                    color: isSelected ? theme.textPrimaryColor : theme.textSecondaryColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Orbitron',
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  plan['price'] as String,
                                  style: TextStyle(
                                    color: isSelected ? color : theme.textSecondaryColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Orbitron',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).padding.bottom + 16),
                child: GestureDetector(
                  onTap: () {
                    final plan = plans[_selectedPackage];
                    final msg = 'Halo, saya mau beli akses ${pkg['label']} - ${plan['name']} (${plan['price']})';
                    final url = 'https://t.me/Renn_XyvXd?text=${Uri.encodeComponent(msg)}';
                    widget.onBuy(url);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 14,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_cart_checkout_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'CONTACT & BUY AKSES',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Orbitron',
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}