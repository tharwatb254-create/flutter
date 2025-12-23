import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../data/database_service.dart';
import '../models/models.dart';
import 'welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUploading = false;

  Future<void> _pickAndUploadImage(DatabaseService dbService) async {
    if (_isUploading) return;
    
    setState(() => _isUploading = true);
    
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      if (image == null) {
        setState(() => _isUploading = false);
        return;
      }

      await dbService.uploadProfileImage(File(image.path));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث الصورة بنجاح')),
        );
      }
    } catch (e) {
      debugPrint('Upload UI Error: $e');
      if (mounted) {
        String message = 'فشل الرفع';
        if (e.toString().contains('Bucket not found')) {
          message = 'خطأ: لم يتم العثور على Bucket "profile-images" في Supabase';
        } else if (e.toString().contains('row violates row-level security policy')) {
          message = 'خطأ: سياسات الأمان (RLS) في Supabase تمنع الرفع. تأكد من إضافة Policy تسمح بالـ INSERT';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dbService = Provider.of<DatabaseService>(context);
    final user = dbService.currentUser;

    debugPrint('ProfileScreen Build - User: ${user?.id}, Role: ${user?.role}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('حسابي'),
        centerTitle: true,
        elevation: 0,
      ),
      body: user == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'جاري التحميل...',
                    style: GoogleFonts.cairo(),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header Section with Gradient
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.7),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        // Profile Picture
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: _isUploading ? null : () => _pickAndUploadImage(dbService),
                            customBorder: const CircleBorder(),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.white,
                              backgroundImage: user.profileImage != null && user.profileImage!.isNotEmpty
                                  ? NetworkImage(user.profileImage!)
                                  : null,
                              child: _isUploading
                                  ? const CircularProgressIndicator()
                                  : (user.profileImage == null || user.profileImage!.isEmpty
                                      ? Icon(
                                          user.role == UserRole.technician
                                              ? Icons.engineering
                                              : Icons.person,
                                          size: 60,
                                          color: Theme.of(context).primaryColor,
                                        )
                                      : null),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Name
                        Text(
                          user.name ?? 'مستخدم',
                          style: GoogleFonts.cairo(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Email
                        Text(
                          user.email,
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Role Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            user.role == UserRole.technician
                                ? '🔧 فني'
                                : '👤 عميل',
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Technician Info (if user is technician)
                  if (user.role == UserRole.technician)
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('technicians')
                          .doc(user.id)
                          .get(),
                      builder: (context, snapshot) {
                        // Loading state
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        // Error state
                        if (snapshot.hasError) {
                          debugPrint('Error loading technician data: ${snapshot.error}');
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  'خطأ في تحميل البيانات',
                                  style: GoogleFonts.cairo(color: Colors.red),
                                ),
                              ),
                            ),
                          );
                        }

                        // No data state
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          debugPrint('No technician data found for user: ${user.id}');
                          return const SizedBox.shrink();
                        }

                        // Data loaded successfully
                        final techData = snapshot.data!.data() as Map<String, dynamic>;
                        final specialty = techData['specialty'] ?? '';
                        final slots = List<String>.from(techData['availableSlots'] ?? []);

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.work,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'معلومات الفني',
                                        style: GoogleFonts.cairo(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24),
                                  _buildInfoRow('الصنعة:', _translateSpecialty(specialty)),
                                  const SizedBox(height: 12),
                                  _buildInfoRow('السعر:', '50 جنيه/ساعة'),
                                  const SizedBox(height: 12),
                                  Text(
                                    'الأوقات المتاحة:',
                                    style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: slots.map((slot) {
                                      return Chip(
                                        label: Text(
                                          slot,
                                          style: GoogleFonts.cairo(fontSize: 12),
                                        ),
                                        backgroundColor: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.1),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 16),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _buildActionTile(
                          context,
                          icon: Icons.edit,
                          title: 'تعديل الملف الشخصي',
                          color: Colors.blue,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('قريباً')),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildActionTile(
                          context,
                          icon: Icons.lock,
                          title: 'تغيير كلمة المرور',
                          color: Colors.orange,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('قريباً')),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildActionTile(
                          context,
                          icon: Icons.help_outline,
                          title: 'المساعدة والدعم',
                          color: Colors.green,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('قريباً')),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildActionTile(
                          context,
                          icon: Icons.info_outline,
                          title: 'عن التطبيق',
                          color: Colors.purple,
                          onTap: () {
                            _showAboutDialog(context);
                          },
                        ),
                        const SizedBox(height: 24),
                        // Logout Button - Full Width
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _showLogoutDialog(context, dbService);
                            },
                            icon: const Icon(Icons.logout),
                            label: Text(
                              'تسجيل خروج',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.grey[900],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, DatabaseService dbService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'تسجيل خروج',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل أنت متأكد من تسجيل الخروج؟',
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            onPressed: () {
              dbService.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('تسجيل خروج', style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'عن التطبيق',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تطبيق صلحني',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'الإصدار 1.0.0',
              style: GoogleFonts.cairo(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              'تطبيق لربط العملاء بأفضل الفنيين في جميع المجالات',
              style: GoogleFonts.cairo(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('حسناً', style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );
  }

  String _translateSpecialty(String en) {
    switch (en) {
      case 'Electricity':
        return 'كهرباء';
      case 'Plumbing':
        return 'سباكة';
      case 'Carpentry':
        return 'نجارة';
      case 'Painting':
        return 'نقاشة';
      case 'AC':
        return 'تكييف';
      case 'Cleaning':
        return 'تنظيف';
      default:
        return en;
    }
  }
}
