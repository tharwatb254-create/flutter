
enum UserRole { client, technician }

class UserModel {
  final String id;
  final String email;
  final String password;
  final UserRole role;
  final String? name;
  final String? profileImage;

  UserModel({
    required this.id,
    required this.email,
    required this.password,
    required this.role,
    this.name,
    this.profileImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role.name,
      'name': name,
      'profile_image': profileImage,
    };
  }

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      password: '', // Password is not stored in Firestore
      role: UserRole.values.firstWhere((e) => e.name == map['role'], orElse: () => UserRole.client),
      name: map['name'],
      profileImage: map['profile_image'],
    );
  }
}

class TechnicianModel {
  final String id;
  final String userId;
  final String name;
  final String specialty;
  final double rating;
  final int reviewCount;
  final double pricePerHour;
  final List<String> availableSlots;
  final String imageUrl;

  TechnicianModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.specialty,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.pricePerHour,
    this.availableSlots = const [],
    this.imageUrl = 'https://i.pravatar.cc/150?img=11',
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'specialty': specialty,
      'rating': rating,
      'reviewCount': reviewCount,
      'pricePerHour': pricePerHour,
      'availableSlots': availableSlots,
      'imageUrl': imageUrl,
    };
  }

  factory TechnicianModel.fromMap(String id, Map<String, dynamic> map) {
    return TechnicianModel(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      specialty: map['specialty'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      pricePerHour: (map['pricePerHour'] ?? 0.0).toDouble(),
      availableSlots: List<String>.from(map['availableSlots'] ?? []),
      imageUrl: map['imageUrl'] ?? 'https://i.pravatar.cc/150?img=11',
    );
  }
}

class JobRequest {
  final String id;
  final String clientId;
  final String technicianId;
  final DateTime timestamp;
  final String status;
  final String selectedSlot;
  final double? latitude;
  final double? longitude;
  final String? address;

  JobRequest({
    required this.id,
    required this.clientId,
    required this.technicianId,
    required this.timestamp,
    this.status = 'pending',
    required this.selectedSlot,
    this.latitude,
    this.longitude,
    this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'technicianId': technicianId,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'selectedSlot': selectedSlot,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }

  factory JobRequest.fromMap(String id, Map<String, dynamic> map) {
    return JobRequest(
      id: id,
      clientId: map['clientId'] ?? '',
      technicianId: map['technicianId'] ?? '',
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      status: map['status'] ?? 'pending',
      selectedSlot: map['selectedSlot'] ?? '',
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      address: map['address'],
    );
  }
}
