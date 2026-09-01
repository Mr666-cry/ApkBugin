// credit_page.dart - TQTO / CREDIT PAGE

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CreditPage extends StatelessWidget {
  const CreditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF150000),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'TQTO / CREDIT',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildCreditCard(
              icon: Icons.code_rounded,
              title: 'Developer Utama',
              name: 'SamuDev',
              subtitle: 'Developer SamInfinity',
              color: const Color(0xFFE50914),
            ),
            const SizedBox(height: 16),
            _buildCreditCard(
              icon: Icons.code_rounded,
              title: 'Second Dev',
              name: 'Venn',
              subtitle: 'Babu Samsinfinity',
              color: const Color(0xFFFF4040),
            ),
            const SizedBox(height: 16),
            _buildCreditCard(
              icon: Icons.code_rounded,
              title: 'Friend & Support',
              name: 'Yuda',
              subtitle: 'Owner',
              color: const Color(0xFFFF4040),
            ),
            const SizedBox(height: 16),
            _buildCreditCard(
              icon: Icons.code_rounded,
              title: 'Friend',
              name: 'Kalz',
              subtitle: 'Owner',
              color: const Color(0xFFB01010),
            ),
            const SizedBox(height: 16),
            _buildCreditCard(
              icon: Icons.code_rounded,
              title: 'Friend',
              name: 'Zam',
              subtitle: 'Tangan Kanan',
              color: const Color(0xFFFF6D00),
            ),
            const SizedBox(height: 16),
            _buildCreditCard(
              icon: Icons.code_rounded,
              title: 'Friend',
              name: 'Rafzz',
              subtitle: 'Tangan Kanan',
              color: const Color(0xFF22C55E),
            ),
            const SizedBox(height: 16),
            _buildCreditCard(
              icon: Icons.code_rounded,
              title: 'Friend',
              name: 'Vinxie',
              subtitle: 'Tangan Kanan',
              color: const Color(0xFF22C55E),
            ),
            const SizedBox(height: 16),
            _buildCreditCard(
              icon: Icons.support_agent_rounded,
              title: 'Support',
              name: 'VerSyx Lyctra Team',
              subtitle: 'Support For Apk',
              color: const Color(0xFFFF4040),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE50914), Color(0xFF8B0000)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE50914).withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'THANK YOU TO ALL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'For Supporting SamuDev',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: IconButton(
                          icon: const FaIcon(FontAwesomeIcons.telegram, size: 18),
                          color: Colors.white,
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: IconButton(
                          icon: const FaIcon(FontAwesomeIcons.whatsapp, size: 18),
                          color: Colors.white,
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: IconButton(
                          icon: const FaIcon(FontAwesomeIcons.github, size: 18),
                          color: Colors.white,
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '© 2026 VerSyxxc - All Rights Reserved',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      letterSpacing: 1,
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

  Widget _buildCreditCard({
    required IconData icon,
    required String title,
    required String name,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF150000),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              'TQTO',
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}