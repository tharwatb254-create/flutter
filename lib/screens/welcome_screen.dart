
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_screen.dart';
import '../models/models.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Icon(
                Icons.handyman_rounded,
                size: 80,
                color: Colors.white,
              ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 20),
              Text(
                'Sal7ny',
                style: GoogleFonts.cairo(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3, end: 0),
              Text(
                'صلحني - خدمات صيانة احترافية',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ).animate().fadeIn(delay: 500.ms),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    Text(
                      'أنت مين؟',
                      style: GoogleFonts.cairo(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _RoleCard(
                      title: 'عميل',
                      subtitle: 'عايز حد يصلح حاجة',
                      icon: Icons.person,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AuthScreen(role: UserRole.client)),
                        );
                      },
                    ).animate().slideX(begin: -1, duration: 500.ms),
                    const SizedBox(height: 16),
                    _RoleCard(
                      title: 'صنايعي',
                      subtitle: 'عايز تقدم خدماتك',
                      icon: Icons.engineering,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AuthScreen(role: UserRole.technician)),
                        );
                      },
                    ).animate().slideX(begin: 1, duration: 500.ms),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Theme.of(context).primaryColor, size: 32),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
