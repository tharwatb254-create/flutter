
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../data/database_service.dart';
import 'dashboard.dart';

class TechnicianSetupScreen extends StatefulWidget {
  const TechnicianSetupScreen({super.key});

  @override
  State<TechnicianSetupScreen> createState() => _TechnicianSetupScreenState();
}

class _TechnicianSetupScreenState extends State<TechnicianSetupScreen> {
  bool _isLoading = false;
  String? _selectedSpecialty;
  final List<String> _specialties = ['Electricity', 'Plumbing', 'Carpentry', 'Painting', 'AC', 'Cleaning'];
  final List<String> _availableTimes = ['09:00 AM', '10:00 AM', '11:00 AM', '12:00 PM', '01:00 PM', '02:00 PM', '03:00 PM', '04:00 PM', '05:00 PM'];
  final List<String> _selectedTimes = [];

  void _submitSetup() async {
    debugPrint('Submit Setup Clicked');
    if (_selectedSpecialty == null || _selectedTimes.isEmpty) {
      debugPrint('Validation Failed: Specialty or Times empty');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('برجاء اختيار الصنعة والمواعيد المتاحة')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      debugPrint('Calling registerTechnicianProfile...');
      
      // Add timeout to prevent infinite loading
      await Provider.of<DatabaseService>(context, listen: false)
          .registerTechnicianProfile(_selectedSpecialty!, _selectedTimes)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              debugPrint('⏱️ TIMEOUT: Firestore operation took too long');
              throw Exception('انتهت مهلة الاتصال. تحقق من اتصال الإنترنت والمحاولة مرة أخرى');
            },
          );
      
      debugPrint('Registration Successful');

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TechnicianDashboard()),
        );
      }
    } catch (e) {
      debugPrint('Registration Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('حدث خطأ: $e'),
             duration: const Duration(seconds: 5),
           ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إعداد الملف الشخصي')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'اختار صنعتك',
              style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _specialties.map((specialty) {
                final isSelected = _selectedSpecialty == specialty;
                return ChoiceChip(
                  label: Text(_translateSpecialty(specialty)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedSpecialty = selected ? specialty : null);
                  },
                  selectedColor: Theme.of(context).primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            Text(
              'المواعيد المتاحة',
              style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'حدد الأوقات اللي بتكون فاضي فيها',
              style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableTimes.map((time) {
                final isSelected = _selectedTimes.contains(time);
                return FilterChip(
                  label: Text(time),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTimes.add(time);
                      } else {
                        _selectedTimes.remove(time);
                      }
                    });
                  },
                  selectedColor: Theme.of(context).secondaryHeaderColor,
                );
              }).toList(),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitSetup,
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                  : const Text('حفظ وذهاب للوحة التحكم'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _translateSpecialty(String en) {
    switch (en) {
      case 'Electricity': return 'كهرباء';
      case 'Plumbing': return 'سباكة';
      case 'Carpentry': return 'نجارة';
      case 'Painting': return 'نقاشة';
      case 'AC': return 'تكييف';
      case 'Cleaning': return 'تنظيف';
      default: return en;
    }
  }
}
