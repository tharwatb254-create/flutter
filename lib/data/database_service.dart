import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'dart:io';
import '../models/models.dart';

class DatabaseService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  List<TechnicianModel> _technicians = [];
  List<JobRequest> _requests = [];

  UserModel? get currentUser => _currentUser;
  List<TechnicianModel> get technicians => _technicians;
  List<JobRequest> get requests => _requests;

  DatabaseService() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _fetchUserProfile(user.uid);
      } else {
        _currentUser = null;
        _requests = [];
        notifyListeners();
      }
    });
  }

  // --- Auth Methods ---
  
  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Login Error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Login Error: $e');
      return false;
    }
  }

  Future<void> signup(String email, String password, UserRole role, String name) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      if (cred.user != null) {
        final newUser = UserModel(
          id: cred.user!.uid,
          email: email,
          password: '',
          role: role,
          name: name,
        );
        
        await _firestore.collection('users').doc(cred.user!.uid).set(newUser.toMap());
        _currentUser = newUser;
        notifyListeners();
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'حدث خطأ في التسجيل';
      
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'البريد الإلكتروني مستخدم بالفعل';
          break;
        case 'invalid-email':
          errorMessage = 'البريد الإلكتروني غير صحيح';
          break;
        case 'operation-not-allowed':
          errorMessage = 'التسجيل بالبريد الإلكتروني غير مفعّل. تأكد من تفعيل Email/Password في Firebase Console';
          break;
        case 'weak-password':
          errorMessage = 'كلمة المرور ضعيفة';
          break;
        default:
          errorMessage = 'خطأ: ${e.message}';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      debugPrint('Signup Error: $e');
      throw Exception('فشل التسجيل: $e');
    }
  }

  void logout() async {
    await _auth.signOut();
  }

  Future<void> _fetchUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.id, doc.data()!);
        
        if (_currentUser!.role == UserRole.client) {
          _fetchRequestsAsClient();
        } else {
          _fetchRequestsAsTechnician();
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Fetch Profile Error: $e');
    }
  }

  // --- Supabase Storage Methods ---

  Future<String?> uploadProfileImage(File imageFile) async {
    if (_auth.currentUser == null) {
      debugPrint('❌ Upload Error: No logged-in user found');
      return null;
    }
    
    try {
      final userId = _auth.currentUser!.uid;
      final fileExt = imageFile.path.split('.').last;
      final fileName = '$userId.$fileExt';
      debugPrint('🚀 Starting upload for user: $userId, FileName: $fileName');

      // 1. Upload to Supabase
      final supabase = Supabase.instance.client;
      debugPrint('📡 Uploading binary to Supabase bucket: profile-images');
      
      await supabase.storage.from('profile-images').uploadBinary(
        fileName,
        await imageFile.readAsBytes(),
        fileOptions: const FileOptions(upsert: true),
      );
      debugPrint('✅ Supabase upload successful');

      // 2. Get Public URL
      final String publicUrl = supabase.storage.from('profile-images').getPublicUrl(fileName);
      debugPrint('🔗 Public URL generated: $publicUrl');
      
      // Add cache buster to URL
      final finalUrl = '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';

      // 3. Save to Firebase Auth
      debugPrint('🔥 Updating Firebase Auth photoURL...');
      await _auth.currentUser!.updatePhotoURL(finalUrl);

      // 4. Save to Firestore
      debugPrint('🔥 Updating Firestore users collection...');
      await _firestore.collection('users').doc(userId).set({
        'profile_image': finalUrl,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 5. Update local state
      debugPrint('📱 Updating local state...');
      if (_currentUser != null) {
        _currentUser = UserModel(
          id: _currentUser!.id,
          email: _currentUser!.email,
          password: '',
          role: _currentUser!.role,
          name: _currentUser!.name,
          profileImage: finalUrl,
        );
        notifyListeners();
      }

      debugPrint('✨ All steps completed successfully!');
      return finalUrl;
    } catch (e) {
      debugPrint('🛑 CRITICAL UPLOAD ERROR: $e');
      rethrow;
    }
  }

  // --- Technician Methods ---

  Future<void> registerTechnicianProfile(String specialty, List<String> slots) async {
    if (_currentUser == null) return;
    
    final tech = TechnicianModel(
      id: _currentUser!.id,
      userId: _currentUser!.id,
      name: _currentUser!.name ?? 'Unknown',
      specialty: specialty,
      pricePerHour: 50.0,
      availableSlots: slots,
    );
    
    await _firestore.collection('technicians').doc(tech.id).set(tech.toMap());
  }

  Future<void> fetchTechniciansByCategory(String category) async {
    try {
      final query = await _firestore.collection('technicians')
          .where('specialty', isEqualTo: category)
          .get();
          
      _technicians = query.docs
          .map((doc) => TechnicianModel.fromMap(doc.id, doc.data()))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Fetch Techs Error: $e');
    }
  }
  
  List<TechnicianModel> getTechniciansByCategory(String category) {
    fetchTechniciansByCategory(category);
    return _technicians.where((t) => t.specialty == category).toList();
  }

  // --- Request Methods ---
  
  Future<void> createRequest(TechnicianModel tech, String slot, {required double latitude, required double longitude, required String address}) async {
    if (_currentUser == null) return;
    
    final req = JobRequest(
      id: '',
      clientId: _currentUser!.id,
      technicianId: tech.id,
      timestamp: DateTime.now(),
      selectedSlot: slot,
      status: 'pending',
      latitude: latitude,
      longitude: longitude,
      address: address,
    );
    
    await _firestore.collection('requests').add(req.toMap());
    _fetchRequestsAsClient();
  }

  Future<void> _fetchRequestsAsClient() async {
    if (_currentUser == null) return;
    final q = await _firestore.collection('requests')
        .where('clientId', isEqualTo: _currentUser!.id)
        .get();
    _requests = q.docs.map((d) => JobRequest.fromMap(d.id, d.data())).toList();
    notifyListeners();
  }
  
  Future<void> _fetchRequestsAsTechnician() async {
    if (_currentUser == null) return;
    final q = await _firestore.collection('requests')
        .where('technicianId', isEqualTo: _currentUser!.id)
        .get();
    _requests = q.docs.map((d) => JobRequest.fromMap(d.id, d.data())).toList();
    notifyListeners();
  }

  Future<void> updateRequestStatus(String id, String status) async {
    try {
      await _firestore.collection('requests').doc(id).update({
        'status': status,
      });
      
      // Update local state and notify listeners
      if (_currentUser != null) {
        if (_currentUser!.role == UserRole.client) {
          _fetchRequestsAsClient();
        } else {
          _fetchRequestsAsTechnician();
        }
      }
    } catch (e) {
      debugPrint('Update Status Error: $e');
    }
  }

  Stream<List<TechnicianModel>> streamTechniciansByCategory(String categoryName) {
    debugPrint('📡 Streaming technicians for category: $categoryName');
    return _firestore.collection('technicians')
        .where('specialty', isEqualTo: categoryName)
        .snapshots()
        .map((snapshot) {
          debugPrint('✅ Found ${snapshot.docs.length} technicians in $categoryName');
          return snapshot.docs
              .map((doc) => TechnicianModel.fromMap(doc.id, doc.data()))
              .toList();
        });
  }

  String? getAuthUserId() {
    return _auth.currentUser?.uid;
  }

  Future<bool> checkTechnicianProfileExists(String userId) async {
    try {
      final doc = await _firestore.collection('technicians').doc(userId).get();
      return doc.exists;
    } catch (e) {
      debugPrint('Error checking tech profile: $e');
      return false;
    }
  }
}