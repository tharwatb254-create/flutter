import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../data/database_service.dart';
import '../../models/models.dart';
import '../profile_screen.dart';
import 'location_viewer.dart';

class TechnicianDashboard extends StatefulWidget {
  const TechnicianDashboard({super.key});

  @override
  State<TechnicianDashboard> createState() => _TechnicianDashboardState();
}

class _TechnicianDashboardState extends State<TechnicianDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const _TechnicianHomeTab(),
      ProfileScreen(), // Remove const to allow Provider updates
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'الطلبات',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }
}

class _TechnicianHomeTab extends StatelessWidget {
  const _TechnicianHomeTab();

  @override
  Widget build(BuildContext context) {
    final requests = Provider.of<DatabaseService>(context).requests;

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        automaticallyImplyLeading: false,
      ),
      body: requests.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_ind, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'مفيش طلبات جديدة حالياً',
                    style: GoogleFonts.cairo(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                return _TechnicianRequestCard(req: requests[index]);
              },
            ),
    );
  }
}

class _TechnicianRequestCard extends StatelessWidget {
  final JobRequest req;

  const _TechnicianRequestCard({required this.req});

  @override
  Widget build(BuildContext context) {
    final isPending = req.status == 'pending';
    final hasLocation = req.latitude != null && req.longitude != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Icon(Icons.person, color: Theme.of(context).primaryColor),
              ),
              title: Text(
                'طلب حجز',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الموعد: ${req.selectedSlot}',
                    style: GoogleFonts.cairo(height: 1.5),
                  ),
                  if (hasLocation)
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.blue),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            req.address ?? 'موقع محدد',
                            style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: req.status == 'accepted' 
                      ? Colors.green.withOpacity(0.1) 
                      : req.status == 'rejected' ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  req.status == 'accepted' ? 'مقبول' : req.status == 'rejected' ? 'مرفوض' : 'جديد',
                  style: GoogleFonts.cairo(
                    color: req.status == 'accepted' 
                      ? Colors.green 
                      : req.status == 'rejected' ? Colors.red : Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
            if (hasLocation) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LocationViewerScreen(
                          latitude: req.latitude!,
                          longitude: req.longitude!,
                          address: req.address ?? 'موقع العميل',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.map, size: 18),
                  label: Text(
                    'عرض الموقع على الخريطة',
                    style: GoogleFonts.cairo(fontSize: 14),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
            if (isPending) ...[
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Provider.of<DatabaseService>(context, listen: false)
                            .updateRequestStatus(req.id, 'rejected');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('رفض'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Provider.of<DatabaseService>(context, listen: false)
                            .updateRequestStatus(req.id, 'accepted');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('قبول'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
