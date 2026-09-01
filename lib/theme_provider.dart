// theme_provider.dart - DENGAN WARNA NEON CYAN, HITAM, EMAS, MERAH, ORANYE
// CYBERPUNK MODERN + GLOW EFFECT

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ====================================================
// MODEL PRESET WARNA
// ====================================================
class ColorPreset {
  final String name;
  final Color primary;
  final Color accent;
  final Color? glow;
  final String icon;

  const ColorPreset({
    required this.name,
    required this.primary,
    required this.accent,
    this.glow,
    this.icon = '🎨',
  });
}

// ====================================================
// THEME PROVIDER
// ====================================================
class ThemeProvider extends ChangeNotifier {
  // ========== DEFAULT COLOR ==========
  static const Color _defaultPrimary = Color(0xFFB026FF);
  static const Color _defaultAccent = Color(0xFFFF2D75);

  Color _primaryColor = _defaultPrimary;
  Color _accentColor = _defaultAccent;
  bool _isDarkMode = true;
  int _currentPresetIndex = 0;

  // ========== GETTERS ==========
  Color get primaryColor => _primaryColor;
  Color get accentColor => _accentColor;
  bool get isDarkMode => _isDarkMode;

  // ========== GETTER UNTUK LOGIN PAGE ==========
  Color get cardColor => _isDarkMode 
      ? const Color(0xFF1A1A2E)   // Dark card
      : const Color(0xFFFFFFFF);   // Light card

  Color get borderColor => _isDarkMode 
      ? const Color(0xFF2A2A3E)   // Dark border
      : const Color(0xFFE0E0E0);   // Light border

  // ========== WARNA UI LAINNYA ==========
  Color get backgroundColor => _isDarkMode 
      ? const Color(0xFF0A0F1A) 
      : const Color(0xFFF5F5F5);
      
  Color get textPrimaryColor => _isDarkMode 
      ? Colors.white 
      : Colors.black87;
      
  Color get textSecondaryColor => _isDarkMode 
      ? Colors.white54 
      : Colors.black54;
      
  Color get glassPrimary => _isDarkMode 
      ? Colors.white.withOpacity(0.05) 
      : Colors.black.withOpacity(0.05);
      
  Color get glassSecondary => _isDarkMode 
      ? Colors.white.withOpacity(0.08) 
      : Colors.black.withOpacity(0.08);

  // ====================================================
  // COLOR PRESETS - LENGKAP!
  // ====================================================
  static const List<ColorPreset> colorPresets = [
    // ─── NEON CYAN (UTAMA) ──────────────────────────────────
    ColorPreset(
      name: 'Neon Purple',
      primary: Color(0xFFB026FF),
      accent: Color(0xFFFF2D75),
      glow: Color(0xFFB026FF),
      icon: '🟣',
    ),
    ColorPreset(
      name: 'Cyan Glow',
      primary: Color(0xFF00F5FF),
      accent: Color(0xFF00B4D8),
      glow: Color(0xFF00F5FF),
      icon: '🔵',
    ),
    ColorPreset(
      name: 'Cyan Dark',
      primary: Color(0xFF0097A7),
      accent: Color(0xFF00BCD4),
      glow: Color(0xFF0097A7),
      icon: '🌊',
    ),
    ColorPreset(
      name: 'Cyan Neon',
      primary: Color(0xFF00E5FF),
      accent: Color(0xFF00B8D4),
      glow: Color(0xFF00E5FF),
      icon: '💎',
    ),

    // ─── HITAM (BLACK) ──────────────────────────────────────
    ColorPreset(
      name: 'Hitam Carbon',
      primary: Color(0xFF1B1B1B),
      accent: Color(0xFF3A3A3A),
      glow: Color(0xFF1B1B1B),
      icon: '⚫',
    ),
    ColorPreset(
      name: 'Hitam Cyber',
      primary: Color(0xFF0A0A0F),
      accent: Color(0xFF1A1A2E),
      glow: Color(0xFF0A0A0F),
      icon: '🌑',
    ),
    ColorPreset(
      name: 'Hitam Premium',
      primary: Color(0xFF121212),
      accent: Color(0xFF1E1E1E),
      glow: Color(0xFF121212),
      icon: '🪨',
    ),

    // ─── EMAS (GOLD) ─────────────────────────────────────────
    ColorPreset(
      name: 'Emas Glow',
      primary: Color(0xFFFFC107),
      accent: Color(0xFFFFA000),
      glow: Color(0xFFFFC107),
      icon: '🌟',
    ),
    ColorPreset(
      name: 'Emas Mewah',
      primary: Color(0xFFFFD700),
      accent: Color(0xFFFF8F00),
      glow: Color(0xFFFFD700),
      icon: '👑',
    ),
    ColorPreset(
      name: 'Emas Neon',
      primary: Color(0xFFFFD740),
      accent: Color(0xFFFFAB00),
      glow: Color(0xFFFFD740),
      icon: '✨',
    ),
    ColorPreset(
      name: 'Emas Premium',
      primary: Color(0xFFF5D100),
      accent: Color(0xFFC9A800),
      glow: Color(0xFFF5D100),
      icon: '🏆',
    ),

    // ─── MERAH (RED) ─────────────────────────────────────────
    ColorPreset(
      name: 'Merah Neon',
      primary: Color(0xFFFF0040),
      accent: Color(0xFFE50914),
      glow: Color(0xFFFF0040),
      icon: '🔴',
    ),
    ColorPreset(
      name: 'Merah Classic',
      primary: Color(0xFFF44336),
      accent: Color(0xFFB71C1C),
      glow: Color(0xFFF44336),
      icon: '❤️',
    ),
    ColorPreset(
      name: 'Merah Glow',
      primary: Color(0xFFFF1744),
      accent: Color(0xFFD50000),
      glow: Color(0xFFFF1744),
      icon: '🔥',
    ),
    ColorPreset(
      name: 'Merah Burgundy',
      primary: Color(0xFF8B0000),
      accent: Color(0xFF5C0000),
      glow: Color(0xFF8B0000),
      icon: '🍷',
    ),
    ColorPreset(
      name: 'Merah Cyber',
      primary: Color(0xFFFF006E),
      accent: Color(0xFFD50000),
      glow: Color(0xFFFF006E),
      icon: '💥',
    ),

    // ─── ORANYE (ORANGE) ─────────────────────────────────────
    ColorPreset(
      name: 'Oranye Neon',
      primary: Color(0xFFFF6D00),
      accent: Color(0xFFFF9100),
      glow: Color(0xFFFF6D00),
      icon: '🟠',
    ),
    ColorPreset(
      name: 'Oranye Classic',
      primary: Color(0xFFFF9800),
      accent: Color(0xFFE65100),
      glow: Color(0xFFFF9800),
      icon: '🍊',
    ),
    ColorPreset(
      name: 'Oranye Glow',
      primary: Color(0xFFFF9100),
      accent: Color(0xFFFF6D00),
      glow: Color(0xFFFF9100),
      icon: '🔥',
    ),
    ColorPreset(
      name: 'Oranye Cyber',
      primary: Color(0xFFFF5722),
      accent: Color(0xFFBF360C),
      glow: Color(0xFFFF5722),
      icon: '🌅',
    ),
    ColorPreset(
      name: 'Oranye Sunset',
      primary: Color(0xFFFFAB00),
      accent: Color(0xFFFF6D00),
      glow: Color(0xFFFFAB00),
      icon: '🌇',
    ),

    // ─── NEON CLASSIC ──────────────────────────────────────
    ColorPreset(
      name: 'Neon Pink',
      primary: Color(0xFFFF2D75),
      accent: Color(0xFFB026FF),
      glow: Color(0xFFFF2D75),
      icon: '🌸',
    ),
    ColorPreset(
      name: 'Neon Cyan',
      primary: Color(0xFF00E5FF),
      accent: Color(0xFFFF1744),
      glow: Color(0xFF00E5FF),
      icon: '💠',
    ),
    ColorPreset(
      name: 'Neon Green',
      primary: Color(0xFF00FF88),
      accent: Color(0xFF00E676),
      glow: Color(0xFF00FF88),
      icon: '🟢',
    ),

    // ─── CYBERPUNK MODERN ──────────────────────────────────
    ColorPreset(
      name: 'Cyberpunk 2077',
      primary: Color(0xFFFF006E),
      accent: Color(0xFF00E5FF),
      glow: Color(0xFFFF006E),
      icon: '🔥',
    ),
    ColorPreset(
      name: 'Cyberpunk Yellow',
      primary: Color(0xFFFFD600),
      accent: Color(0xFFFF006E),
      glow: Color(0xFFFFD600),
      icon: '⭐',
    ),
    ColorPreset(
      name: 'Synthwave',
      primary: Color(0xFFFF00FF),
      accent: Color(0xFF00FFFF),
      glow: Color(0xFFFF00FF),
      icon: '🌊',
    ),
    ColorPreset(
      name: 'Vaporwave',
      primary: Color(0xFFFF6B9D),
      accent: Color(0xFF7F5AF0),
      glow: Color(0xFFFF6B9D),
      icon: '🌴',
    ),
    ColorPreset(
      name: 'Cyber Blue',
      primary: Color(0xFF00B4D8),
      accent: Color(0xFF0077B6),
      glow: Color(0xFF00B4D8),
      icon: '🔵',
    ),
    ColorPreset(
      name: 'Matrix Green',
      primary: Color(0xFF00FF41),
      accent: Color(0xFF003B00),
      glow: Color(0xFF00FF41),
      icon: '💚',
    ),

    // ─── HIJAU GLOW ─────────────────────────────────────────
    ColorPreset(
      name: 'Hijau Glow',
      primary: Color(0xFF22C55E),
      accent: Color(0xFF16A34A),
      glow: Color(0xFF22C55E),
      icon: '🌿',
    ),
    ColorPreset(
      name: 'Hijau Toxic',
      primary: Color(0xFF39FF14),
      accent: Color(0xFF00FF00),
      glow: Color(0xFF39FF14),
      icon: '☢️',
    ),
    ColorPreset(
      name: 'Hijau Mint',
      primary: Color(0xFF2DD4BF),
      accent: Color(0xFF14B8A6),
      glow: Color(0xFF2DD4BF),
      icon: '🌊',
    ),

    // ─── PUTIH ──────────────────────────────────────────────
    ColorPreset(
      name: 'Putih Clean',
      primary: Color(0xFFFFFFFF),
      accent: Color(0xFFE2E8F0),
      glow: Color(0xFFFFFFFF),
      icon: '⚪',
    ),
    ColorPreset(
      name: 'Putih Glass',
      primary: Color(0xFFF1F5F9),
      accent: Color(0xFFCBD5E1),
      glow: Color(0xFFFFFFFF),
      icon: '🥛',
    ),

    // ─── ABU GLOW ───────────────────────────────────────────
    ColorPreset(
      name: 'Abu Glow',
      primary: Color(0xFF94A3B8),
      accent: Color(0xFF64748B),
      glow: Color(0xFF94A3B8),
      icon: '🌫️',
    ),
    ColorPreset(
      name: 'Abu Metalik',
      primary: Color(0xFFA8B5C0),
      accent: Color(0xFF7A8A99),
      glow: Color(0xFFA8B5C0),
      icon: '⚙️',
    ),

    // ─── UNGU NEON MODERN ──────────────────────────────────
    ColorPreset(
      name: 'Ungu Neon',
      primary: Color(0xFF8B5CF6),
      accent: Color(0xFF6D28D9),
      glow: Color(0xFF8B5CF6),
      icon: '🔮',
    ),
    ColorPreset(
      name: 'Ungu Deep',
      primary: Color(0xFF7C3AED),
      accent: Color(0xFF5B21B6),
      glow: Color(0xFF7C3AED),
      icon: '🟪',
    ),
    ColorPreset(
      name: 'Ungu Cyber',
      primary: Color(0xFF9D4EDD),
      accent: Color(0xFF7B2CBF),
      glow: Color(0xFF9D4EDD),
      icon: '🌀',
    ),

    // ─── CYBERPUNK GLOW ────────────────────────────────────
    ColorPreset(
      name: 'Cyber Glow Red',
      primary: Color(0xFFFF0040),
      accent: Color(0xFFFF2D75),
      glow: Color(0xFFFF0040),
      icon: '🔥',
    ),
    ColorPreset(
      name: 'Cyber Glow Blue',
      primary: Color(0xFF00F5FF),
      accent: Color(0xFF00B4D8),
      glow: Color(0xFF00F5FF),
      icon: '💠',
    ),
    ColorPreset(
      name: 'Cyber Glow Purple',
      primary: Color(0xFFB026FF),
      accent: Color(0xFF8B5CF6),
      glow: Color(0xFFB026FF),
      icon: '🔮',
    ),
    ColorPreset(
      name: 'Cyber Glow Pink',
      primary: Color(0xFFFF2D75),
      accent: Color(0xFFFF006E),
      glow: Color(0xFFFF2D75),
      icon: '🌸',
    ),
    ColorPreset(
      name: 'Cyber Glow Green',
      primary: Color(0xFF00FF88),
      accent: Color(0xFF00E676),
      glow: Color(0xFF00FF88),
      icon: '💚',
    ),
  ];

  // ========== CONSTRUCTOR ==========
  ThemeProvider() {
    _loadSavedTheme();
  }

  // ========== LOAD SAVED THEME ==========
  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _currentPresetIndex = prefs.getInt('theme_preset_index') ?? 0;
    _isDarkMode = prefs.getBool('theme_dark_mode') ?? true;
    _applyPresetByIndex(_currentPresetIndex);
    notifyListeners();
  }

  // ========== SAVE THEME ==========
  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_preset_index', _currentPresetIndex);
    await prefs.setBool('theme_dark_mode', _isDarkMode);
  }

  // ========== APPLY PRESET BY OBJECT ==========
  void applyPreset(ColorPreset preset) {
    final index = colorPresets.indexWhere((p) => p.name == preset.name);
    if (index != -1) {
      _applyPresetByIndex(index);
      _saveTheme();
      notifyListeners();
    }
  }

  // ========== APPLY PRESET BY INDEX ==========
  void _applyPresetByIndex(int index) {
    if (index >= 0 && index < colorPresets.length) {
      _currentPresetIndex = index;
      _primaryColor = colorPresets[index].primary;
      _accentColor = colorPresets[index].accent;
    }
  }

  // ========== GET GLOW COLOR ==========
  Color? getGlowColor() {
    if (_currentPresetIndex >= 0 && _currentPresetIndex < colorPresets.length) {
      return colorPresets[_currentPresetIndex].glow;
    }
    return null;
  }

  // ========== CEK APAKAH PRESET AKTIF ==========
  bool isActivePreset(ColorPreset preset) {
    return _primaryColor == preset.primary && _accentColor == preset.accent;
  }

  // ========== RESET KE DEFAULT ==========
  void resetToDefault() {
    _currentPresetIndex = 0;
    _primaryColor = _defaultPrimary;
    _accentColor = _defaultAccent;
    _saveTheme();
    notifyListeners();
  }

  // ========== TOGGLE DARK MODE ==========
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    _saveTheme();
    notifyListeners();
  }

  // ========== SET DARK MODE ==========
  void setDarkMode(bool value) {
    _isDarkMode = value;
    _saveTheme();
    notifyListeners();
  }

  // ========== THEME DATA ==========
  ThemeData get themeData {
    return ThemeData(
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      primaryColor: primaryColor,
      colorScheme: ColorScheme(
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: accentColor,
        onSecondary: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        background: backgroundColor,
        onBackground: textPrimaryColor,
        surface: cardColor,
        onSurface: textPrimaryColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      // ✅ FIX: DialogTheme → DialogThemeData
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundColor,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: textPrimaryColor),
        bodyMedium: TextStyle(color: textSecondaryColor),
        titleLarge: TextStyle(color: textPrimaryColor),
        titleMedium: TextStyle(color: textPrimaryColor),
      ),
    );
  }
}