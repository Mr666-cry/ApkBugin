// global_chat.dart - FULL THEME PROVIDER SUPPORT
// ALL COLORS DYNAMIC, SMOOTH TRANSITIONS

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'api_config.dart';
import 'theme_provider.dart';

// ─── Role Colors ────────────────────────────
Color _roleColor(String role, ThemeProvider theme) {
  switch (role.toLowerCase()) {
    case 'developer':  return const Color(0xFFFF0000);
    case 'founder':    return const Color(0xFFFF4500);
    case 'owner':      return const Color(0xFFFF6600);
    case 'tk':         return const Color(0xFFF59E0B);
    case 'vip':        return theme.primaryColor;
    case 'reseller':   return Colors.green;
    case 'member':     return theme.textSecondaryColor;
    default:           return theme.textSecondaryColor;
  }
}

// ─── Role Badge ─────────────────────────────
Widget _roleBadge(String role, ThemeProvider theme) {
  final color = _roleColor(role, theme);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withOpacity(0.5)),
    ),
    child: Text(
      role.toUpperCase().replaceAll('_', ' '),
      style: TextStyle(
        color: color,
        fontSize: 9,
        fontWeight: FontWeight.bold,
        fontFamily: 'Orbitron',
        letterSpacing: 0.5,
      ),
    ),
  );
}

// ─── Model ──────────────────────────────────
class _ChatMsg {
  final String id;
  final String username;
  final String role;
  final String message;
  final String time;

  _ChatMsg({
    required this.id,
    required this.username,
    required this.role,
    required this.message,
    required this.time,
  });

  factory _ChatMsg.fromJson(Map<String, dynamic> j) => _ChatMsg(
    id:       j['id']?.toString()       ?? '',
    username: j['username']?.toString() ?? 'Unknown',
    role:     j['role']?.toString()     ?? '',
    message:  j['message']?.toString()  ?? '',
    time:     j['time']?.toString()     ?? '',
  );
}

// ─── Page ───────────────────────────────────
class GlobalChatPage extends StatefulWidget {
  final String sessionKey;
  final String username;
  final String role;

  const GlobalChatPage({
    super.key,
    required this.sessionKey,
    required this.username,
    required this.role,
  });

  @override
  State<GlobalChatPage> createState() => _GlobalChatPageState();
}

class _GlobalChatPageState extends State<GlobalChatPage>
    with TickerProviderStateMixin {

  final _msgCtrl   = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<_ChatMsg> _messages = [];

  bool _sending  = false;
  bool _loading  = true;
  Timer? _pollTimer;

  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _fetchMessages();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _fetchMessages());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Fetch Messages ──────────────────────────
  Future<void> _fetchMessages() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/globalChat?key=${widget.sessionKey}'),
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List rawList = data['messages'] ?? data['chats'] ?? data ?? [];
        final newMsgs = rawList
            .map((e) => _ChatMsg.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        if (mounted) {
          setState(() {
            _messages.clear();
            _messages.addAll(newMsgs);
            _loading = false;
          });
          _scrollToBottom();
        }
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Send Message ────────────────────────────
  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    _msgCtrl.clear();

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/sendChat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'key':     widget.sessionKey,
          'message': text,
        }),
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        await _fetchMessages();
      }
    } catch (_) {
      if (mounted) {
        final theme = Provider.of<ThemeProvider>(context, listen: false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gagal kirim pesan'),
            backgroundColor: theme.primaryColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return Scaffold(
          backgroundColor: theme.backgroundColor,
          appBar: _buildAppBar(theme),
          body: Column(
            children: [
              Expanded(child: _buildChatList(theme)),
              _buildInputBar(theme),
            ],
          ),
        );
      },
    );
  }

  // ── AppBar ──────────────────────────────────
  PreferredSizeWidget _buildAppBar(ThemeProvider theme) {
    return AppBar(
      backgroundColor: theme.cardColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_rounded, color: theme.primaryColor, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) => Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.5 * _pulseCtrl.value),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'VerSyx CHAT',
                style: TextStyle(
                  color: theme.textPrimaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Orbitron',
                  letterSpacing: 2,
                ),
              ),
              Text(
                'Semua user bisa baca & kirim',
                style: TextStyle(color: theme.textSecondaryColor, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: theme.borderColor),
      ),
    );
  }

  // ── Chat List ───────────────────────────────
  Widget _buildChatList(ThemeProvider theme) {
    if (_loading) {
      return Center(
        child: CircularProgressIndicator(color: theme.primaryColor),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.cardColor,
                border: Border.all(color: theme.borderColor),
              ),
              child: Icon(Icons.chat_bubble_outline_rounded, color: theme.textSecondaryColor, size: 30),
            ),
            const SizedBox(height: 16),
            Text('Belum ada pesan', style: TextStyle(color: theme.textSecondaryColor, fontSize: 14)),
            const SizedBox(height: 6),
            Text('Jadilah yang pertama kirim!', style: TextStyle(color: theme.textSecondaryColor.withOpacity(0.5), fontSize: 12)),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final isMe = msg.username == widget.username;
        return _buildMsgBubble(theme, msg, isMe);
      },
    );
  }

  // ── Message Bubble ──────────────────────────
  Widget _buildMsgBubble(ThemeProvider theme, _ChatMsg msg, bool isMe) {
    final roleColor = _roleColor(msg.role, theme);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            // Avatar
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: roleColor.withOpacity(0.2),
                border: Border.all(color: roleColor.withOpacity(0.5)),
              ),
              child: Center(
                child: Text(
                  msg.username.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: roleColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isMe
                      ? [theme.primaryColor.withOpacity(0.3), theme.primaryColor.withOpacity(0.1)]
                      : [theme.cardColor, theme.backgroundColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft:     const Radius.circular(16),
                  topRight:    const Radius.circular(16),
                  bottomLeft:  Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4  : 16),
                ),
                border: Border.all(
                  color: isMe ? theme.primaryColor.withOpacity(0.4) : theme.borderColor,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isMe ? theme.primaryColor.withOpacity(0.15) : Colors.black26,
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          msg.username,
                          style: TextStyle(
                            color: roleColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        _roleBadge(msg.role, theme),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    msg.message,
                    style: TextStyle(color: theme.textPrimaryColor, fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    msg.time,
                    style: TextStyle(color: theme.textSecondaryColor.withOpacity(0.5), fontSize: 10),
                  ),
                ],
              ),
            ),
          ),

          if (isMe) ...[
            const SizedBox(width: 8),
            // Avatar me
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.primaryColor.withOpacity(0.2),
                border: Border.all(color: theme.primaryColor.withOpacity(0.5)),
              ),
              child: Center(
                child: Text(
                  widget.username.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Input Bar ───────────────────────────────
  Widget _buildInputBar(ThemeProvider theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(top: BorderSide(color: theme.borderColor)),
      ),
      child: Row(
        children: [
          // Input Field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.backgroundColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: theme.borderColor),
              ),
              child: TextField(
                controller: _msgCtrl,
                style: TextStyle(color: theme.textPrimaryColor, fontSize: 14),
                maxLines: 3,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Ketik pesan...',
                  hintStyle: TextStyle(color: theme.textSecondaryColor.withOpacity(0.5)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Send Button
          GestureDetector(
            onTap: _sendMessage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 48, height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _sending
                      ? [theme.borderColor, theme.borderColor]
                      : [theme.primaryColor, theme.accentColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: _sending ? [] : [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: _sending
                  ? Padding(
                      padding: const EdgeInsets.all(14),
                      child: CircularProgressIndicator(
                        color: theme.textSecondaryColor,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}