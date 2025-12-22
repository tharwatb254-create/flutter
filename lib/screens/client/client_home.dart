
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'technician_list.dart';

class ClientHomeScreen extends StatelessWidget {
  const ClientHomeScreen({super.key});

  final List<Map<String, dynamic>> categories = const [
    {'name': 'كهرباء', 'id': 'Electricity', 'icon': Icons.electric_bolt, 'color': Colors.orange},
    {'name': 'سباكة', 'id': 'Plumbing', 'icon': Icons.water_drop, 'color': Colors.blue},
    {'name': 'نجارة', 'id': 'Carpentry', 'icon': Icons.handyman, 'color': Colors.brown},
    {'name': 'نقاشة', 'id': 'Painting', 'icon': Icons.format_paint, 'color': Colors.purple},
    {'name': 'تكييف', 'id': 'AC', 'icon': Icons.ac_unit, 'color': Colors.cyan},
    {'name': 'تنظيف', 'id': 'Cleaning', 'icon': Icons.cleaning_services, 'color': Colors.teal},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('خدمات صلحني'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'اختار الخدمة اللي محتاجها',
              style: GoogleFonts.cairo(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return _CategoryCard(
                    name: cat['name'],
                    icon: cat['icon'],
                    color: cat['color'],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TechnicianListScreen(
                            categoryName: cat['id'], // Uses strict ID
                            displayTitle: cat['name'],
                          ),
                        ),
                      );
                    },
                  ).animate().scale(delay: (100 * index).ms);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.name,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 40),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
