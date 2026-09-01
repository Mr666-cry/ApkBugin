// dashboard_page.dart - VIDEO BACKGROUND + MUTE/UNMUTE
// + GLOW LEBIH TERANG + ONLINE USERS DI BAWAH
// ✅ FIX: BOTTOM NAV LEBIH KE ATAS + BUG MEMBESAR

import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:math' show Random;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';

import 'api_config.dart';
import 'nik_check.dart';
import 'admin_page.dart';
import 'owner_page.dart';
import 'home_page.dart';
import 'seller_page.dart';
import 'creator_page.dart';
import 'developer_page.dart';
import 'change_password_page.dart';
import 'credit_page.dart';
import 'tools_gateway.dart';
import 'tqto_page.dart';
import 'login_page.dart';
import 'bug_sender.dart';
import 'global_chat.dart';
import 'contact_page.dart';
import 'profile_page.dart';
import 'riwayat_page.dart';
import 'info_page.dart';
import 'al_quran.dart';
import 'anime_home.dart';
import 'theme_provider.dart';
import 'collorsetting.dart';
import 'quote_page.dart';
import 'games.dart';
import 'services/online_user_service.dart';

// ─── COLORS ────────────────────────────────────────────────────────────────────
const Color kBg      = Color(0xFF0A0000);
const Color kCard    = Color(0xFF150000);
const Color kCardAlt = Color(0xFF1C0000);
const Color kBorder  = Color(0xFF3B0A0A);
const Color kWhite   = Colors.white;
const Color kWhite70 = Colors.white70;
const Color kWhite54 = Colors.white54;
const Color kWhite24 = Colors.white24;

// ─── GRID PATTERN PAINTER ────────────────────────────────────────────────────
class GridPatternPainter extends CustomPainter {
  final Color color;
  final double spacing;

  GridPatternPainter({this.color = Colors.white, this.spacing = 30.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final paintDiag = Paint()
      ..color = color.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

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

// ─── HEXAGON PATTERN PAINTER ──────────────────────────────────────────────────
class HexagonPatternPainter extends CustomPainter {
  final Color color;
  final double spacing;

  HexagonPatternPainter({this.color = Colors.white, this.spacing = 30.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final double h = spacing;
    final double w = spacing * 0.866;

    for (double row = -1; row < size.height / h + 2; row++) {
      for (double col = -1; col < size.width / w + 2; col++) {
        final double offsetX = (row % 2 == 0) ? 0 : w * 0.5;
        final double cx = col * w + offsetX;
        final double cy = row * h;
        _drawHexagon(canvas, Offset(cx, cy), w * 0.5, paint);
      }
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      double angle = (i * 60 - 30) * 3.14159 / 180;
      double x = center.dx + radius * math.cos(angle);
      double y = center.dy + radius * math.sin(angle);
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Prayer Time Service ───────────────────────────────────────────────────────
class PrayerTimeService {
  static Future<Map<String, dynamic>> fetchPrayerTimes(String city) async {
    final now = DateTime.now();
    final uri = Uri.https('api.aladhan.com', '/v1/timingsByCity', {
      'city': city, 'country': 'ID', 'method': '11',
      'day': '${now.day}', 'month': '${now.month}', 'year': '${now.year}',
    });
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (_) {}
    return {};
  }
}

// ─── Role helpers ─────────────────────────────────────────────────────────────
IconData _roleIcon(String role) {
  switch (role.toLowerCase()) {
    case 'owner':    return Icons.workspace_premium_rounded;
    case 'admin':    return Icons.admin_panel_settings_rounded;
    case 'reseller': return Icons.storefront_rounded;
    case 'vip':      return Icons.star_rounded;
    default:         return Icons.person_rounded;
  }
}

// ─── ANIMATED DOT ──────────────────────────────────────────────────────────────
class _AnimatedDot extends StatefulWidget {
  final Color color;
  final double size;
  const _AnimatedDot({required this.color, this.size = 6});
  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _a = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _a,
    child: Container(
      width: widget.size, height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle, color: widget.color,
        boxShadow: [BoxShadow(color: widget.color.withOpacity(0.6), blurRadius: 6, spreadRadius: 1)],
      ),
    ),
  );
}

// ─── DASHBOARD PAGE ───────────────────────────────────────────────────────────
class DashboardPage extends StatefulWidget {
  final String username;
  final String password;
  final String role;
  final String expiredDate;
  final String sessionKey;
  final List<Map<String, dynamic>> listBug;
  final List<Map<String, dynamic>> listDoos;
  final List<dynamic> news;

  const DashboardPage({
    super.key,
    required this.username,
    required this.password,
    required this.role,
    required this.expiredDate,
    required this.listBug,
    required this.listDoos,
    required this.sessionKey,
    required this.news,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  // ── State ────────────────────────────────────────────────────────────────
  late String sessionKey, username, password, role, expiredDate;
  late List<Map<String, dynamic>> listBug, listDoos;
  late List<dynamic> newsList;

  String androidId = 'unknown';
  File? _profileImage;
  VideoPlayerController? _menuVideoCtrl;

  int _navIndex   = 0;
  int onlineUsers = 99;
  int activeConns = 0;

  // ── Online User Service ──────────────────────────────────────────────────
  final OnlineUserService _onlineService = OnlineUserService();
  int _onlineCount = 0;
  List<String> _onlineUsers = [];

  // ── Video Volume State ──────────────────────────────────────────────────
  bool _isVideoMuted = true;

  // ── Animation controllers ─────────────────────────────────────────────────
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  late AnimationController _bugGlowCtrl;
  late Animation<double> _bugGlowAnim;

  // Online Users polling
  Timer? _statsTimer;

  // News carousel
  late PageController _newsPageCtrl;
  int _newsPageViewKey = 0;
  double _currentNewsPage = 0.0;

  // Quick Actions carousel
  late PageController _qaPageCtrl;
  double _currentQaPage = 0.0;

  // ── Location ──
  bool _locationLoading = false;
  bool _locationGranted = false;

  // ── Prayer times ──
  String _prayerCity = 'Surabaya';
  Map<String, String> _prayerTimes = {};
  String _nextPrayerLabel = '';
  String _nextPrayerTime  = '';
  bool _prayerLoading = true;

  // ── Hadith ──
  Map<String, dynamic>? _hadith;
  bool _hadithLoading = true;
  int _lastHadithNumber = 0;

  @override
  void initState() {
    super.initState();
    sessionKey  = widget.sessionKey;
    username    = widget.username;
    password    = widget.password;
    role        = widget.role;
    expiredDate = widget.expiredDate;
    listBug     = widget.listBug;
    listDoos    = widget.listDoos;
    newsList    = widget.news;

    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _bugGlowCtrl = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _bugGlowAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _bugGlowCtrl, curve: Curves.easeInOut)
    );

    _newsPageCtrl = PageController(viewportFraction: 0.88, initialPage: 0);
    _newsPageCtrl.addListener(() {
      if (mounted) setState(() => _currentNewsPage = _newsPageCtrl.page ?? 0.0);
    });

    _qaPageCtrl = PageController(viewportFraction: 0.88, initialPage: 0);
    _qaPageCtrl.addListener(() {
      if (mounted) setState(() => _currentQaPage = _qaPageCtrl.page ?? 0.0);
    });

    _initAndroidId();
    _loadProfileImage();
    _initMenuVideo();
    _detectLocationAndFetchPrayer(); 
    _fetchRandomHadith();
    
    _onlineService.addListener(_onOnlineUsersUpdated);
    _onlineService.startPolling();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchStats();
      _statsTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        _fetchStats();
      });
    });
  }

  @override
  void dispose() {
    _statsTimer?.cancel();
    _onlineService.removeListener(_onOnlineUsersUpdated);
    _onlineService.dispose();
    _fadeCtrl.dispose();
    _pulseCtrl.dispose();
    _bugGlowCtrl.dispose();
    _menuVideoCtrl?.dispose();
    _newsPageCtrl.dispose();
    _qaPageCtrl.dispose();
    super.dispose();
  }

  // ─── ONLINE USER CALLBACK ────────────────────────────────────────────────
  void _onOnlineUsersUpdated(int count, List<String> users) {
    if (mounted) {
      setState(() {
        _onlineCount = count;
        _onlineUsers = users;
      });
    }
  }

  // ─── FETCH STATS ──────────────────────────────────────────────────────────
  Future<void> _fetchStats() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/stats?key=$sessionKey'),
      ).timeout(const Duration(seconds: 5));
      
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (mounted) {
          setState(() {
            onlineUsers = data['onlineUsers'] ?? 99;
            activeConns = data['activeConnections'] ?? 0;
          });
        }
      }
    } catch (e) {}
  }

  // ── Init helpers ──────────────────────────────────────────────────────────
  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path  = prefs.getString('profile_image_$username');
    if (path != null && path.isNotEmpty && mounted) {
      setState(() => _profileImage = File(path));
    }
  }

  void _initMenuVideo() {
    _menuVideoCtrl = VideoPlayerController.asset('assets/videos/banner.mp4')
      ..initialize().then((_) {
        if (mounted) setState(() {});
        _menuVideoCtrl?.setLooping(true);
        _menuVideoCtrl?.setVolume(0.0);
        _menuVideoCtrl?.play();
      });
  }

  void _toggleBannerVolume() {
    if (_menuVideoCtrl != null && _menuVideoCtrl!.value.isInitialized) {
      setState(() {
        _isVideoMuted = !_isVideoMuted;
        _menuVideoCtrl!.setVolume(_isVideoMuted ? 0.0 : 1.0);
      });
    }
  }

  Future<void> _initAndroidId() async {
    try {
      final info = await DeviceInfoPlugin().androidInfo;
      androidId = info.id;
    } catch (_) {
      androidId = 'unknown';
    }
  }

  Future<void> _openUrl(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  // ─── Fetch Prayer Times ────────────────────────────────────────────────────
  Future<void> _fetchPrayerTimes() async {
    if (!mounted) return;
    setState(() => _prayerLoading = true);
    final data = await PrayerTimeService.fetchPrayerTimes(_prayerCity);
    if (!mounted) return;
    if (data.isNotEmpty) {
      final timings = data['data']?['timings'] ?? {};
      final Map<String, String> times = {
        'Subuh'  : timings['Fajr']    ?? '--:--',
        'Dzuhur' : timings['Dhuhr']   ?? '--:--',
        'Ashar'  : timings['Asr']     ?? '--:--',
        'Maghrib': timings['Maghrib'] ?? '--:--',
        'Isya'   : timings['Isha']    ?? '--:--',
      };
      final now = TimeOfDay.now();
      String nextLabel = 'Isya';
      String nextTime  = times['Isya'] ?? '--:--';
      for (final entry in times.entries) {
        final parts = entry.value.split(':');
        if (parts.length >= 2) {
          final h = int.tryParse(parts[0]) ?? 0;
          final m = int.tryParse(parts[1]) ?? 0;
          if (h > now.hour || (h == now.hour && m > now.minute)) {
            nextLabel = entry.key;
            nextTime  = entry.value;
            break;
          }
        }
      }
      setState(() {
        _prayerTimes     = times;
        _nextPrayerLabel = nextLabel;
        _nextPrayerTime  = nextTime;
        _prayerLoading   = false;
      });
    } else {
      setState(() => _prayerLoading = false);
    }
  }

  // ─── Detect Location ───────────────────────────────────────────────────────
  Future<void> _detectLocationAndFetchPrayer() async {
    if (!mounted) return;
    setState(() => _locationLoading = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _locationLoading = false;
            _prayerCity = 'Surabaya';
          });
          await _fetchPrayerTimes();
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _locationLoading = false;
              _prayerCity = 'Surabaya';
            });
            await _fetchPrayerTimes();
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _locationLoading = false;
            _prayerCity = 'Surabaya';
          });
          await _fetchPrayerTimes();
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks.first;
        final city = place.subAdministrativeArea?.isNotEmpty == true
            ? place.subAdministrativeArea!
            : place.locality?.isNotEmpty == true
                ? place.locality!
                : place.administrativeArea ?? 'Surabaya';

        setState(() {
          _prayerCity     = city;
          _locationGranted = true;
          _locationLoading = false;
        });

        await _fetchPrayerTimes();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(children: [
                const Icon(Icons.location_on_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text('Lokasi terdeteksi: $city'),
              ]),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationLoading = false;
          _prayerCity = 'Surabaya';
        });
        await _fetchPrayerTimes();
      }
    }
  }

  // ─── Fetch Hadith ──────────────────────────────────────────────────────────
  Future<void> _fetchRandomHadith() async {
    if (!mounted) return;
    setState(() => _hadithLoading = true);
    try {
      int randomNumber;
      do {
        randomNumber = Random().nextInt(100) + 1;
      } while (randomNumber == _lastHadithNumber);
      _lastHadithNumber = randomNumber;
      final response = await http
          .get(Uri.parse('https://api.hadith.gading.dev/books/muslim/$randomNumber'))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200 && mounted) {
        setState(() { _hadith = json.decode(response.body); _hadithLoading = false; });
      } else {
        if (mounted) setState(() => _hadithLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _hadithLoading = false);
    }
  }

  // ─── Change City Dialog ────────────────────────────────────────────────────
  void _showChangeCityDialog() {
    final ctrl = TextEditingController(text: _prayerCity);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Ganti Lokasi',
            style: TextStyle(color: kWhite, fontFamily: 'Orbitron', fontSize: 14)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: kWhite),
          decoration: InputDecoration(
            hintText: 'Nama kota (misal: Jakarta)',
            hintStyle: const TextStyle(color: kWhite54),
            filled: true, fillColor: kBg,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            prefixIcon: const Icon(Icons.location_city_rounded, color: Colors.green),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: kWhite54))),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                setState(() {
                  _prayerCity = ctrl.text.trim();
                  _locationGranted = false;
                });
                _fetchPrayerTimes();
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Simpan',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ─── Hadith Full Dialog ────────────────────────────────────────────────────
  void _showHadithFullDialog(String arabic, String indo, String source, String number, String grade) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: kCard, borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(color: Colors.white.withOpacity(0.08), blurRadius: 30, spreadRadius: 2),
              BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 20, offset: const Offset(0, 8)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  color: Colors.white.withOpacity(0.08),
                  border: Border(bottom: BorderSide(color: kBorder.withOpacity(0.5))),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.2)),
                      child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('HADITH LENGKAP',
                            style: TextStyle(color: kWhite, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Orbitron')),
                        Text(grade, style: const TextStyle(color: Colors.white, fontSize: 11)),
                      ]),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: kWhite.withOpacity(0.08)),
                        child: const Icon(Icons.close_rounded, color: kWhite54, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.62),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity, padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: const Color(0xFF1C0000),
                          border: Border.all(color: kBorder.withOpacity(0.3)),
                        ),
                        child: Text(arabic,
                            textAlign: TextAlign.right, textDirection: TextDirection.rtl,
                            style: const TextStyle(color: kWhite, fontSize: 19, height: 2.2)),
                      ),
                      const SizedBox(height: 14),
                      Row(children: [
                        Container(width: 3, height: 18,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: Colors.white)),
                        const SizedBox(width: 8),
                        const Text('ARTINYA:', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      ]),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity, padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: const Color(0xFF150000),
                          border: Border.all(color: kBorder.withOpacity(0.2)),
                        ),
                        child: Text(indo,
                            style: const TextStyle(color: kWhite, fontSize: 14, fontStyle: FontStyle.italic, height: 1.8)),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withOpacity(0.5)),
                          color: Colors.white.withOpacity(0.08),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text('${source.isNotEmpty ? source : "Muslim"} #$number',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleInvalidSession(String message) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('⚠️ Session Expired', style: TextStyle(color: kWhite)),
        content: Text(message, style: const TextStyle(color: kWhite54)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─── Navigation ────────────────────────────────────────────────────────────
  void _onNavTap(int index) {
    setState(() => _navIndex = index);
    if (index == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_newsPageCtrl.hasClients) {
          setState(() { _currentNewsPage = 0.0; _newsPageViewKey++; });
          _newsPageCtrl.jumpToPage(0);
        }
      });
    }
  }

  void _onDrawerNav(int index) {
    Widget page;
    switch (index) {
      case 1: page = SellerPage(keyToken: sessionKey); break;
      case 2: page = AdminPage(sessionKey: sessionKey); break;
      case 3: page = OwnerPage(sessionKey: sessionKey, username: username); break;
      case 4: page = CreatorPage(sessionKey: sessionKey); break;
      case 5: page = DeveloperPage(sessionKey: sessionKey); break;
      default: return;
    }
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page)).then((_) {
      if (mounted) {
        setState(() => _navIndex = 0);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_newsPageCtrl.hasClients) {
            setState(() { _currentNewsPage = 0.0; _newsPageViewKey++; });
            _newsPageCtrl.jumpToPage(0);
          }
        });
      }
    });
  }

  // ── Current Page ──────────────────────────────────────────────────────────
  Widget _buildCurrentPage() {
    switch (_navIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return GlobalChatPage(
          sessionKey: sessionKey,
          username: username,
          role: role,
        );
      case 2:
        return HomePage(
          username: username,
          password: password,
          listBug: listBug,
          role: role,
          expiredDate: expiredDate,
          sessionKey: sessionKey,
        );
      case 3:
        return InfoPage(sessionKey: sessionKey);
      case 4:
        return ToolsPage(
          sessionKey: sessionKey,
          userRole: role,
          listDoos: listDoos,
        );
      default:
        return _buildHomePage();
    }
  }

  // ─── HOME PAGE ─────────────────────────────────────────────────────────────
  Widget _buildHomePage() {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                _buildProfileHeader(theme),
                const SizedBox(height: 14),
                _buildWelcomeCard(theme),
                const SizedBox(height: 14),
                _buildQuickActionsSection(theme),
                const SizedBox(height: 14),
                _buildLatestUpdates(theme),
                const SizedBox(height: 14),
                _buildPrayerSection(theme),
                const SizedBox(height: 14),
                _buildHadithSection(theme),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    username,
                    style: TextStyle(
                      color: kWhite.withOpacity(0.12),
                      fontSize: 13, letterSpacing: 4,
                      fontFamily: 'Orbitron',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── PROFILE HEADER ──────────────────────────────────────────────────────
  Widget _buildProfileHeader(ThemeProvider theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            if (_menuVideoCtrl != null && _menuVideoCtrl!.value.isInitialized)
              SizedBox(
                height: 200,
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _menuVideoCtrl!.value.size.width,
                    height: _menuVideoCtrl!.value.size.height,
                    child: VideoPlayer(_menuVideoCtrl!),
                  ),
                ),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                color: Colors.black,
              ),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: _toggleBannerVolume,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isVideoMuted ? Icons.volume_off : Icons.volume_up,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isVideoMuted ? 'MUTE' : 'UNMUTE',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [theme.primaryColor, theme.accentColor],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.primaryColor.withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: _profileImage != null
                                  ? Image.file(_profileImage!, fit: BoxFit.cover)
                                  : Icon(
                                      FontAwesomeIcons.userAstronaut,
                                      size: 28,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black, width: 2),
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 8,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Orbitron',
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [theme.primaryColor, theme.accentColor],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                role.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStatItem(
                        icon: Icons.link_rounded,
                        value: activeConns.toString(),
                        label: 'Active Connections',
                        color: theme.accentColor,
                      ),
                      _buildDivider(),
                      _buildStatItem(
                        icon: Icons.calendar_month_rounded,
                        value: expiredDate.length > 10 ? expiredDate.substring(0, 10) : expiredDate,
                        label: 'Expiration',
                        color: Colors.amber,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$_onlineCount Online',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Orbitron',
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0.3, end: 1.0),
                          duration: const Duration(milliseconds: 900),
                          builder: (_, double value, __) {
                            return Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(value * 0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Orbitron',
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 30,
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.red, Colors.transparent],
                            ),
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
      ),
    );
  }

  // ─── STAT ITEM ──────────────────────────────────────────────────────────────
  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Orbitron',
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 8,
              fontFamily: 'ShareTechMono',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 24,
      color: Colors.white.withOpacity(0.08),
    );
  }

  // ─── Welcome Card ──────────────────────────────────────────────────────────
  Widget _buildWelcomeCard(ThemeProvider theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.primaryColor.withOpacity(0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.2),
              blurRadius: 24,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                ScaleTransition(
                  scale: _pulseAnim,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [theme.primaryColor, theme.accentColor],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(0.5),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.security_rounded, color: kWhite, size: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome Back,',
                        style: TextStyle(
                          color: kWhite54,
                          fontSize: 11,
                          fontFamily: 'Orbitron',
                        ),
                      ),
                      Text(
                        username,
                        style: TextStyle(
                          color: theme.textPrimaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Orbitron',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.primaryColor.withOpacity(0.5),
                          ),
                          color: theme.primaryColor.withOpacity(0.08),
                        ),
                        child: Text(
                          role.toUpperCase(),
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.primaryColor.withOpacity(0.12),
                    border: Border.all(
                      color: theme.primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Icon(
                    Icons.timer_outlined,
                    color: theme.primaryColor,
                    size: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: theme.primaryColor.withOpacity(0.4),
                ),
                color: theme.primaryColor.withOpacity(0.04),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _AnimatedDot(color: theme.primaryColor, size: 5),
                  const SizedBox(width: 8),
                  Text(
                    'SamsInfinity Dashboard',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Orbitron',
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _AnimatedDot(color: theme.primaryColor, size: 5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── QUICK ACTIONS ──────────────────────────────────────────────────────────
  Widget _buildQuickActionsSection(ThemeProvider theme) {
    final actions = [
      _QuickActionData(
        icon: FontAwesomeIcons.whatsapp,
        bgIcon: FontAwesomeIcons.whatsapp,
        title: 'Manage Sender',
        subtitle: 'Manage your active sender',
        gradient: [theme.primaryColor, theme.accentColor],
        onTap: () => Navigator.push(
          context,
          _slideRoute(BugSenderPage(sessionKey: sessionKey, username: username, role: role)),
        ),
      ),
      _QuickActionData(
        icon: Icons.volunteer_activism,
        bgIcon: Icons.volunteer_activism,
        title: 'TQTO',
        subtitle: 'THANKS TO TEAM',
        gradient: [theme.accentColor, theme.primaryColor],
        onTap: () => Navigator.push(context, _slideRoute(TqtoPage())),
      ),
      _QuickActionData(
        icon: FontAwesomeIcons.telegram,
        bgIcon: FontAwesomeIcons.telegram,
        title: 'Join Channel',
        subtitle: 'Dev Info Channel',
        gradient: [theme.accentColor, theme.primaryColor],
        onTap: () => _openUrl('https://t.me/rennxyvxdd'),
      ),
      _QuickActionData(
        icon: FontAwesomeIcons.bookQuran,
        bgIcon: FontAwesomeIcons.bookQuran,
        title: 'Al Quran',
        subtitle: 'Baca Al-Quran',
        gradient: [theme.primaryColor, Colors.green],
        onTap: () => Navigator.push(context, _slideRoute(AlQuranPage())),
      ),
      _QuickActionData(
        icon: FontAwesomeIcons.tv,
        bgIcon: FontAwesomeIcons.tv,
        title: 'Anime',
        subtitle: 'Discover & Watch Anime',
        gradient: [Colors.orange, theme.primaryColor],
        onTap: () => Navigator.push(context, _slideRoute(HomeAnimePage())),
      ),
      _QuickActionData(
        icon: FontAwesomeIcons.quoteRight,
        bgIcon: FontAwesomeIcons.quoteRight,
        title: 'Quote Hari Ini',
        subtitle: 'Motivasi setiap hari',
        gradient: [Colors.blue, Colors.purple],
        onTap: () => Navigator.push(
          context,
          _slideRoute(const QuotePage()),
        ),
      ),
      _QuickActionData(
        icon: FontAwesomeIcons.gamepad,
        bgIcon: FontAwesomeIcons.gamepad,
        title: '🎮 MINI GAME',
        subtitle: 'Tic Tac Toe, Catur, Slot',
        gradient: [theme.accentColor, theme.primaryColor],
        onTap: () => Navigator.push(
          context,
          _slideRoute(const GamesPage()),
        ),
      ),
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.amber.withOpacity(0.18),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: const Icon(Icons.bolt_rounded, color: Colors.amber, size: 22),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('QUICK ACTIONS',
                      style: TextStyle(
                        color: kWhite, fontWeight: FontWeight.bold, fontSize: 15,
                        fontFamily: 'Orbitron', letterSpacing: 1)),
                  Text('Beberapa Menu Tambahan',
                      style: TextStyle(color: kWhite54, fontSize: 12)),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.amber.withOpacity(0.15),
                  border: Border.all(color: Colors.amber.withOpacity(0.4)),
                ),
                child: Row(children: [
                  Container(
                      width: 7, height: 7,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.amber)),
                  const SizedBox(width: 5),
                  const Text('VerSyx',
                      style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold)),
                ]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _qaPageCtrl,
            itemCount: actions.length,
            onPageChanged: (index) {
              if (mounted) setState(() => _currentQaPage = index.toDouble());
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildQuickActionCard(actions[index], theme),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(actions.length, (index) {
            final bool isActive = _currentQaPage.round() == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: isActive ? Colors.amber : Colors.white24,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(_QuickActionData action, ThemeProvider theme) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
              colors: action.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          boxShadow: [
            BoxShadow(
                color: action.gradient.first.withOpacity(0.4),
                blurRadius: 20, offset: const Offset(0, 8))
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -12, bottom: -12,
              child: Icon(action.bgIcon, color: Colors.white.withOpacity(0.08), size: 110),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white.withOpacity(0.22)),
                    child: Icon(action.icon, color: kWhite, size: 24),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white.withOpacity(0.22)),
                      child: const Text('Tap →',
                          style: TextStyle(color: kWhite, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(action.title,
                      style: const TextStyle(
                        color: kWhite, fontWeight: FontWeight.bold, fontSize: 17, fontFamily: 'Orbitron')),
                  const SizedBox(height: 4),
                  Text(action.subtitle,
                      style: TextStyle(color: kWhite.withOpacity(0.8), fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Latest Updates ────────────────────────────────────────────────────────
  Widget _buildLatestUpdates(ThemeProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              const Icon(Icons.dashboard_customize_rounded, color: Colors.orange, size: 22),
              const SizedBox(width: 8),
              const Text('LATEST UPDATES',
                  style: TextStyle(
                    color: kWhite, fontWeight: FontWeight.bold, fontSize: 15,
                    fontFamily: 'Orbitron', letterSpacing: 1)),
              const Spacer(),
              if (newsList.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.orange.withOpacity(0.15),
                    border: Border.all(color: Colors.orange.withOpacity(0.4)),
                  ),
                  child: Text('${newsList.length} Updates',
                      style: const TextStyle(
                          color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (newsList.isNotEmpty)
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: newsList.length,
              itemBuilder: (ctx, i) => _buildNewsCardHorizontal(newsList[i], theme),
            ),
          ),
        if (newsList.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: kCard,
                  border: Border.all(color: kBorder.withOpacity(0.4))),
              child: const Center(
                  child: Text('No updates available', style: TextStyle(color: kWhite54))),
            ),
          ),
      ],
    );
  }

  Widget _buildNewsCardHorizontal(dynamic item, ThemeProvider theme) {
    final imgUrl   = item['image']?.toString() ?? '';
    final title    = item['title']?.toString() ?? 'No Title';
    final date     = item['date']?.toString() ?? item['created_at']?.toString() ?? '';
    final cardWidth = (MediaQuery.of(context).size.width / 2) - 22;

    return Container(
      width: cardWidth,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: kCard,
        border: Border.all(color: kBorder.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Stack(
              children: [
                Container(
                  height: 100, width: double.infinity, color: kCardAlt,
                  child: imgUrl.isNotEmpty
                      ? Image.network(imgUrl, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.image_not_supported, color: kWhite54, size: 30)))
                      : const Center(
                          child: Icon(Icons.article_rounded, color: kWhite54, size: 30)),
                ),
                Positioned(
                  top: 8, right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black.withOpacity(0.65),
                      border: Border.all(color: Colors.orange.withOpacity(0.7)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle_notifications_rounded, color: Colors.orange, size: 10),
                        SizedBox(width: 3),
                        Text('NEW',
                            style: TextStyle(
                                color: Colors.orange, fontSize: 9, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
            child: Text(title,
                style: const TextStyle(
                  color: kWhite, fontSize: 14, fontWeight: FontWeight.bold,
                  fontFamily: 'Orbitron', height: 1.3),
                maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: Row(
              children: [
                const Icon(Icons.access_time_rounded, color: kWhite54, size: 11),
                const SizedBox(width: 4),
                if (date.isNotEmpty)
                  Expanded(
                    child: Text(
                        date.length > 10 ? date.substring(0, 10) : date,
                        style: const TextStyle(color: kWhite54, fontSize: 10)),
                  ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.orange.withOpacity(0.18)),
                  child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.orange, size: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Prayer Section ────────────────────────────────────────────────────────
  Widget _buildPrayerSection(ThemeProvider theme) {
    final prayerColors = [
      const Color(0xFF5B4FD4),
      const Color(0xFFFF9800),
      const Color(0xFFFF5722),
      const Color(0xFFE50914),
      const Color(0xFF8B0000),
    ];
    final prayerIcons = [
      Icons.nights_stay_rounded,
      Icons.wb_sunny_rounded,
      Icons.cloud_rounded,
      Icons.wb_twilight_rounded,
      Icons.nightlight_round,
    ];
    final prayerKeys = ['Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kBorder.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 18, offset: const Offset(0, 8))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.green.withOpacity(0.2),
                    border: Border.all(color: Colors.green.withOpacity(0.4)),
                  ),
                  child: const Center(child: Icon(Icons.mosque, color: Colors.green, size: 26)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('JADWAL SHOLAT',
                          style: TextStyle(
                            color: kWhite, fontWeight: FontWeight.bold, fontSize: 15,
                            fontFamily: 'Orbitron', letterSpacing: 1)),
                      Text(_prayerCity,
                          style: const TextStyle(color: kWhite54, fontSize: 12)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _locationLoading ? null : _detectLocationAndFetchPrayer,
                  child: Container(
                    width: 38, height: 38,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _locationGranted
                          ? Colors.green.withOpacity(0.2)
                          : kWhite24.withOpacity(0.1),
                      border: Border.all(
                        color: _locationGranted
                            ? Colors.green.withOpacity(0.6)
                            : kWhite54.withOpacity(0.3),
                      ),
                    ),
                    child: _locationLoading
                        ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(color: Colors.green, strokeWidth: 2),
                          )
                        : Icon(
                            _locationGranted
                                ? Icons.my_location_rounded
                                : Icons.location_searching_rounded,
                            color: _locationGranted ? Colors.green : kWhite54,
                            size: 18,
                          ),
                  ),
                ),
                GestureDetector(
                  onTap: _showChangeCityDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.green,
                    ),
                    child: const Row(children: [
                      Icon(Icons.edit_location_alt_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 5),
                      Text('GANTI',
                          style: TextStyle(
                              color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (_nextPrayerLabel.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.green.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    ScaleTransition(
                      scale: _pulseAnim,
                      child: _AnimatedDot(color: Colors.orange, size: 10),
                    ),
                    const SizedBox(width: 10),
                    Text('Menuju $_nextPrayerLabel : $_nextPrayerTime',
                        style: const TextStyle(
                          color: kWhite, fontSize: 13, fontWeight: FontWeight.w600,
                          fontFamily: 'Orbitron')),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.withOpacity(0.5)),
                      ),
                      child: const Text('VerSyx',
                          style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 14),
            if (_prayerLoading)
              const Center(child: CircularProgressIndicator(color: Colors.green, strokeWidth: 2))
            else
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: prayerKeys.length,
                  itemBuilder: (ctx, i) {
                    final key   = prayerKeys[i];
                    final time  = _prayerTimes[key] ?? '--:--';
                    final color = prayerColors[i];
                    final icon  = prayerIcons[i];
                    final isNext = key == _nextPrayerLabel;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                      margin: EdgeInsets.only(right: 10, bottom: isNext ? 0 : 6, top: isNext ? 0 : 6),
                      width: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: color,
                        boxShadow: [
                          BoxShadow(
                              color: color.withOpacity(isNext ? 0.65 : 0.3),
                              blurRadius: isNext ? 18 : 8, offset: const Offset(0, 4))
                        ],
                        border: isNext
                            ? Border.all(color: Colors.white.withOpacity(0.5), width: 1.5)
                            : null,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icon, color: Colors.white, size: 22),
                            const SizedBox(height: 4),
                            Text(key.toUpperCase(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 8,
                                    fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                            const SizedBox(height: 4),
                            Text(time,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16,
                                    fontWeight: FontWeight.bold, fontFamily: 'Orbitron')),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Hadith Section ────────────────────────────────────────────────────────
  Widget _buildHadithSection(ThemeProvider theme) {
    if (_hadithLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            color: kCard, borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kBorder.withOpacity(0.5)),
          ),
          child: const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
        ),
      );
    }

    final arabic = _hadith?['data']?['text']?['ar'] ??
        'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى';
    final indo   = _hadith?['data']?['text']?['id'] ??
        'Sesungguhnya setiap amalan tergantung pada niatnya.';
    final number = _hadith?['data']?['id']?.toString() ?? '1';
    final source = _hadith?['data']?['source']?.toString() ?? 'Muslim';
    final grade  = _hadith?['data']?['grade']?.toString() ?? 'Sahih Muslim';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kCard, borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kBorder.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 18, offset: const Offset(0, 8))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white.withOpacity(0.18)),
                  child: const Center(child: Icon(Icons.menu_book_rounded, color: Colors.white, size: 22)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('HADITH OF THE DAY',
                        style: TextStyle(
                          color: kWhite, fontWeight: FontWeight.bold, fontSize: 13,
                          fontFamily: 'Orbitron', letterSpacing: 0.5)),
                    const SizedBox(height: 2),
                    Text('$grade · Tap card to read full',
                        style: const TextStyle(color: kWhite54, fontSize: 10)),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _showHadithFullDialog(arabic, indo, source, number, grade),
              child: Column(
                children: [
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFF1C0000),
                      border: Border.all(color: kBorder.withOpacity(0.3)),
                    ),
                    child: Text(arabic,
                        textAlign: TextAlign.right, textDirection: TextDirection.rtl,
                        style: const TextStyle(color: kWhite, fontSize: 15, height: 2.0)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12), color: const Color(0xFF150000)),
                    child: Text(indo,
                        style: const TextStyle(
                          color: kWhite54, fontSize: 12, fontStyle: FontStyle.italic, height: 1.6),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.45)),
                    color: Colors.white.withOpacity(0.07),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text('${source.isNotEmpty ? source : "Muslim"} #$number',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ]),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _fetchRandomHadith,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: kWhite54.withOpacity(0.3)),
                    ),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.touch_app_rounded, color: kWhite54, size: 12),
                      SizedBox(width: 4),
                      Text('Tap card', style: TextStyle(color: kWhite54, fontSize: 10)),
                    ]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: false,
          appBar: _buildAppBar(theme),
          drawer: _buildDrawer(theme),
          body: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: GridPatternPainter(
                    color: theme.primaryColor,
                    spacing: 30,
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topLeft,
                      radius: 0.9,
                      colors: [
                        theme.primaryColor.withOpacity(0.50),
                        theme.primaryColor.withOpacity(0.08),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ),
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
              SafeArea(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, anim) =>
                      FadeTransition(opacity: anim, child: child),
                  child: KeyedSubtree(
                    key: ValueKey(_navIndex),
                    child: _buildCurrentPage(),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomNav(theme),
        );
      },
    );
  }

  // ─── AppBar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(ThemeProvider theme) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: kWhite),
      titleSpacing: 0,
      title: Row(
        children: [
          const SizedBox(width: 8),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.primaryColor.withOpacity(0.4),
              ),
              color: theme.primaryColor.withOpacity(0.1),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo.png',
                width: 36,
                height: 36,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            username,
            style: TextStyle(
              color: theme.textPrimaryColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Orbitron',
            ),
          ),
        ],
      ),
      actions: [
        _buildOnlineUsers(theme),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            _slideRoute(ProfilePage(
              username: username,
              password: password,
              role: role,
              expiredDate: expiredDate,
              sessionKey: sessionKey,
            )),
          ),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.primaryColor.withOpacity(0.5),
                width: 2,
              ),
              color: theme.primaryColor.withOpacity(0.2),
            ),
            child: ClipOval(
              child: _profileImage != null
                  ? Image.file(_profileImage!, fit: BoxFit.cover)
                  : Icon(
                      FontAwesomeIcons.userAstronaut,
                      color: theme.primaryColor,
                      size: 16,
                    ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            _slideRoute(const ContactPage()),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.headset_mic_outlined,
              color: theme.textPrimaryColor,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ─── ONLINE USERS WIDGET ──────────────────────────────────────────────────
  Widget _buildOnlineUsers(ThemeProvider theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.glassPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AnimatedDot(color: Colors.green, size: 6),
          const SizedBox(width: 4),
          Text(
            '$_onlineCount',
            style: TextStyle(
              color: theme.textPrimaryColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'Orbitron',
            ),
          ),
          const SizedBox(width: 2),
          Text(
            'Online',
            style: TextStyle(
              color: theme.textSecondaryColor,
              fontSize: 8,
              fontFamily: 'ShareTechMono',
            ),
          ),
        ],
      ),
    );
  }

// ─── BOTTOM NAV ─────────────────────────────────────────────────────────────
// ✅ FIX: MENU LAIN 26px + BUG SETENGAH DI ATAS
Widget _buildBottomNav(ThemeProvider theme) {
  final items = [
    _NavItem(icon: Icons.home_rounded, label: 'HOME'),
    _NavItem(icon: Icons.chat_bubble_rounded, label: 'CHAT'),
    _NavItem(icon: FontAwesomeIcons.whatsapp, label: 'BUG'),
    _NavItem(icon: Icons.info_outline_rounded, label: 'INFO'),
    _NavItem(icon: Icons.build_circle_outlined, label: 'TOOLS'),
  ];

  return Container(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
    height: 110,
    child: Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // ─── BACKGROUND NAV ──────────────────────────────────────────────
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.85),
              borderRadius: BorderRadius.circular(34),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.15),
                  blurRadius: 25,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
        ),
        
        // ─── 5 MENU ITEMS ──────────────────────────────────────────────────
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SizedBox(
            height: 90,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (i) {
                final isActive = _navIndex == i;
                final isCenter = i == 2;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onNavTap(i),
                    child: Transform.translate(
                      offset: Offset(0, isCenter ? -30 : 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isCenter)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              width: 72,
                              height: 72,
                              margin: const EdgeInsets.only(bottom: 2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    theme.primaryColor,
                                    theme.accentColor,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.primaryColor.withOpacity(0.7),
                                    blurRadius: 30,
                                    spreadRadius: 8,
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.4),
                                  width: 3,
                                ),
                              ),
                              child: Icon(
                                items[i].icon,
                                color: Colors.white,
                                size: 34,
                              ),
                            )
                          else
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  items[i].icon,
                                  color: isActive
                                      ? theme.primaryColor
                                      : Colors.white.withOpacity(0.4),
                                  size: 26,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  items[i].label,
                                  style: TextStyle(
                                    color: isActive
                                        ? theme.primaryColor
                                        : Colors.white.withOpacity(0.4),
                                    fontSize: isActive ? 11 : 10,
                                    fontWeight: isActive
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontFamily: isActive ? 'Orbitron' : null,
                                    letterSpacing: isActive ? 0.5 : 0,
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        
        // ─── INDICATOR ACTIVE ────────────────────────────────────────────
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final isActive = _navIndex == i && i != 2;

              return Expanded(
                child: Container(
                  height: 68,
                  alignment: Alignment.topCenter,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isActive ? 30 : 0,
                    height: isActive ? 3 : 0,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(0.6),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ], // ✅ PASTIKAN KURUNG TUTUP INI ADA
    ),
  );
}

  // ─── DRAWER ────────────────────────────────────────────────────────────────
  Widget _buildDrawer(ThemeProvider theme) {
    return Drawer(
      backgroundColor: Colors.black.withOpacity(0.95),
      width: MediaQuery.of(context).size.width * 0.75,
      child: Column(
        children: [
          Container(
            height: 200,
            color: Colors.black,
            child: Stack(
              children: [
                if (_menuVideoCtrl != null && _menuVideoCtrl!.value.isInitialized)
                  SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _menuVideoCtrl!.value.size.width,
                        height: _menuVideoCtrl!.value.size.height,
                        child: VideoPlayer(_menuVideoCtrl!),
                      ),
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.primaryColor.withOpacity(0.6),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.primaryColor.withOpacity(0.3),
                                blurRadius: 12,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: ClipOval(
                            child: _profileImage != null
                                ? Image.file(_profileImage!, fit: BoxFit.cover)
                                : Icon(
                                    FontAwesomeIcons.userAstronaut,
                                    size: 28,
                                    color: theme.primaryColor,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          username,
                          style: TextStyle(
                            color: theme.textPrimaryColor,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Orbitron',
                          ),
                        ),
                        Text(
                          role.toUpperCase(),
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontSize: 10,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            showColorSettingsSheet(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [theme.primaryColor, theme.accentColor],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.primaryColor.withOpacity(0.4),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.palette_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Ganti Warna',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.transparent,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  if (['reseller', 'developer'].contains(role))
                    _buildDrawerItem(
                      icon: Icons.storefront_rounded,
                      label: 'Seller Page',
                      color: theme.primaryColor,
                      onTap: () => _onDrawerNav(1),
                    ),
                  if (['tk', 'developer'].contains(role))
                    _buildDrawerItem(
                      icon: Icons.admin_panel_settings_rounded,
                      label: 'Admin Page',
                      color: theme.accentColor,
                      onTap: () => _onDrawerNav(2),
                    ),
                  if (['owner', 'developer'].contains(role))
                    _buildDrawerItem(
                      icon: Icons.workspace_premium_rounded,
                      label: 'Owner Page',
                      color: theme.primaryColor,
                      onTap: () => _onDrawerNav(3),
                    ),
                  if (['founder', 'developer'].contains(role))
                    _buildDrawerItem(
                      icon: Icons.workspace_premium_rounded,
                      label: 'Creator Page',
                      color: theme.accentColor,
                      onTap: () => _onDrawerNav(4),
                    ),
                  if (['developer'].contains(role))
                    _buildDrawerItem(
                      icon: Icons.code_rounded,
                      label: 'Developer Page',
                      color: theme.primaryColor,
                      onTap: () => _onDrawerNav(5),
                    ),
                  _buildDrawerItem(
                    icon: Icons.chat_rounded,
                    label: 'Global Chat',
                    color: theme.primaryColor,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GlobalChatPage(
                            sessionKey: sessionKey,
                            username: username,
                            role: role,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.history_rounded,
                    label: 'Riwayat Aktivitas',
                    color: theme.accentColor,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        _slideRoute(RiwayatPage(
                          sessionKey: sessionKey,
                          role: role,
                        )),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.favorite_rounded,
                    label: 'TQTO / Credit',
                    color: Colors.pink,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreditPage(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.lock_outline_rounded,
                    label: 'Ganti Password',
                    color: theme.primaryColor,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        _slideRoute(ChangePasswordPage(
                          username: username,
                          sessionKey: sessionKey,
                        )),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildDrawerItem(
                    icon: Icons.logout_rounded,
                    label: 'Keluar',
                    color: Colors.red,
                    isLogout: true,
                    onTap: () async {
                      Navigator.pop(context);
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      if (!mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (_) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isLogout ? Colors.red.withOpacity(0.08) : Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLogout ? Colors.red.withOpacity(0.3) : color.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: isLogout ? Colors.red : color, size: 18),
        title: Text(
          label,
          style: TextStyle(
            color: isLogout ? Colors.red : kWhite,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: isLogout ? Colors.red : color.withOpacity(0.4),
          size: 12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }
}

// ─── Quick Action Data ─────────────────────────────────────────────────────────
class _QuickActionData {
  final IconData icon;
  final IconData bgIcon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;
  const _QuickActionData({
    required this.icon,
    required this.bgIcon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });
}

// ─── Nav Item ─────────────────────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

// ─── Slide Route ──────────────────────────────────────────────────────────────
PageRoute _slideRoute(Widget page) => PageRouteBuilder(
  pageBuilder: (_, __, ___) => page,
  transitionDuration: const Duration(milliseconds: 300),
  transitionsBuilder: (_, anim, __, child) => SlideTransition(
    position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
    child: FadeTransition(opacity: anim, child: child),
  ),
);