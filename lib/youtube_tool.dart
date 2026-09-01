// youtube_tool.dart
// YouTube Browser menggunakan WebView dengan tema ungu elegant

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class YouTubeToolPage extends StatefulWidget {
  const YouTubeToolPage({super.key});

  @override
  State<YouTubeToolPage> createState() => _YouTubeToolPageState();
}

class _YouTubeToolPageState extends State<YouTubeToolPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  int _loadingProgress = 0;

  // Warna Dark Purple Elegant (sama dengan dashboard)
  final Color primaryColor = const Color(0xFF4A148C);
  final Color accentColor = const Color(0xFFCE93D8);
  final Color backgroundColor = const Color(0xFF1A0B2E);
  final Color surfaceColor = const Color(0xFF2D1B4E);
  final Color cardColor = const Color(0xFF3D2B5E);
  final Color textPrimary = Colors.white;
  final Color textSecondary = const Color(0xFFE1BEE7);

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(backgroundColor)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 14; Pixel 8) '
        'AppleWebKit/537.36 (KHTML, like Gecko) '
        'Chrome/124.0.0.0 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() { _isLoading = true; _hasError = false; }),
          onProgress: (p) => setState(() => _loadingProgress = p),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (error) {
            if (error.isForMainFrame == true) {
              setState(() { _isLoading = false; _hasError = true; });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse('https://m.youtube.com'));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: _buildAppBar(),
        body: _hasError ? _buildErrorState() : _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: accentColor, size: 20),
        onPressed: () async {
          if (await _controller.canGoBack()) {
            _controller.goBack();
          } else {
            if (mounted) Navigator.pop(context);
          }
        },
      ),
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, accentColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'YouTube',
            style: TextStyle(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh_rounded, color: accentColor),
          onPressed: () => _controller.reload(),
        ),
        IconButton(
          icon: Icon(Icons.home_rounded, color: accentColor),
          onPressed: () => _controller.loadRequest(Uri.parse('https://m.youtube.com')),
        ),
        const SizedBox(width: 4),
      ],
      bottom: _isLoading
          ? PreferredSize(
              preferredSize: const Size.fromHeight(3),
              child: LinearProgressIndicator(
                value: _loadingProgress / 100,
                backgroundColor: surfaceColor,
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                minHeight: 3,
              ),
            )
          : null,
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading && _loadingProgress < 30)
          Container(
            color: backgroundColor,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, accentColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.5),
                          blurRadius: 25,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Memuat YouTube...',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 180,
                    child: LinearProgressIndicator(
                      value: _loadingProgress / 100,
                      backgroundColor: surfaceColor,
                      valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                      borderRadius: BorderRadius.circular(10),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_loadingProgress%',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Loading dots animation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 1500),
                        tween: Tween<double>(begin: 0.3, end: 1.0),
                        builder: (context, double value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: primaryColor.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.2),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: Colors.red,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Gagal Memuat',
              style: TextStyle(
                color: textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Periksa koneksi internet kamu\nlalu coba lagi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () => _controller.reload(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, accentColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 10),
                    Text(
                      'Coba Lagi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
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
}