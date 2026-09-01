// login_page.dart - ORCA ACCESS STYLE (100% SEPERTI FOTO)
// LEFT-ALIGNED LAYOUT

import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:provider/provider.dart';
import 'api_config.dart';
import 'splash.dart';
import 'theme_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with TickerProviderStateMixin {
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePass = true;
  String? _androidId;

  // Animations
  late AnimationController _bgCtrl;
  late AnimationController _entranceCtrl;
  late AnimationController _logoCtrl;
  late AnimationController _btnCtrl;
  late AnimationController _shakeCtrl;

  late Animation<double> _fade;
  late Animation<Offset> _slide;
  late Animation<double> _logoGlow;
  late Animation<double> _btnPulse;
  late Animation<double> _shake;

  @override
  void initState() {
    super.initState();

    _bgCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 18))
      ..repeat();

    _entranceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fade = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _entranceCtrl, curve: Curves.easeOutCubic));

    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
    _logoGlow = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeInOut));

    _btnCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    _btnPulse = Tween<double>(begin: 1.0, end: 1.04)
        .animate(CurvedAnimation(parent: _btnCtrl, curve: Curves.easeInOut));

    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _shake = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -5.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 5.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 5.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));

    _entranceCtrl.forward();
    _initLogin();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _entranceCtrl.dispose();
    _logoCtrl.dispose();
    _btnCtrl.dispose();
    _shakeCtrl.dispose();
    userCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  // ─── Init auto-login ──────────────────────────────────────────────────────
  Future<void> _initLogin() async {
    try {
      final info = await DeviceInfoPlugin().androidInfo
          .timeout(const Duration(seconds: 5));
      _androidId = info.id;
    } catch (_) {
      _androidId = 'unknown';
    }

    final prefs = await SharedPreferences.getInstance();
    final savedUser = prefs.getString('username');
    final savedPass = prefs.getString('password');
    final savedKey = prefs.getString('key');

    if (savedUser != null && savedPass != null && savedKey != null) {
      try {
        final res = await http.get(Uri.parse(
            '$baseUrl/myInfo?username=$savedUser&password=$savedPass&androidId=$_androidId&key=$savedKey'));
        final data = jsonDecode(res.body);

        if (data['valid'] == true && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => SplashScreen(
              username: savedUser,
              password: savedPass,
              role: data['role'],
              sessionKey: data['key'],
              expiredDate: data['expiredDate'],
              listBug: _parseList(data['listBug']),
              listDoos: _parseList(data['listDDoS']),
              news: _parseList(data['news']),
            )),
          );
        }
      } catch (_) {}
    }
  }

  List<Map<String, dynamic>> _parseList(dynamic raw) =>
      (raw as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList();

  // ─── Login ────────────────────────────────────────────────────────────────
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final username = userCtrl.text.trim();
    final password = passCtrl.text.trim();

    setState(() => _isLoading = true);

    try {
      final res = await http.post(Uri.parse('$baseUrl/validate'), body: {
        'username': username,
        'password': password,
        'androidId': _androidId ?? 'unknown',
      });
      final data = jsonDecode(res.body);

      if (data['expired'] == true) {
        _shakeCtrl.forward(from: 0);
        _showAlert(
          title: 'Akses Habis',
          message: 'Masa akses Anda telah berakhir. Silakan perpanjang.',
          type: _AlertType.warning,
          showContact: true,
        );
      } else if (data['valid'] != true) {
        _shakeCtrl.forward(from: 0);
        final msg = (data['message'] ?? '').toString().toLowerCase();
        if (msg.contains('perangkat') || msg.contains('device') ||
            msg.contains('another')) {
          _showAlert(
            title: 'Sesi Aktif',
            message: 'Akun ini sedang login di perangkat lain.',
            type: _AlertType.warning,
          );
        } else {
          _showAlert(
            title: 'Login Gagal',
            message: 'Username atau password salah.',
            type: _AlertType.error,
          );
        }
      } else {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('username', username);
        prefs.setString('password', password);
        prefs.setString('key', data['key']);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => SplashScreen(
              username: username,
              password: password,
              role: data['role'],
              sessionKey: data['key'],
              expiredDate: data['expiredDate'],
              listBug: _parseList(data['listBug']),
              listDoos: _parseList(data['listDDoS']),
              news: _parseList(data['news']),
            )),
          );
        }
      }
    } catch (_) {
      _shakeCtrl.forward(from: 0);
      _showAlert(
        title: 'Koneksi Error',
        message: 'Gagal terhubung ke server. Periksa jaringan Anda.',
        type: _AlertType.error,
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }

  // ─── Alert dialog ─────────────────────────────────────────────────────────
  void _showAlert({
    required String title,
    required String message,
    required _AlertType type,
    bool showContact = false,
  }) {
    final color = switch (type) {
      _AlertType.error => Colors.red,
      _AlertType.warning => Colors.amber,
      _AlertType.success => Colors.green,
    };
    final icon = switch (type) {
      _AlertType.error => Icons.error_rounded,
      _AlertType.warning => Icons.warning_amber_rounded,
      _AlertType.success => Icons.check_circle_rounded,
    };

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 320),
      transitionBuilder: (_, anim, __, child) => ScaleTransition(
        scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
        child: FadeTransition(opacity: anim, child: child),
      ),
      pageBuilder: (ctx, _, __) => Consumer<ThemeProvider>(
        builder: (context, theme, child) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.cardColor, theme.backgroundColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: color.withOpacity(0.3), width: 1.5),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.15), blurRadius: 50),
              ],
            ),
            padding: const EdgeInsets.all(28),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.1),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(height: 18),
              Text(title,
                  style: TextStyle(
                      color: theme.textPrimaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Text(message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: theme.textSecondaryColor,
                      fontSize: 13,
                      height: 1.5)),
              const SizedBox(height: 24),
              if (showContact) ...[
                _GradBtn(
                  label: 'HUBUNGI ADMIN',
                  fullWidth: true,
                  onTap: () async {
                    Navigator.pop(ctx);
                    await launchUrl(Uri.parse('https://t.me/rrvxsz'),
                        mode: LaunchMode.externalApplication);
                  },
                ),
                const SizedBox(height: 12),
              ],
              _OutlineBtn(
                label: showContact ? 'TUTUP' : 'OK',
                fullWidth: true,
                onTap: () => Navigator.pop(ctx),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return Scaffold(
          backgroundColor: theme.backgroundColor,
          body: Stack(
            children: [
              Positioned.fill(
                  child: _AnimatedBg(
                      controller: _bgCtrl,
                      primaryColor: theme.primaryColor,
                      accentColor: theme.accentColor)),
              SafeArea(
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          _buildLogo(theme),
                          const SizedBox(height: 20),
                          _buildHeading(theme),
                          const SizedBox(height: 28),
                          AnimatedBuilder(
                            animation: _shake,
                            builder: (_, child) => Transform.translate(
                              offset: Offset(_shake.value, 0),
                              child: child,
                            ),
                            child: _buildForm(theme),
                          ),
                          const SizedBox(height: 24),
                          _buildFooter(theme),
                          const SizedBox(height: 20),
                        ],
                      ),
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

  // ─── Logo (LEFT-ALIGNED) ────────────────────────────────────────────────
  Widget _buildLogo(ThemeProvider theme) {
    return AnimatedBuilder(
      animation: _logoGlow,
      builder: (_, __) => Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      theme.primaryColor.withOpacity(_logoGlow.value * 0.12),
                      Colors.transparent,
                    ],
                    radius: 0.8,
                  ),
                ),
              ),
              // Outer ring
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(_logoGlow.value * 0.3),
                    width: 1.5,
                  ),
                ),
              ),
              // Mid ring
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor.withOpacity(_logoGlow.value * 0.15),
                      theme.accentColor.withOpacity(_logoGlow.value * 0.1),
                    ],
                  ),
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(_logoGlow.value * 0.4),
                    width: 2,
                  ),
                ),
              ),
              // Core logo
              Hero(
                tag: 'logo',
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [theme.cardColor, theme.backgroundColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: theme.primaryColor.withOpacity(_logoGlow.value * 0.7),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor
                            .withOpacity(_logoGlow.value * 0.35),
                        blurRadius: 25,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset('assets/images/logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.shield_rounded,
                          color: theme.primaryColor,
                          size: 22)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Heading (LEFT-ALIGNED) ──────────────────────────────────────────────
  Widget _buildHeading(ThemeProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ORCA ACCESS Title
        ShaderMask(
          shaderCallback: (b) => LinearGradient(
            colors: [theme.primaryColor, theme.accentColor, theme.primaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(b),
          child: Text(
            'VERSYX ACCESS',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 4,
              fontFamily: 'Orbitron',
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Subtitle
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: theme.glassPrimary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.primaryColor.withOpacity(0.1)),
          ),
          child: Text(
            'secure session gateway',
            style: TextStyle(
              color: theme.textSecondaryColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Enter Authorized Credentials
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.primaryColor.withOpacity(0.08)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                  boxShadow: [
                    BoxShadow(color: Colors.green, blurRadius: 4),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'ENTER AUTHORIZED CREDENTIALS',
                style: TextStyle(
                  color: theme.textSecondaryColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Form (LEFT-ALIGNED) ──────────────────────────────────────────────────
  Widget _buildForm(ThemeProvider theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.cardColor, theme.backgroundColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: theme.primaryColor.withOpacity(0.12), width: 1),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Username
            _LoginField(
              controller: userCtrl,
              label: 'Username',
              hint: 'Enter your username',
              icon: Icons.person_outline_rounded,
              validator: (v) => (v == null || v.isEmpty)
                  ? 'Username tidak boleh kosong'
                  : null,
            ),
            const SizedBox(height: 14),

            // Password
            _LoginField(
              controller: passCtrl,
              label: 'Password',
              hint: 'Enter your password',
              icon: Icons.lock_outline_rounded,
              obscure: _obscurePass,
              onToggleObscure: () =>
                  setState(() => _obscurePass = !_obscurePass),
              validator: (v) => (v == null || v.isEmpty)
                  ? 'Password tidak boleh kosong'
                  : null,
            ),
            const SizedBox(height: 20),

            // Submit Button (LEFT-ALIGNED)
            _LoginButton(
              isLoading: _isLoading,
              pulseAnim: _btnPulse,
              onTap: _login,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Footer (LEFT-ALIGNED) ────────────────────────────────────────────────
  Widget _buildFooter(ThemeProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: theme.glassPrimary,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: theme.primaryColor.withOpacity(0.08), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.security_rounded,
                  color: theme.primaryColor.withOpacity(0.5), size: 12),
              const SizedBox(width: 8),
              Text(
                'Device binding aktif untuk menjaga sesi akun.',
                style: TextStyle(
                  color: theme.textSecondaryColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Belum punya akses? ',
              style: TextStyle(color: theme.textSecondaryColor, fontSize: 12),
            ),
            GestureDetector(
              onTap: () => launchUrl(
                  Uri.parse('https://t.me/Renn_XyvXd'),
                  mode: LaunchMode.externalApplication),
              child: ShaderMask(
                shaderCallback: (b) => LinearGradient(
                  colors: [theme.primaryColor, theme.accentColor],
                ).createShader(b),
                child: const Text(
                  'BUY ACCESS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 3,
              height: 3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.primaryColor,
                boxShadow: [
                  BoxShadow(color: theme.primaryColor, blurRadius: 3),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '© 2026 NEVERSYX LYOCTRA',
              style: TextStyle(
                color: theme.textSecondaryColor.withOpacity(0.4),
                fontSize: 9,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 3,
              height: 3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.accentColor,
                boxShadow: [
                  BoxShadow(color: theme.accentColor, blurRadius: 3),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Login Field ──────────────────────────────────────────────────────────────
class _LoginField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final String? Function(String?)? validator;

  const _LoginField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.onToggleObscure,
    this.validator,
  });

  @override
  State<_LoginField> createState() => _LoginFieldState();
}

class _LoginFieldState extends State<_LoginField> {
  bool _focused = false;
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _focused ? theme.primaryColor : theme.borderColor,
          width: _focused ? 1.5 : 1.0,
        ),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                )
              ]
            : [],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focus,
        obscureText: widget.obscure,
        validator: widget.validator,
        style: TextStyle(
            color: theme.textPrimaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w500),
        cursorColor: theme.primaryColor,
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: TextStyle(
              color: _focused ? theme.primaryColor : theme.textSecondaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w600),
          floatingLabelStyle:
              TextStyle(color: theme.primaryColor, fontSize: 10),
          hintText: widget.hint,
          hintStyle: TextStyle(
              color: theme.textSecondaryColor.withOpacity(0.4), fontSize: 12),
          prefixIcon: Icon(widget.icon,
              color: _focused ? theme.primaryColor : theme.textSecondaryColor,
              size: 18),
          suffixIcon: widget.onToggleObscure != null
              ? IconButton(
                  icon: Icon(
                    widget.obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: _focused
                        ? theme.primaryColor
                        : theme.textSecondaryColor,
                    size: 18,
                  ),
                  onPressed: widget.onToggleObscure,
                )
              : null,
          errorStyle: TextStyle(color: Colors.red, fontSize: 10),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

// ─── Login Button ─────────────────────────────────────────────────────────────
class _LoginButton extends StatefulWidget {
  final bool isLoading;
  final Animation<double> pulseAnim;
  final VoidCallback onTap;

  const _LoginButton({
    required this.isLoading,
    required this.pulseAnim,
    required this.onTap,
  });

  @override
  State<_LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<_LoginButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) {
        setState(() => _down = false);
        if (!widget.isLoading) widget.onTap();
      },
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedBuilder(
        animation: widget.pulseAnim,
        builder: (_, __) => Transform.scale(
          scale: widget.isLoading || _down ? 1.0 : widget.pulseAnim.value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: widget.isLoading
                  ? LinearGradient(
                      colors: [
                        theme.primaryColor.withOpacity(0.5),
                        theme.accentColor.withOpacity(0.5)
                      ],
                    )
                  : LinearGradient(
                      colors: [theme.primaryColor, theme.accentColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: _down || widget.isLoading
                  ? []
                  : [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(
                            widget.pulseAnim.value * 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: widget.isLoading
                    ? const SizedBox(
                        key: ValueKey('loading'),
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : Row(
                        key: const ValueKey('idle'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_forward_rounded,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 12),
                          Text(
                            'SIGN IN →',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                              fontFamily: 'Orbitron',
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Gradient Button ──────────────────────────────────────────────────────────
class _GradBtn extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool fullWidth;

  const _GradBtn(
      {required this.label, required this.onTap, this.fullWidth = false});

  @override
  State<_GradBtn> createState() => _GradBtnState();
}

class _GradBtnState extends State<_GradBtn> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) {
        setState(() => _down = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: 44,
          width: widget.fullWidth ? double.infinity : null,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.primaryColor, theme.accentColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: _down
                ? []
                : [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          child: Center(
            child: Text(widget.label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 0.5)),
          ),
        ),
      ),
    );
  }
}

// ─── Outline Button ───────────────────────────────────────────────────────────
class _OutlineBtn extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool fullWidth;

  const _OutlineBtn(
      {required this.label, required this.onTap, this.fullWidth = false});

  @override
  State<_OutlineBtn> createState() => _OutlineBtnState();
}

class _OutlineBtnState extends State<_OutlineBtn> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) {
        setState(() => _down = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 44,
        width: widget.fullWidth ? double.infinity : null,
        decoration: BoxDecoration(
          color: _down ? theme.borderColor.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.borderColor, width: 1.5),
        ),
        child: Center(
          child: Text(widget.label,
              style: TextStyle(
                  color: theme.textSecondaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 0.5)),
        ),
      ),
    );
  }
}

// ─── Animated Background ──────────────────────────────────────────────────────
class _AnimatedBg extends StatelessWidget {
  final AnimationController controller;
  final Color primaryColor;
  final Color accentColor;

  const _AnimatedBg({
    required this.controller,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) =>
          CustomPaint(painter: _BgPainter(controller.value, primaryColor, accentColor)),
    );
  }
}

class _BgPainter extends CustomPainter {
  final double t;
  final Color primaryColor;
  final Color accentColor;

  _BgPainter(this.t, this.primaryColor, this.accentColor);

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

    // Primary glow
    final glow = Paint()
      ..shader = RadialGradient(colors: [
        primaryColor.withOpacity(0.10 + math.sin(t * math.pi * 2) * 0.03),
        Colors.transparent,
      ], radius: 0.7).createShader(Rect.fromCircle(
          center: Offset(size.width / 2, size.height * 0.35),
          radius: size.width * 0.7));
    canvas.drawCircle(
        Offset(size.width / 2, size.height * 0.35), size.width * 0.7, glow);

    // Accent glow
    final glow2 = Paint()
      ..shader = RadialGradient(colors: [
        accentColor.withOpacity(0.06 + math.cos(t * math.pi * 2) * 0.02),
        Colors.transparent,
      ], radius: 0.5).createShader(Rect.fromCircle(
          center: Offset(size.width * 0.15, size.height * 0.75),
          radius: size.width * 0.4));
    canvas.drawCircle(
        Offset(size.width * 0.15, size.height * 0.75), size.width * 0.4, glow2);
  }

  @override
  bool shouldRepaint(_BgPainter old) =>
      old.t != t || old.primaryColor != primaryColor || old.accentColor != accentColor;
}

enum _AlertType { error, warning, success }