import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'api_config.dart';

class SellerPage extends StatefulWidget {
  final String keyToken;

  const SellerPage({super.key, required this.keyToken});

  @override
  State<SellerPage> createState() => _SellerPageState();
}

class _SellerPageState extends State<SellerPage> {
  List<dynamic> fullUserList = [];
  List<dynamic> filteredList = [];

  final List<String> roleOptions = ['member', 'vip'];
  String selectedRole = 'member';

  int currentPage = 1;
  int itemsPerPage = 25;

  final createUsernameController = TextEditingController();
  final createPasswordController = TextEditingController();

  // ✅ DURASI OPTIONS
  final List<Map<String, dynamic>> durationOptions = [
    {'label': '1 Hari', 'value': '1'},
    {'label': '3 Hari', 'value': '3'},
    {'label': '7 Hari', 'value': '7'},
    {'label': '1 Bulan', 'value': '30'},
    {'label': 'Permanent', 'value': '9999999'},
  ];
  String selectedDuration = '7'; // Default 7 Hari

  final editUsernameController = TextEditingController();

  // ✅ EDIT DURASI OPTIONS
  String selectedEditDuration = '7'; // Default 7 Hari

  bool isLoading = false;

  // --- TEMA WARNA MERAH ---
  final Color bgDark = const Color(0xFF0A0000);
  final Color primaryCyan = const Color(0xFFE50914);
  final Color accentCyan = const Color(0xFFFF4040);
  final Color primaryWhite = Colors.white;
  final Color cardGlass = Colors.white.withOpacity(0.05);
  final Color borderGlass = Colors.white.withOpacity(0.1);

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/listUsers?key=${widget.keyToken}'),
      );
      final data = jsonDecode(res.body);
      if (data['valid'] == true && data['authorized'] == true) {
        fullUserList = data['users'] ?? [];
        _filterAndPaginate();
      } else {
        _alert("Info", data['message'] ?? 'Gagal memuat user.');
      }
    } catch (_) {
      _alert("Error", "Gagal terhubung ke server.");
    }
    setState(() => isLoading = false);
  }

  void _filterAndPaginate() {
    setState(() {
      currentPage = 1;
      filteredList = fullUserList
          .where((u) => u['role'] == selectedRole)
          .toList();
    });
  }

  List<dynamic> _getCurrentPageData() {
    final start = (currentPage - 1) * itemsPerPage;
    final end = (start + itemsPerPage);
    return filteredList.sublist(
      start,
      end > filteredList.length ? filteredList.length : end,
    );
  }

  int get totalPages => (filteredList.length / itemsPerPage).ceil();

  Future<void> _createAccount() async {
    final u = createUsernameController.text.trim();
    final p = createPasswordController.text.trim();
    final d = selectedDuration; // ✅ AMBIL DARI DROPDOWN

    if (u.isEmpty || p.isEmpty) {
      _alert("Peringatan", "Username dan Password wajib diisi.");
      return;
    }

    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse(
          "$baseUrl/createAccount?key=${widget.keyToken}&newUser=$u&pass=$p&day=$d"));
      final data = jsonDecode(res.body);

      if (data['created'] == true) {
        _alert("Sukses", "✅ Akun berhasil dibuat!");
        createUsernameController.clear();
        createPasswordController.clear();
        setState(() {
          selectedDuration = '7'; // Reset ke default
        });
        _fetchUsers();
      } else {
        String msg = data['message'] ?? 'Gagal membuat akun.';
        if (data['invalidDay'] == true) {
          msg += " (Max 30 hari untuk Reseller)";
        }
        _alert("Gagal", "❌ $msg");
      }
    } catch (e) {
      _alert("Error", "❌ Koneksi error: $e");
    }
    setState(() => isLoading = false);
  }

  Future<void> _editUser() async {
    final u = editUsernameController.text.trim();
    final d = selectedEditDuration; // ✅ AMBIL DARI DROPDOWN

    if (u.isEmpty) {
      _alert("Peringatan", "Username wajib diisi.");
      return;
    }

    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse(
          "$baseUrl/editUser?key=${widget.keyToken}&username=$u&addDays=$d"));
      final data = jsonDecode(res.body);

      if (data['edited'] == true) {
        _alert("Sukses", "✅ Durasi berhasil diperbarui.");
        editUsernameController.clear();
        setState(() {
          selectedEditDuration = '7'; // Reset ke default
        });
        _fetchUsers();
      } else {
        _alert("Gagal", "❌ ${data['message'] ?? 'Gagal mengubah durasi.'}");
      }
    } catch (e) {
      _alert("Error", "❌ Koneksi error: $e");
    }
    setState(() => isLoading = false);
  }

  void _alert(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: bgDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: accentCyan.withOpacity(0.3)),
        ),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: accentCyan),
            const SizedBox(width: 10),
            Text(title, style: TextStyle(color: primaryWhite)),
          ],
        ),
        content: Text(message, style: TextStyle(color: Colors.white70)),
        actions: [
          Center(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [primaryCyan, accentCyan]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK", style: TextStyle(color: primaryWhite, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType type = TextInputType.text,
    String hint = "",
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: type,
        style: TextStyle(color: primaryWhite),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white38),
          labelStyle: TextStyle(color: accentCyan),
          prefixIcon: Icon(icon, color: accentCyan),
          filled: true,
          fillColor: cardGlass,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderGlass),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: borderGlass),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accentCyan, width: 2),
          ),
        ),
      ),
    );
  }

  // ✅ DROPDOWN DURASI
  Widget _buildDurationDropdown({
    required String value,
    required ValueChanged<String> onChanged,
    String? label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Container(
        decoration: BoxDecoration(
          color: cardGlass,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderGlass),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 2),
                child: Text(
                  label,
                  style: TextStyle(
                    color: accentCyan,
                    fontSize: 13,
                  ),
                ),
              ),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                dropdownColor: bgDark,
                icon: const Icon(Icons.expand_more, color: Colors.white54, size: 20),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                items: durationOptions.map((opt) {
                  return DropdownMenuItem<String>(
                    value: opt['value'],
                    child: Row(
                      children: [
                        // ✅ PAKAI TEXT "∞" UNTUK PERMANENT
                        if (opt['value'] == '0')
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              '∞',
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else
                          Icon(
                            Icons.calendar_today_rounded,
                            color: accentCyan,
                            size: 16,
                          ),
                        const SizedBox(width: 10),
                        Text(
                          opt['label'],
                          style: TextStyle(
                            color: opt['value'] == '0' 
                                ? Colors.amber 
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    onChanged(value);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 25),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardGlass,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderGlass),
        boxShadow: [
          BoxShadow(
            color: primaryCyan.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryCyan.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accentCyan),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: primaryWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Orbitron',
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildUserItem(Map user) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardGlass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGlass),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryCyan.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, color: accentCyan),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['username'],
                  style: TextStyle(color: primaryWhite, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  "ROLE: ${user['role'].toString().toUpperCase()} | EXP: ${user['expiredDate']}",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(totalPages, (index) {
        final page = index + 1;
        return ElevatedButton(
          onPressed: () => setState(() => currentPage = page),
          style: ElevatedButton.styleFrom(
            backgroundColor: currentPage == page ? accentCyan : Colors.transparent,
            foregroundColor: currentPage == page ? primaryWhite : Colors.white54,
            padding: EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: borderGlass),
            ),
          ),
          child: Text("$page", style: TextStyle(fontSize: 12)),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgDark, primaryCyan.withOpacity(0.1), bgDark],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.storefront, color: accentCyan, size: 50),
                SizedBox(height: 10),
                Text(
                  "SELLER DASHBOARD",
                  style: TextStyle(
                    color: primaryWhite,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Orbitron',
                    letterSpacing: 2,
                    shadows: [Shadow(color: primaryCyan.withOpacity(0.8), blurRadius: 10)],
                  ),
                ),
                SizedBox(height: 40),

                _buildGlassCard(
                  title: "CREATE MEMBER",
                  icon: FontAwesomeIcons.userPlus,
                  children: [
                    _buildInput(
                      label: "Username Baru",
                      controller: createUsernameController,
                      icon: FontAwesomeIcons.user,
                    ),
                    _buildInput(
                      label: "Password",
                      controller: createPasswordController,
                      icon: FontAwesomeIcons.lock,
                    ),
                    // ✅ DROPDOWN DURASI (GANTI TEXTFIELD)
                    _buildDurationDropdown(
                      value: selectedDuration,
                      label: "Durasi",
                      onChanged: (value) {
                        setState(() {
                          selectedDuration = value;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [primaryCyan, accentCyan]),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: primaryCyan.withOpacity(0.4), blurRadius: 10, offset: Offset(0, 4))
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _createAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isLoading
                            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: primaryWhite))
                            : Text("CREATE ACCOUNT", style: TextStyle(color: primaryWhite, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),

                _buildGlassCard(
                  title: "EXTEND DURATION",
                  icon: FontAwesomeIcons.clock,
                  children: [
                    _buildInput(
                      label: "Username Target",
                      controller: editUsernameController,
                      icon: FontAwesomeIcons.userEdit,
                      hint: "Username member yang ingin diperpanjang",
                    ),
                    // ✅ DROPDOWN DURASI UNTUK EDIT (GANTI TEXTFIELD)
                    _buildDurationDropdown(
                      value: selectedEditDuration,
                      label: "Tambah Durasi",
                      onChanged: (value) {
                        setState(() {
                          selectedEditDuration = value;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [primaryCyan, accentCyan]),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: primaryCyan.withOpacity(0.4), blurRadius: 10, offset: Offset(0, 4))
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _editUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isLoading
                            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: primaryWhite))
                            : Text("ADD DAYS", style: TextStyle(color: primaryWhite, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),

                _buildGlassCard(
                  title: "MEMBER LIST",
                  icon: FontAwesomeIcons.users,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderGlass),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedRole,
                          dropdownColor: bgDark,
                          style: TextStyle(color: primaryWhite),
                          items: roleOptions.map((role) {
                            return DropdownMenuItem(value: role, child: Text(role.toUpperCase()));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              selectedRole = val;
                              _filterAndPaginate();
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    isLoading
                        ? Center(child: CircularProgressIndicator(color: accentCyan))
                        : Column(
                      children: [
                        ..._getCurrentPageData().map((u) => _buildUserItem(u)).toList(),
                        SizedBox(height: 20),
                        _buildPagination(),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}