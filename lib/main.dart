import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'theme.dart';
import 'data/database_service.dart';
import 'screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // START: Supabase Configuration
    await Supabase.initialize(
      url: 'https://lrsatkcdrcnrniglmakk.supabase.co',
      anonKey: 'sb_publishable_dbg9IkVuuovJ6LRRgQb0qg_rV4bNKnl',
    );
    // END: Supabase Configuration

    runApp(const MyApp());
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  "فشل تشغيل Firebase",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text("$e", style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                const Text(
                  "تأكد من:\n1. تفعيل Email/Password في Firebase Console\n2. إعدادات Firebase صحيحة",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DatabaseService(),
      child: MaterialApp(
        title: 'Sal7ny',
        debugShowCheckedModeBanner: false,
        theme: Sal7nyTheme.lightTheme,
        home: const WelcomeScreen(),
        locale: const Locale('ar', 'EG'),
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },
      ),
    );
  }
}