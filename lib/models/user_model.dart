import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String email;
  final String username;
  final String? fullName;
  final String? profileImageUrl;
  final DateTime? dateOfBirth;
  final String? phoneNumber;
  final List<String> favoriteMovies;
  final List<String> watchHistory;
  final String subscription;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  UserModel({
    this.id,
    required this.email,
    required this.username,
    this.fullName,
    this.profileImageUrl,
    this.dateOfBirth,
    this.phoneNumber,
    this.favoriteMovies = const [],
    this.watchHistory = const [],
    this.subscription = 'free',
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  // Convert from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      fullName: data['fullName'],
      profileImageUrl: data['profileImageUrl'],
      dateOfBirth: data['dateOfBirth']?.toDate(),
      phoneNumber: data['phoneNumber'],
      favoriteMovies: _parseStringList(data['favoriteMovies']),
      watchHistory: _parseStringList(data['watchHistory']),
      subscription: data['subscription'] ?? 'free',
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'username': username,
      'fullName': fullName,
      'profileImageUrl': profileImageUrl,
      'dateOfBirth': dateOfBirth,
      'phoneNumber': phoneNumber,
      'favoriteMovies': favoriteMovies,
      'watchHistory': watchHistory,
      'subscription': subscription,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
    };
  }

  // Copy with method for updates
  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? fullName,
    String? profileImageUrl,
    DateTime? dateOfBirth,
    String? phoneNumber,
    List<String>? favoriteMovies,
    List<String>? watchHistory,
    String? subscription,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      favoriteMovies: favoriteMovies ?? this.favoriteMovies,
      watchHistory: watchHistory ?? this.watchHistory,
      subscription: subscription ?? this.subscription,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // Helper method to safely parse string lists
  static List<String> _parseStringList(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.map((item) => item.toString()).toList();
    }
    return [];
  }
}
