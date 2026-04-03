import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pos/core/dependency.dart';
import 'package:pos/core/services/storage_service.dart';
import 'package:pos/domain/responses/users/get_current_user.dart';

class PermissionHelper {
  static CurrentUserResponse? _currentUser;
  static Future<void> loadUser() async {
    try {
      final storage = getIt<StorageService>();
      final userJson = await storage.getString('current_user');
      if (userJson != null) {
        final Map<String, dynamic> data = jsonDecode(userJson);
        _currentUser = CurrentUserResponse.fromJson(data);
      }
    } catch (e) {
      debugPrint('Error loading user for PermissionHelper: $e');
    }
  }

  /// Checks if the current user has a specific permission (e.g., 'manage_products:create').
  static bool hasPermission(String permission) {
    if (_currentUser == null) return false;
    
    // System Manager or "All" role often bypasses all checks
    if (_currentUser!.message.roles.any((r) => 
        r.toLowerCase() == 'system manager' || 
        r.toLowerCase() == 'all')) {
      return true;
    }

    return _currentUser!.message.hasPermission(permission);
  }

  /// Checks if the current user has access to a module/capability (e.g., 'manage_products').
  static bool hasCapability(String capability) {
    if (_currentUser == null) return false;

    // System Manager or "All" role often bypasses all checks
    // if (_currentUser!.message.roles.any((r) => 
    //     r.toLowerCase() == 'system manager' || 
    //     r.toLowerCase() == 'all')) {
    //   return true;
    // }
    if (_currentUser!.message.roles.any((r) => 
        r.toLowerCase() == 'system manager' )) {
      return true;
    }

    return _currentUser!.message.hasCapability(capability);
  }

  /// Helper to get the current user message
  static CurrentUserMessage? get user => _currentUser?.message;
}
