// tqto_page.dart - FULL THEME PROVIDER SUPPORT
// ALL COLORS DYNAMIC, SMOOTH TRANSITIONS

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class TqtoPage extends StatefulWidget {
  const TqtoPage({super.key});

  @override
  State<TqtoPage> createState() => _TqtoPageState();
}

class _TqtoPageState extends State<TqtoPage> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _floatController;

  final List<Map<String, dynamic>> tqtoList = [
    {
      'username': 'SamuDev',
      'fullname': 'SamuDev',
      'role': 'Developer Utama SamInfinity',
      'bio': 'Master of backend architecture & system security',
      'icon': FontAwesomeIcons.code,
    },
    {
      'username': 'VenTamvan',
      'fullname': 'VennEks',
      'role': 'Second Dev & Murid',
      'bio': 'Second Dev SamsInfinity',
      'icon': FontAwesomeIcons.palette,
    },
  ];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowController.repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.2, end: 0.6).animate(_glowController);
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _floatController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _openTelegram(String username) async {
    final Uri url = Uri.parse('https://t.me/$username');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        return Scaffold(
          backgroundColor: theme.backgroundColor,
          body: Stack(
            children: <Widget>[
              _buildBackgroundGradient(theme),
              _buildNeonParticles(theme),
              SafeArea(
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverAppBar(
                      floating: true,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      centerTitle: true,
                      title: Text(
                        "CREATORS & CONTRIBUTORS",
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 14,
                          color: theme.textSecondaryColor,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      leading: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.glassPrimary,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.borderColor.withOpacity(0.3)),
                          ),
                          child: Icon(Icons.arrow_back_rounded, color: theme.textPrimaryColor, size: 20),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: <Widget>[
                            _buildHeaderCard(theme),
                            const SizedBox(height: 24),
                            _buildHeroBanner(theme),
                            const SizedBox(height: 24),
                            _buildTqtoGrid(theme),
                            const SizedBox(height: 32),
                            _buildFooter(theme),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackgroundGradient(ThemeProvider theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            theme.backgroundColor,
            theme.cardColor,
            theme.backgroundColor.withOpacity(0.8),
          ],
        ),
      ),
    );
  }

  Widget _buildNeonParticles(ThemeProvider theme) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (BuildContext context, Widget? child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 0.8,
                colors: <Color>[
                  theme.primaryColor.withOpacity(0.08 * _glowAnimation.value),
                  Colors.transparent,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(ThemeProvider theme) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (BuildContext context, Widget? child) {
        return Transform.translate(
          offset: Offset(0, 4 * (_floatController.value - 0.5)),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  theme.glassPrimary,
                  theme.glassSecondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: theme.borderColor.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.15),
                  blurRadius: 30,
                  spreadRadius: 5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: <Widget>[
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[theme.primaryColor, theme.accentColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    FontAwesomeIcons.peopleGroup,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [theme.primaryColor, theme.accentColor],
                  ).createShader(bounds),
                  child: Text(
                    "THANKS TO",
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "ELITE TEAM BEHIND VERSYX LYOCTRA",
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 11,
                    color: theme.textSecondaryColor,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 60,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[theme.primaryColor, Colors.transparent],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroBanner(ThemeProvider theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            theme.primaryColor.withOpacity(0.12),
            theme.primaryColor.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.borderColor.withOpacity(0.3)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
            ),
            child: Icon(FontAwesomeIcons.bullhorn, color: theme.primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "COLLABORATIVE EFFORT",
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 12,
                    color: theme.primaryColor,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "VERSYXX was built through dedication and collective expertise of these amazing individuals",
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textSecondaryColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTqtoGrid(ThemeProvider theme) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.85,
      ),
      itemCount: tqtoList.length,
      itemBuilder: (BuildContext context, int index) {
        final Map<String, dynamic> person = tqtoList[index];
        return _buildTqtoCard(theme, person);
      },
    );
  }

  Widget _buildTqtoCard(ThemeProvider theme, Map<String, dynamic> person) {
    return GestureDetector(
      onTap: () {
        _openTelegram(person['username'] as String);
      },
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (BuildContext context, Widget? child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  theme.glassPrimary,
                  theme.glassSecondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.borderColor.withOpacity(0.3 + (0.15 * _glowAnimation.value)),
                width: 1.2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        theme.primaryColor.withOpacity(0.2),
                        theme.primaryColor.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
                  ),
                  child: Icon(
                    person['icon'] as IconData,
                    color: theme.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "@${person['username']}",
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 13,
                    color: theme.textPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  person['role'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.textSecondaryColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    person['bio'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.textSecondaryColor.withOpacity(0.7),
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(FontAwesomeIcons.telegram, size: 10, color: theme.primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        "CONTACT",
                        style: TextStyle(
                          fontSize: 8,
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFooter(ThemeProvider theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            theme.primaryColor.withOpacity(0.08),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.borderColor.withOpacity(0.2)),
      ),
      child: Column(
        children: <Widget>[
          Icon(FontAwesomeIcons.codePullRequest, color: theme.textSecondaryColor, size: 28),
          const SizedBox(height: 12),
          Text(
            "BUILT WITH DEDICATION",
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 11,
              color: theme.textSecondaryColor,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "NeverSyx Lyoctra V4",
            style: TextStyle(
              fontFamily: 'ShareTechMono',
              fontSize: 10,
              color: theme.textSecondaryColor.withOpacity(0.7),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 1,
            color: theme.borderColor.withOpacity(0.4),
          ),
        ],
      ),
    );
  }
}