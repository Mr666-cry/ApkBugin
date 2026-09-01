// splash.dart - HOLOW EXECUTION STYLE + THEME PROVIDER
// ✅ FIXED: GREEN SCREEN ERROR + RETRY MECHANISM
// ✅ ADDED: MAINTENANCE PAGE INTEGRATION

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dashboard_page.dart';
import 'theme_provider.dart';
import 'maintenance_page.dart';  // 🔥 TAMBAHKAN
import 'api_config.dart';            // 🔥 TAMBAHKAN

class SplashScreen extends StatefulWidget {
  final String username;
  final String password;
  final String role;
  final String expiredDate;
  final String sessionKey;
  final List<Map<String, dynamic>> listBug;
  final List<Map<String, dynamic>> listDoos;
  final List<dynamic> news;

  const SplashScreen({
    super.key,
    required this.username,
    required this.password,
    required this.role,
    required this.expiredDate,
    required this.sessionKey,
    required this.listBug,
    required this.listDoos,
    required this.news,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  VideoPlayerController? _videoCtrl;
  bool _videoReady = false;
  bool _isNavigating = false;
  bool _videoError = false;
  int _retryCount = 0;
  bool _isRetrying = false;
  bool _isCheckingMaintenance = false;

  // Animations
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    
    // 🔥 CEK MAINTENANCE DULU SEBELUM VIDEO
    _checkMaintenance();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🔥 MAINTENANCE CHECK - FIRST
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Future<void> _checkMaintenance() async {
    if (_isCheckingMaintenance) return;
    _isCheckingMaintenance = true;

    try {
      final response = await http.get(
  Uri.parse('$baseUrl/api/app-status'),
);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final isMaintenance = data['maintenance'] == true;

        if (isMaintenance) {
          // 🔥 TAMPILKAN MAINTENANCE PAGE
          _isNavigating = true;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => MaintenancePage(
                message: data['message'] ?? 'Aplikasi sedang dalam pemeliharaan.',
                version: data['version'] ?? '2.0.0',
                downloadUrl: data['downloadUrl'] ?? '',
                onRetry: () {
                  // Cek ulang maintenance
                  _isNavigating = false;
                  _checkMaintenance();
                },
              ),
            ),
          );
          return;
        }
      }

      // Jika tidak maintenance, lanjut ke video
      _isCheckingMaintenance = false;
      _initVideoWithRetry();

    } catch (e) {
      // Jika gagal cek maintenance, lanjutkan ke video
      debugPrint('⚠️ Maintenance check failed: $e');
      _isCheckingMaintenance = false;
      _initVideoWithRetry();
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // VIDEO INIT WITH RETRY
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  void _initVideoWithRetry() {
    if (_isRetrying) return;
    _isRetrying = true;

    // Dispose controller lama jika ada
    _videoCtrl?.removeListener(_onVideoProgress);
    _videoCtrl?.dispose();

    try {
      _videoCtrl = VideoPlayerController.asset('assets/videos/splash.mp4')
        ..initialize().then((_) {
          if (!mounted) return;
          
          setState(() {
            _videoReady = true;
            _videoError = false;
            _isRetrying = false;
          });

          _videoCtrl!.setLooping(false);
          _videoCtrl!.setVolume(1.0);
          _videoCtrl!.play();

          _videoCtrl!.addListener(_onVideoProgress);

          // Fallback timer - navigasi maksimal 8 detik
          Future.delayed(const Duration(seconds: 8), () {
            if (mounted && !_isNavigating) {
              if (_videoCtrl != null && !_videoCtrl!.value.isPlaying) {
                debugPrint('⏰ Fallback: Force navigate after 8 seconds');
                _navigateToDashboard();
              }
            }
          });

        }).catchError((error) {
          debugPrint('❌ Video Init Error: $error');
          _handleVideoError();
        });
    } catch (e) {
      debugPrint('❌ Video Exception: $e');
      _handleVideoError();
    }
  }

  void _handleVideoError() {
    if (_retryCount < 3) {
      _retryCount++;
      debugPrint('🔄 Retry video attempt $_retryCount/3');
      
      setState(() {
        _videoReady = false;
        _videoError = true;
        _isRetrying = false;
      });

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && !_isNavigating) {
          _initVideoWithRetry();
        }
      });
    } else {
      debugPrint('❌ All retry failed, navigating directly');
      setState(() {
        _videoError = true;
        _videoReady = false;
        _isRetrying = false;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_isNavigating) _navigateToDashboard();
      });
    }
  }

  void _onVideoProgress() {
    if (!mounted || _isNavigating || _videoCtrl == null) return;

    try {
      final value = _videoCtrl!.value;
      
      if (value.hasError) {
        debugPrint('⚠️ Video playback error detected');
        _handleVideoError();
        return;
      }

      final position = value.position;
      final duration = value.duration;
      
      if (duration != Duration.zero && position >= duration) {
        _navigateToDashboard();
      }
    } catch (e) {
      debugPrint('⚠️ Listener error: $e');
    }
  }

  void _navigateToDashboard() {
    if (_isNavigating || !mounted) return;
    _isNavigating = true;
    
    // Cleanup video controller
    _videoCtrl?.removeListener(_onVideoProgress);
    _videoCtrl?.dispose();
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => DashboardPage(
          username: widget.username,
          password: widget.password,
          role: widget.role,
          expiredDate: widget.expiredDate,
          sessionKey: widget.sessionKey,
          listBug: widget.listBug,
          listDoos: widget.listDoos,
          news: widget.news,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _videoCtrl?.removeListener(_onVideoProgress);
    _videoCtrl?.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // BUILD
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return Scaffold(
          backgroundColor: theme.backgroundColor,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // ─── Video Background ──────────────────────────────────────────
              if (_videoReady && _videoCtrl != null && !_videoError)
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoCtrl!.value.size.width,
                    height: _videoCtrl!.value.size.height,
                    child: VideoPlayer(_videoCtrl!),
                  ),
                )
              else if (_videoError || !_videoReady)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF0A0E27),
                        const Color(0xFF1A1A4E),
                        const Color(0xFF0D111A),
                      ],
                    ),
                  ),
                  child: _isRetrying || _isCheckingMaintenance
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: Color(0xFFFF0040),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Loading...',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      : null,
                ),

              // ─── Overlay ──────────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.backgroundColor.withOpacity(0.4),
                      theme.backgroundColor.withOpacity(0.6),
                    ],
                  ),
                ),
              ),

              // ─── Glow Effect ──────────────────────────────────────────────
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (_, __) => Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.5,
                        colors: [
                          theme.primaryColor.withOpacity(0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ─── Content ───────────────────────────────────────────────────
              SafeArea(
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // ─── Main Text ────────────────────────────────────────────
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          // ─── Title ──────────────────────────────────────────
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [theme.primaryColor, theme.accentColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: Text(
                              'NeverSyx Lyoctra',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                fontFamily: 'Orbitron',
                                letterSpacing: 8,
                                shadows: [
                                  Shadow(
                                    color: theme.primaryColor.withOpacity(0.3),
                                    blurRadius: 30,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ─── Subtitle ──────────────────────────────────────
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: theme.primaryColor.withOpacity(0.2),
                                  width: 1.5,
                                ),
                                right: BorderSide(
                                  color: theme.primaryColor.withOpacity(0.2),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            child: Text(
                              'Kegagalan Adalah Batu Loncatan Menuju Kesuksesan.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: theme.textPrimaryColor.withOpacity(0.8),
                                fontFamily: 'ShareTechMono',
                                letterSpacing: 1.5,
                                height: 1.4,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ─── Powered By ────────────────────────────────────
                          Text(
                            'Powered by @Ren_XyvXd And @VenTamvan',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.textSecondaryColor.withOpacity(0.5),
                              fontFamily: 'ShareTechMono',
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 3),

                    // ─── SKIP BUTTON ──────────────────────────────────────────
                    GestureDetector(
                      onTap: _navigateToDashboard,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 36,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.primaryColor.withOpacity(0.15),
                              theme.accentColor.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: theme.primaryColor.withOpacity(0.35),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.primaryColor.withOpacity(0.15),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.skip_next_rounded,
                              color: theme.primaryColor.withOpacity(0.8),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'SKIP / LEWATI',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: theme.textPrimaryColor.withOpacity(0.9),
                                fontFamily: 'Orbitron',
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ─── INDICATOR ──────────────────────────────────────────
                    if (_videoError && _retryCount < 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          'Memuat video... (Percobaan $_retryCount/3)',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.textSecondaryColor.withOpacity(0.5),
                            fontFamily: 'ShareTechMono',
                          ),
                        ),
                      ),
                    
                    // ─── MAINTENANCE CHECK INDICATOR ────────────────────────
                    if (_isCheckingMaintenance)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          'Memeriksa status aplikasi...',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.textSecondaryColor.withOpacity(0.5),
                            fontFamily: 'ShareTechMono',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}