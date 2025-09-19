import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

class UserProfileProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  UserProfileProvider() {
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user != null) {
        // Load from Firestore if user is authenticated
        await _loadProfileFromFirestore(user);
      } else {
        // Load from local storage
        await _loadProfileFromLocal();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error loading profile: $e';
      notifyListeners();
    }
  }

  Future<void> _loadProfileFromFirestore(User user) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('profile')
          .doc('data')
          .get();

      if (doc.exists) {
        _userProfile = UserProfile.fromMap(doc.data()!);
      } else {
        // Create default profile
        _userProfile = _createDefaultProfile(user);
        await _saveProfileToFirestore();
      }
    } catch (e) {
      throw Exception('Failed to load profile from cloud: $e');
    }
  }

  Future<void> _loadProfileFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileData = prefs.getString('userProfile');

      if (profileData != null) {
        final profileMap = json.decode(profileData) as Map<String, dynamic>;
        _userProfile = UserProfile.fromMap(profileMap);
      } else {
        // Create default profile for offline use
        _userProfile = UserProfile(
          userId: 'offline_user',
          displayName: 'User',
          email: 'user@example.com',
          joinDate: DateTime.now(),
        );
        await _saveProfileToLocal();
      }
    } catch (e) {
      throw Exception('Failed to load profile from local storage: $e');
    }
  }

  UserProfile _createDefaultProfile(User user) {
    return UserProfile(
      userId: user.uid,
      displayName: user.displayName ?? user.email?.split('@')[0] ?? 'User',
      email: user.email ?? '',
      joinDate: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  Future<void> updateProfile({
    String? displayName,
    String? email,
    int? readingGoal,
    Map<String, dynamic>? settings,
  }) async {
    if (_userProfile == null) return;

    try {
      _userProfile = _userProfile!.copyWith(
        displayName: displayName,
        email: email,
        readingGoal: readingGoal,
        settings: settings,
      );

      if (_auth.currentUser != null) {
        await _saveProfileToFirestore();
      } else {
        await _saveProfileToLocal();
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error updating profile: $e';
      notifyListeners();
    }
  }

  Future<void> updateReadingStats({
    int? booksCompleted,
    int? readingTimeMinutes,
  }) async {
    if (_userProfile == null) return;

    try {
      _userProfile = _userProfile!.copyWith(
        booksCompletedThisYear: booksCompleted ?? _userProfile!.booksCompletedThisYear,
        totalReadingTimeMinutes: (readingTimeMinutes ?? 0) + _userProfile!.totalReadingTimeMinutes,
      );

      if (_auth.currentUser != null) {
        await _saveProfileToFirestore();
      } else {
        await _saveProfileToLocal();
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error updating reading stats: $e';
      notifyListeners();
    }
  }

  Future<void> _saveProfileToFirestore() async {
    if (_userProfile == null || _auth.currentUser == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('profile')
          .doc('data')
          .set(_userProfile!.toMap());
    } catch (e) {
      throw Exception('Failed to save profile to cloud: $e');
    }
  }

  Future<void> _saveProfileToLocal() async {
    if (_userProfile == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final profileData = json.encode(_userProfile!.toMap());
      await prefs.setString('userProfile', profileData);
    } catch (e) {
      throw Exception('Failed to save profile locally: $e');
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}