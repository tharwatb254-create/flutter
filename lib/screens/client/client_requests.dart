import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/database_service.dart';
import '../../models/models.dart';

class ClientRequestsScreen extends StatelessWidget {
  const ClientRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure requests are fetched
    // In a real app with streams, this might be handled differently, 
    // but here we rely on the provider having the data or fetching it on init.
    final requests = Provider.of<DatabaseService>(context).requests;

    return Scaffold(
      appBar: AppBar(title: const Text('طلباتي')),
      body: requests.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'لسه مفيش طلبات',
                    style: GoogleFonts.cairo(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final req = requests[index];
                return _RequestCard(req: req);
              },
            ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final JobRequest req;

  const _RequestCard({required this.req});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    switch (req.status) {
      case 'accepted':
        statusColor = Colors.green;
        statusText = 'مقبول';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'مرفوض';
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'قيد الانتظار';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'طلب صيانة', // We could fetch tech name here if we had it joined
                        style: GoogleFonts.cairo(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        DateFormat('yyyy/MM/dd').format(req.timestamp),
                        style: GoogleFonts.cairo(
                             color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statusText,
                    style: GoogleFonts.cairo(
                        color: statusColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'الموعد: ${req.selectedSlot}',
                  style: GoogleFonts.cairo(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
