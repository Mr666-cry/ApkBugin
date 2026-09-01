// quote_page.dart
// DAILY QUOTE & MOTIVASI - TANPA PACKAGE

import 'dart:math';
import 'package:flutter/material.dart';

class QuotePage extends StatefulWidget {
  const QuotePage({super.key});

  @override
  State<QuotePage> createState() => _QuotePageState();
}

class _QuotePageState extends State<QuotePage> {
  final List<Map<String, String>> _quotes = [
    {'text': 'Hidup adalah petualangan yang berani.', 'author': 'Helen Keller'},
    {'text': 'Kesuksesan dimulai dari keinginan yang kuat.', 'author': 'Napoleon Hill'},
    {'text': 'Jangan takut gagal, takutlah untuk tidak mencoba.', 'author': 'Roy T. Bennett'},
    {'text': 'Mimpi besar dimulai dari langkah kecil.', 'author': 'Lao Tzu'},
    {'text': 'Percaya pada diri sendiri adalah kunci utama.', 'author': 'Confucius'},
    {'text': 'Hari ini adalah awal dari sisa hidupmu.', 'author': 'Unknown'},
    {'text': 'Jadilah perubahan yang ingin kamu lihat.', 'author': 'Mahatma Gandhi'},
    {'text': 'Kesempatan tidak datang, kamu yang menciptakannya.', 'author': 'Chris Grosser'},
    {'text': 'Jangan menyerah, akhir yang indah menantimu.', 'author': 'Unknown'},
    {'text': 'Bersyukur adalah kunci kebahagiaan.', 'author': 'Unknown'},
    {'text': 'Kegagalan adalah batu loncatan menuju sukses.', 'author': 'Thomas Edison'},
    {'text': 'Hidup adalah 10% apa yang terjadi dan 90% reaksi.', 'author': 'Charles R. Swindoll'},
    {'text': 'Semangat adalah bahan bakar kesuksesan.', 'author': 'Unknown'},
    {'text': 'Setiap hari adalah kesempatan baru.', 'author': 'Unknown'},
    {'text': 'Kerja keras mengalahkan bakat yang tidak bekerja.', 'author': 'Tim Notke'},
    {'text': 'Kesabaran adalah kunci kemenangan.', 'author': 'Unknown'},
    {'text': 'Jangan bandingkan dirimu dengan orang lain.', 'author': 'Unknown'},
    {'text': 'Mulai dari mana pun, teruslah melangkah.', 'author': 'Unknown'},
    {'text': 'Tujuan tanpa rencana hanyalah angan.', 'author': 'Unknown'},
    {'text': 'Hargai proses, nikmati perjalanan.', 'author': 'Unknown'},
    {'text': 'Hidup terlalu singkat untuk ragu.', 'author': 'Unknown'},
    {'text': 'Bermimpilah setinggi langit.', 'author': 'Unknown'},
    {'text': 'Kebahagiaan ada dalam dirimu sendiri.', 'author': 'Aristotle'},
    {'text': 'Jadilah versi terbaik dari dirimu.', 'author': 'Unknown'},
    {'text': 'Setiap masalah ada solusinya.', 'author': 'Unknown'},
  ];

  late Map<String, String> _currentQuote;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _currentQuote = _quotes[_random.nextInt(_quotes.length)];
  }

  void _generateNewQuote() {
    setState(() {
      _currentQuote = _quotes[_random.nextInt(_quotes.length)];
    });
  }

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
        title: const Text(
          '💬 Quote Hari Ini',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Orbitron',
            letterSpacing: 1,
          ),
        ),
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.format_quote_rounded,
                  color: Colors.blue,
                  size: 40,
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.blueGrey.withOpacity(0.15),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '❝${_currentQuote['text']}❞',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 40,
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '— ${_currentQuote['author']}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.blue.withOpacity(0.7),
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _generateNewQuote,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.purple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Quote Lainnya',
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
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('📋 Quote disalin ke clipboard!'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.blueGrey.withOpacity(0.2),
                        ),
                      ),
                      child: const Icon(
                        Icons.share_rounded,
                        color: Colors.white54,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                '${_quotes.indexOf(_currentQuote) + 1} dari ${_quotes.length}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.15),
                  fontSize: 11,
                  fontFamily: 'Orbitron',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}