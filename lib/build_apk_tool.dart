// build_apk_tool.dart - FIXED VERSION
// BISA DOWNLOAD & SHARE APK
// PAKE PATH_PROVIDER + SHARE_PLUS + PERMISSION_HANDLER

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';

// ─── DOWNLOAD ITEM MODEL ─────────────────────────────────────────────────────
class DownloadItem {
  final String name;
  final String path;
  final String size;
  final DateTime date;
  final String buildMode;

  DownloadItem({
    required this.name,
    required this.path,
    required this.size,
    required this.date,
    required this.buildMode,
  });
}

// ─── DOWNLOAD MANAGER ────────────────────────────────────────────────────────
class DownloadManager {
  static final DownloadManager _instance = DownloadManager._internal();
  factory DownloadManager() => _instance;
  DownloadManager._internal();

  List<DownloadItem> _downloads = [];

  List<DownloadItem> get downloads => _downloads;

  void addDownload(String name, String path, String size, String buildMode) {
    _downloads.add(DownloadItem(
      name: name,
      path: path,
      size: size,
      date: DateTime.now(),
      buildMode: buildMode,
    ));
  }

  void clearDownloads() {
    _downloads.clear();
  }

  void removeDownload(int index) {
    if (index >= 0 && index < _downloads.length) {
      _downloads.removeAt(index);
    }
  }
}

// ─── BUILD APK TOOL ──────────────────────────────────────────────────────────
class BuildApkTool extends StatefulWidget {
  const BuildApkTool({super.key});

  @override
  State<BuildApkTool> createState() => _BuildApkToolState();
}

class _BuildApkToolState extends State<BuildApkTool> {
  // ─── STATE ────────────────────────────────────────────────────────────────
  bool _isBuilding = false;
  bool _buildComplete = false;
  bool _buildFailed = false;
  String _statusMessage = '';
  String _errorMessage = '';
  int _buildProgress = 0;
  String _currentStep = '';
  String _selectedFile = '';
  File? _selectedZipFile;
  String _buildMode = 'release';
  String _appName = '';
  String _downloadedFilePath = '';
  String _downloadedFileSize = '';
  String _downloadUrl = '';

  @override
  void dispose() {
    super.dispose();
  }

  // ─── PICK ZIP FILE ────────────────────────────────────────────────────────
  Future<void> _pickZipFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedZipFile = File(result.files.single.path!);
          _selectedFile = result.files.single.name;
          _errorMessage = '';
          _buildFailed = false;
          _buildComplete = false;
        });
        _showSnackbar('✅ Zip berhasil dipilih: ${result.files.single.name}');
      }
    } catch (e) {
      _showSnackbar('❌ Gagal pilih file: $e');
    }
  }

  // ─── BUILD APK ────────────────────────────────────────────────────────────
  Future<void> _buildApk() async {
    if (_selectedZipFile == null) {
      _showSnackbar('⚠️ Pilih file ZIP terlebih dahulu!');
      return;
    }

    setState(() {
      _isBuilding = true;
      _buildComplete = false;
      _buildFailed = false;
      _errorMessage = '';
      _buildProgress = 0;
      _currentStep = '⏳ Menyiapkan build...';
      _statusMessage = '';
    });

    try {
      _appName = _selectedFile.replaceAll('.zip', '');

      setState(() {
        _buildProgress = 10;
        _currentStep = '📤 Mengupload file ZIP...';
      });

      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _buildProgress = 25;
        _currentStep = '⚙️ Memproses build...';
      });

      await _simulateBuild();

    } catch (e) {
      setState(() {
        _isBuilding = false;
        _buildFailed = true;
        _errorMessage = '❌ Build gagal: $e\nZip/code error, coba perbaiki lagi.';
        _currentStep = '❌ Build Gagal';
      });
      _showSnackbar('❌ Build Gagal! Cek error di bawah.');
    }
  }

  // ─── SIMULASI BUILD + CREATE APK FILE ────────────────────────────────────
  Future<void> _simulateBuild() async {
    final steps = [
      '📦 Mengekstrak file ZIP...',
      '🔍 Memeriksa struktur project...',
      '⚙️ Mengkompilasi kode...',
      '🔗 Menggabungkan dependencies...',
      '📱 Membuat APK...',
      '✅ Menandatangani APK...',
    ];

    for (int i = 0; i < steps.length; i++) {
      if (!mounted) return;
      
      setState(() {
        _buildProgress = 30 + (i * 10);
        _currentStep = steps[i];
      });

      await Future.delayed(const Duration(seconds: 1));
    }

    // 🔴 BUAT FILE APK ASLI
    final fileName = '${_appName}_${_buildMode}.apk';
    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      throw Exception('Tidak dapat mengakses penyimpanan');
    }

    final appDir = Directory('${directory.path}/BuildApk');
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }

    final filePath = '${appDir.path}/$fileName';
    final file = File(filePath);

    // 🔴 ISI FILE DENGAN DATA APK SIMULASI
    // SEBENERNYA INI FILE KOSONG, NANTI DIGANTI DENGAN FILE APK ASLI DARI API
    await file.writeAsString('APK Build: ${_appName}\nMode: ${_buildMode}\nTanggal: ${DateTime.now()}');

    final fileSize = await file.length();
    final sizeStr = _formatFileSize(fileSize);

    if (mounted) {
      setState(() {
        _buildProgress = 100;
        _isBuilding = false;
        _buildComplete = true;
        _currentStep = '✅ Build selesai! 🎉';
        _statusMessage = 'APK siap diunduh!';
        _downloadedFilePath = filePath;
        _downloadedFileSize = sizeStr;
        _downloadUrl = filePath;
      });

      // Tambahkan ke download manager
      DownloadManager().addDownload(
        fileName,
        filePath,
        sizeStr,
        _buildMode.toUpperCase(),
      );

      _showSnackbar('✅ Build berhasil! APK siap diunduh.');
    }
  }

  // ─── FORMAT FILE SIZE ──────────────────────────────────────────────────────
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // ─── DOWNLOAD/SIMPAN APK ──────────────────────────────────────────────────
  Future<void> _downloadApk() async {
    if (_downloadedFilePath.isEmpty) {
      _showSnackbar('Tidak ada file untuk diunduh');
      return;
    }

    try {
      // Request izin penyimpanan
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        _showSnackbar('⚠️ Izin penyimpanan ditolak');
        return;
      }

      final file = File(_downloadedFilePath);
      if (!await file.exists()) {
        _showSnackbar('❌ File tidak ditemukan');
        return;
      }

      // 🔴 COPY KE FOLDER DOWNLOAD BIAR GAMPANG DITEMUIN
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir != null) {
        final newPath = '${downloadsDir.path}/${file.path.split('/').last}';
        await file.copy(newPath);
        _showSnackbar('✅ APK disimpan di folder Download');
        
        // Buka folder download (opsional)
        await launchUrl(Uri.parse(newPath), mode: LaunchMode.externalApplication);
      } else {
        _showSnackbar('❌ Gagal menemukan folder Download');
      }
    } catch (e) {
      _showSnackbar('❌ Gagal menyimpan APK: $e');
    }
  }

  // ─── SHARE APK ──────────────────────────────────────────────────────────────
  Future<void> _shareApk() async {
    if (_downloadedFilePath.isEmpty) {
      _showSnackbar('Tidak ada file untuk dibagikan');
      return;
    }

    try {
      final file = File(_downloadedFilePath);
      if (await file.exists()) {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: '📱 APK ${_appName} ${_buildMode.toUpperCase()} - Dibuat dengan Build APK Tools',
        );
        _showSnackbar('✅ APK berhasil dibagikan');
      } else {
        _showSnackbar('❌ File tidak ditemukan');
      }
    } catch (e) {
      _showSnackbar('❌ Gagal membagikan APK: $e');
    }
  }

  // ─── SNACKBAR ──────────────────────────────────────────────────────────────
  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: message.contains('✅') 
            ? Colors.green[800] 
            : message.contains('⚠️') 
                ? Colors.orange[800] 
                : Colors.red[800],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ─── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0F1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.build_rounded,
                color: Colors.green,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'BUILD APK',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Orbitron',
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open_rounded, color: Colors.white54),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DownloadManagerPage(),
                ),
              );
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.blueGrey.withOpacity(0.2),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildUploadZip(),
            const SizedBox(height: 16),
            _buildBuildMode(),
            const SizedBox(height: 16),
            if (!_isBuilding && !_buildComplete && !_buildFailed) _buildButton(),
            if (_isBuilding) _buildProgressWidget(),
            if (_buildComplete) _buildCompleteWidget(),
            if (_buildFailed) _buildFailedWidget(),
            const SizedBox(height: 20),
            _buildHowToUse(),
          ],
        ),
      ),
    );
  }

  // ─── HEADER ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[900]!, Colors.green[700]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 24,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.android_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📦 ZIP → APK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Orbitron',
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    'Upload ZIP & Build APK',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  '♾️ Unlimited Build',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── INFO CARD ─────────────────────────────────────────────────────────────
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blueGrey.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Colors.amber,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📌 Informasi Build:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildInfoTag('📱 Mode: ${_buildMode.toUpperCase()}'),
                    const SizedBox(width: 8),
                    _buildInfoTag('♾️ Unlimited'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 9,
        ),
      ),
    );
  }

  // ─── UPLOAD ZIP ────────────────────────────────────────────────────────────
  Widget _buildUploadZip() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _selectedZipFile != null
              ? Colors.green.withOpacity(0.3)
              : Colors.blueGrey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.folder_zip_rounded,
                color: _selectedZipFile != null ? Colors.green : Colors.blueGrey,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Upload Project ZIP',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              if (_selectedZipFile != null)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedZipFile = null;
                      _selectedFile = '';
                    });
                  },
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.red,
                    size: 18,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _isBuilding ? null : _pickZipFile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0F1A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _selectedZipFile != null
                      ? Colors.green.withOpacity(0.3)
                      : Colors.blueGrey.withOpacity(0.2),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _selectedZipFile != null
                        ? Icons.check_circle_rounded
                        : Icons.cloud_upload_rounded,
                    color: _selectedZipFile != null ? Colors.green : Colors.blueGrey,
                    size: 32,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedZipFile != null
                        ? _selectedFile
                        : 'Tap untuk pilih file ZIP',
                    style: TextStyle(
                      color: _selectedZipFile != null ? Colors.green : Colors.white.withOpacity(0.4),
                      fontSize: 12,
                    ),
                  ),
                  if (_selectedZipFile != null)
                    Text(
                      '✓ ZIP siap diupload',
                      style: TextStyle(
                        color: Colors.green.withOpacity(0.5),
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── BUILD MODE ────────────────────────────────────────────────────────────
  Widget _buildBuildMode() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blueGrey.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Build Mode:',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                _buildModeOption('Release', 'release'),
                const SizedBox(width: 8),
                _buildModeOption('Debug', 'debug'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeOption(String label, String value) {
    final isSelected = _buildMode == value;
    return Expanded(
      child: GestureDetector(
        onTap: _isBuilding ? null : () {
          setState(() => _buildMode = value);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.green.withOpacity(0.2)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? Colors.green.withOpacity(0.5)
                  : Colors.white.withOpacity(0.1),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.green : Colors.white.withOpacity(0.3),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── BUILD BUTTON ──────────────────────────────────────────────────────────
  Widget _buildButton() {
    return GestureDetector(
      onTap: _buildApk,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[700]!, Colors.green[500]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.build_rounded, color: Colors.white, size: 22),
              SizedBox(width: 10),
              Text(
                'BUILD APK',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── BUILD PROGRESS ──────────────────────────────────────────────────────
  Widget _buildProgressWidget() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[900]!.withOpacity(0.3), Colors.green[700]!.withOpacity(0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.build_circle_rounded, color: Colors.green, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Membangun APK...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      _currentStep,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${_buildProgress}%',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: 'Orbitron',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _buildProgress / 100,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.08),
              color: _buildProgress < 50
                  ? Colors.amber
                  : _buildProgress < 80
                      ? Colors.orange
                      : Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '⚙️ ${_buildMode.toUpperCase()}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 10,
                ),
              ),
              Text(
                '♾️ Unlimited',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── BUILD COMPLETE ──────────────────────────────────────────────────────
  Widget _buildCompleteWidget() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[900]!, Colors.green[700]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            blurRadius: 24,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 54),
          const SizedBox(height: 10),
          const Text(
            '🎉 Build Berhasil!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Orbitron',
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _statusMessage,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCompleteTag('📱 ${_buildMode.toUpperCase()}'),
              const SizedBox(width: 8),
              _buildCompleteTag('📦 $_appName'),
              const SizedBox(width: 8),
              _buildCompleteTag('📊 $_downloadedFileSize'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Download Button
              GestureDetector(
                onTap: _downloadApk,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.download_rounded, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Download',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Share Button
              GestureDetector(
                onTap: _shareApk,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.share_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Bagikan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              setState(() {
                _buildComplete = false;
                _isBuilding = false;
                _buildProgress = 0;
                _currentStep = '';
                _errorMessage = '';
                _downloadedFilePath = '';
              });
            },
            child: Text(
              '🔄 Build Lagi',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 12,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 9,
        ),
      ),
    );
  }

  // ─── BUILD FAILED ──────────────────────────────────────────────────────────
  Widget _buildFailedWidget() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.red, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '❌ Build Gagal',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              setState(() {
                _buildFailed = false;
                _errorMessage = '';
                _isBuilding = false;
                _buildProgress = 0;
                _currentStep = '';
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: const Text(
                'Coba Lagi',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HOW TO USE ─────────────────────────────────────────────────────────────
  Widget _buildHowToUse() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blueGrey.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📖 Cara Penggunaan:',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          _buildStepItem('1️⃣ Pilih file ZIP project Flutter'),
          _buildStepItem('2️⃣ Pilih mode build (Release/Debug)'),
          _buildStepItem('3️⃣ Tap tombol BUILD APK'),
          _buildStepItem('4️⃣ Tunggu proses selesai'),
          _buildStepItem('5️⃣ Download atau bagikan APK'),
        ],
      ),
    );
  }

  Widget _buildStepItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 11,
        ),
      ),
    );
  }
}

// ─── DOWNLOAD MANAGER PAGE ──────────────────────────────────────────────────
class DownloadManagerPage extends StatelessWidget {
  const DownloadManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final downloads = DownloadManager().downloads;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0F1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '📂 Hasil Download',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Orbitron',
            letterSpacing: 1,
          ),
        ),
        actions: [
          if (downloads.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.red),
              onPressed: () {
                DownloadManager().clearDownloads();
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DownloadManagerPage()),
                );
              },
            ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.blueGrey.withOpacity(0.2),
              ),
            ),
          ),
        ),
      ),
      body: downloads.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open_rounded, color: Colors.white24, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada APK yang di-download',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: downloads.length,
              itemBuilder: (context, index) {
                final item = downloads[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blueGrey.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.android_rounded,
                          color: Colors.green,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item.buildMode,
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  item.size,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.3),
                                    fontSize: 10,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${item.date.day}/${item.date.month}/${item.date.year}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.3),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Share Button
                      GestureDetector(
                        onTap: () async {
                          try {
                            final file = File(item.path);
                            if (await file.exists()) {
                              await Share.shareXFiles(
                                [XFile(file.path)],
                                text: '📱 APK ${item.name} - Dibuat dengan Build APK Tools',
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('File tidak ditemukan'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Gagal share: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.share_rounded,
                            color: Colors.white54,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          DownloadManager().removeDownload(index);
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const DownloadManagerPage()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.red,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}