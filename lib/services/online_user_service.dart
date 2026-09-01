// lib/services/online_user_service.dart
// SIMPLE ONLINE USER SERVICE - POLLING

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_config.dart';

class OnlineUserService {
  static final OnlineUserService _instance = OnlineUserService._internal();
  factory OnlineUserService() => _instance;
  OnlineUserService._internal();

  Timer? _timer;
  int _onlineCount = 0;
  List<String> _onlineUsers = [];
  bool _isLoading = false;
  
  // Listener untuk update UI
  final List<Function(int, List<String>)> _listeners = [];

  // ─── REGISTER LISTENER ──────────────────────────────────────────────────
  void addListener(Function(int, List<String>) listener) {
    _listeners.add(listener);
  }

  // ─── REMOVE LISTENER ───────────────────────────────────────────────────
  void removeListener(Function(int, List<String>) listener) {
    _listeners.remove(listener);
  }

  // ─── NOTIFY ALL LISTENERS ─────────────────────────────────────────────
  void _notifyListeners() {
    for (var listener in _listeners) {
      listener(_onlineCount, _onlineUsers);
    }
  }

  // ─── GETTERS ────────────────────────────────────────────────────────────
  int get onlineCount => _onlineCount;
  List<String> get onlineUsers => _onlineUsers;

  // ─── START POLLING ──────────────────────────────────────────────────────
  void startPolling() {
    _stopPolling();
    _fetchOnlineUsers(); // Fetch pertama langsung
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      _fetchOnlineUsers();
    });
  }

  // ─── STOP POLLING ──────────────────────────────────────────────────────
  void _stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  // ─── FETCH ONLINE USERS ────────────────────────────────────────────────
  Future<void> _fetchOnlineUsers() async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionKey = prefs.getString('key') ?? '';

      final response = await http.get(
        Uri.parse('$baseUrl/getOnlineUsers?key=$sessionKey'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['valid'] == true) {
          _onlineCount = data['online'] ?? 0;
          _onlineUsers = List<String>.from(data['users'] ?? []);
          _notifyListeners();
        }
      }
    } catch (e) {
      // Silent error - biar ga crash
    } finally {
      _isLoading = false;
    }
  }

  // ─── DISPOSE ────────────────────────────────────────────────────────────
  void dispose() {
    _stopPolling();
    _listeners.clear();
  }
}