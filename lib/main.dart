
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme.dart';
import 'data/database_service.dart';
import 'screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    print("Initializing Firebase...");
    print("Platform: ${DefaultFirebaseOptions.currentPlatform.runtimeType}");
    print("API Key: ${DefaultFirebaseOptions.currentPlatform.apiKey}");
    print("Project ID: ${DefaultFirebaseOptions.currentPlatform.projectId}");

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase Initialized Successfully");
    
    runApp(const MyApp());
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text("Firebase Init Failed:\n$e", style: const TextStyle(color: Colors.red)),
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
