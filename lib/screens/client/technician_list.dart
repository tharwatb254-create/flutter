
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/database_service.dart';
import '../../models/models.dart';
import 'location_picker.dart';

class TechnicianListScreen extends StatelessWidget {
  final String categoryName;
  final String displayTitle;

  const TechnicianListScreen({
    super.key,
    required this.categoryName,
    required this.displayTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('صنايعية $displayTitle'),
      ),
      body: StreamBuilder<List<TechnicianModel>>(
        stream: Provider.of<DatabaseService>(context, listen: false)
            .streamTechniciansByCategory(categoryName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('حصل خطأ: ${snapshot.error}'));
          }

          final technicians = snapshot.data ?? [];

          if (technicians.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('للأسف مفيش صنايعية في القسم ده حالياً',
                      style: GoogleFonts.cairo(fontSize: 18)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: technicians.length,
            itemBuilder: (context, index) {
              return _TechnicianCard(tech: technicians[index])
                  .animate()
                  .slideY(begin: 0.1, delay: (100 * index).ms);
            },
          );
        },
      ),
    );
  }
}

class _TechnicianCard extends StatelessWidget {
  final TechnicianModel tech;

  const _TechnicianCard({required this.tech});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(tech.imageUrl),
                  backgroundColor: Colors.grey[200],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tech.name,
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.orange, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${tech.rating} (${tech.reviewCount} تقييم)',
                            style: GoogleFonts.cairo(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      Text(
                        '${tech.pricePerHour} ج.م / ساعة',
                        style: GoogleFonts.cairo(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: tech.availableSlots.map((slot) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: ActionChip(
                      label: Text(slot),
                      onPressed: () {
                        _showBookingConfirmation(context, slot);
                      },
                      avatar: const Icon(Icons.access_time, size: 16),
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.05),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingConfirmation(BuildContext context, String slot) async {
    // First, pick location
    final locationData = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => const LocationPickerScreen(),
      ),
    );

    if (!context.mounted || locationData == null) return;

    // Show confirmation dialog
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            Text(
              'تأكيد الحجز',
              style: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'حجز موعد مع ${tech.name} الساعة $slot',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      locationData['address'] ?? 'موقع محدد',
                      style: GoogleFonts.cairo(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Provider.of<DatabaseService>(context, listen: false)
                          .createRequest(
                        tech,
                        slot,
                        latitude: locationData['latitude'],
                        longitude: locationData['longitude'],
                        address: locationData['address'],
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم إرسال الطلب بنجاح!')),
                      );
                    },
                    child: const Text('تأكيد'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
