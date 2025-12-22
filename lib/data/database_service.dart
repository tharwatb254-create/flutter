
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  StreamSubscription<DocumentSnapshot>? _userProfileSubscription;

  DatabaseService() {
    // Listen to Auth State Changes
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _subscribeToUserProfile(user.uid);
      } else {
        _currentUser = null;
        _userProfileSubscription?.cancel();
        _requests = [];
        notifyListeners();
      }
    });
  }

  // Get Firebase Auth user ID
  String? getAuthUserId() {
    return _auth.currentUser?.uid;
  }

  // --- Auth Methods ---
  
  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      debugPrint('Login Error: $e');
      return false;
    }
  }

  Future<void> signup(String email, String password, UserRole role, String name) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if (cred.user != null) {
        // Update Firebase Auth Display Name for robustness
        await cred.user!.updateDisplayName(name);
        
        final newUser = UserModel(
          id: cred.user!.uid,
          email: email,
          password: '',
          role: role,
          name: name,
        );
        
        // Optimistic update
        _currentUser = newUser;
        notifyListeners();
        
        await _firestore.collection('users').doc(cred.user!.uid).set(newUser.toMap());
      }
    } catch (e) {
      throw Exception('Signup failed: $e');
    }
  }

  void logout() async {
    _userProfileSubscription?.cancel();
    await _auth.signOut();
  }

  void _subscribeToUserProfile(String uid) {
    debugPrint('🔔 Subscribing to user profile: $uid');
    _userProfileSubscription?.cancel();
    _userProfileSubscription = _firestore.collection('users').doc(uid).snapshots().listen(
      (doc) async {
        debugPrint('📥 User profile snapshot received. Exists: ${doc.exists}');
        if (doc.exists) {
          _currentUser = UserModel.fromMap(doc.id, doc.data()!);
          debugPrint('✅ User loaded: ${_currentUser!.name}, Role: ${_currentUser!.role}');
          
          if (_currentUser!.role == UserRole.client) {
            _fetchRequestsAsClient();
          } else {
            _fetchRequestsAsTechnician();
          }
          notifyListeners();
          debugPrint('🔔 notifyListeners() called');
        } else {
          debugPrint('⚠️ User document does not exist for UID: $uid');
          
          // Create user document from Firebase Auth data
          final authUser = _auth.currentUser;
          if (authUser != null) {
            debugPrint('🔧 Creating user document from Auth data...');
            
            // Check if user is in technicians collection to determine role
            final techDoc = await _firestore.collection('technicians').doc(uid).get();
            final role = techDoc.exists ? UserRole.technician : UserRole.client;
            
            final newUser = UserModel(
              id: uid,
              email: authUser.email ?? '',
              password: '',
              role: role,
              name: authUser.displayName ?? 'مستخدم',
            );
            
            try {
              await _firestore.collection('users').doc(uid).set(newUser.toMap());
              debugPrint('✅ User document created successfully');
            } catch (e) {
              debugPrint('❌ Failed to create user document: $e');
            }
          }
        }
      },
      onError: (e) {
        debugPrint('❌ Profile Stream Error: $e');
      }
    );
  }

  // --- Technician Methods ---

  Future<void> registerTechnicianProfile(String specialty, List<String> slots) async {
    debugPrint('=== registerTechnicianProfile START ===');
    debugPrint('Specialty: $specialty');
    debugPrint('Slots: $slots');
    
    // Robust check: Use Auth User if local model is null
    final authUser = _auth.currentUser;
    
    debugPrint('Auth User: ${authUser?.uid ?? "NULL"}');
    debugPrint('Auth User Email: ${authUser?.email ?? "NULL"}');
    debugPrint('Current User Model: ${_currentUser?.id ?? "NULL"}');
    
    if (authUser == null) {
      debugPrint('❌ Error: Cannot register technician, user is null');
      throw Exception('User is not logged in properly');
    }
    
    // Use local model name or auth name or fallback
    final String name = _currentUser?.name ?? authUser.displayName ?? 'Unknown';
    
    debugPrint('Technician Name: $name');
    
    final tech = TechnicianModel(
      id: authUser.uid, 
      userId: authUser.uid,
      name: name,
      specialty: specialty,
      pricePerHour: 50.0,
      availableSlots: slots,
    );
    
    debugPrint('Tech Model Created: ${tech.toMap()}');
    debugPrint('Attempting Firestore write...');
    
    try {
      await _firestore.collection('technicians').doc(tech.id).set(tech.toMap());
      debugPrint('✅ Firestore write SUCCESSFUL');
    } catch (e) {
      debugPrint('❌ Firestore write FAILED: $e');
      rethrow;
    }
    
    debugPrint('=== registerTechnicianProfile END ===');
  }

  // Check if technician profile exists
  Future<bool> checkTechnicianProfileExists(String userId) async {
    try {
      final doc = await _firestore.collection('technicians').doc(userId).get();
      return doc.exists;
    } catch (e) {
      debugPrint('Error checking technician profile: $e');
      return false;
    }
  }

  // Changed to fetch from Firestore instead of in-memory filtering
  Stream<List<TechnicianModel>> streamTechniciansByCategory(String category) {
    return _firestore
        .collection('technicians')
        .where('specialty', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TechnicianModel.fromMap(doc.id, doc.data()))
            .toList());
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
  
  // Helper to get cached technicians (backward compatibility with UI)
  List<TechnicianModel> getTechniciansByCategory(String category) {
    // In a real app, we should trigger a fetch here or have a stream.
    // For now, we return the cached list and trigger a fetch.
    fetchTechniciansByCategory(category);
    return _technicians.where((t) => t.specialty == category).toList();
  }

  // --- Request Methods ---
  
  Future<void> createRequest(
    TechnicianModel tech,
    String slot, {
    double? latitude,
    double? longitude,
    String? address,
  }) async {
    final authUser = _auth.currentUser;
    if (authUser == null) return;
    
    final req = JobRequest(
      id: '', // Auto-generated by Firestore
      clientId: authUser.uid,
      technicianId: tech.id,
      timestamp: DateTime.now(),
      selectedSlot: slot,
      status: 'pending',
      latitude: latitude,
      longitude: longitude,
      address: address,
    );
    
    await _firestore.collection('requests').add(req.toMap());
    _fetchRequestsAsClient(); // Refresh
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    await _firestore.collection('requests').doc(requestId).update({'status': status});
    
    // Refresh local lists
    if (_currentUser?.role == UserRole.technician) {
      await _fetchRequestsAsTechnician();
    } else {
      await _fetchRequestsAsClient();
    }
  }

  Future<void> _fetchRequestsAsClient() async {
    if (_currentUser == null) return;
    final q = await _firestore.collection('requests').where('clientId', isEqualTo: _currentUser!.id).get();
    _requests = q.docs.map((d) => JobRequest.fromMap(d.id, d.data())).toList();
    // Sort by timestamp descending
    _requests.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    notifyListeners();
  }
  
  Future<void> _fetchRequestsAsTechnician() async {
    if (_currentUser == null) return;
    final q = await _firestore.collection('requests').where('technicianId', isEqualTo: _currentUser!.id).get();
    _requests = q.docs.map((d) => JobRequest.fromMap(d.id, d.data())).toList();
    // Sort by timestamp descending
    _requests.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    notifyListeners();
  }
}
