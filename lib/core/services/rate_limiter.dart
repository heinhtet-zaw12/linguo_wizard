import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

/// Daily rate limiter supporting both device-based (guest) and user-based (authenticated) limits.
///
/// Guest users: uses device identifier + SharedPreferences sliding-window counter.
/// Authenticated users: uses Firestore document at `users/{userId}/rateLimits`.
class RateLimiterService {
  // ─── Guest (device-based) methods ───

  /// Check if the guest user can make an AI call today.
  Future<bool> canMakeCall() async {
    final deviceId = await _getDeviceId();
    final key = _buildKey(deviceId);

    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(key) ?? 0;
    return count < AppConfig.maxDailyCalls;
  }

  /// Record that a guest AI call was made.
  Future<void> recordCall() async {
    final deviceId = await _getDeviceId();
    final key = _buildKey(deviceId);

    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, current + 1);
  }

  /// Get the number of remaining AI calls available today for a guest.
  Future<int> remainingCalls() async {
    final deviceId = await _getDeviceId();
    final key = _buildKey(deviceId);

    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(key) ?? 0;
    return (AppConfig.maxDailyCalls - count).clamp(0, AppConfig.maxDailyCalls);
  }

  // ─── Authenticated (user-based) methods ───

  /// Check if the authenticated user can make an AI call today.
  ///
  /// Reads from Firestore `users/{userId}/rateLimits` field.
  Future<bool> canMakeCallForUser(String userId) async {
    final data = await _readUserRateLimit(userId);
    if (data == null) return true;

    final date = data['date'] as String?;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (date != today) return true; // New day — reset.

    final count = data['dailyCalls'] as int? ?? 0;
    return count < AppConfig.maxDailyCalls;
  }

  /// Record that an authenticated user's AI call was made.
  Future<void> recordCallForUser(String userId) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final ref = _userRateLimitRef(userId);

    await FirebaseFirestore.instance.runTransaction((txn) async {
      final doc = await txn.get(ref);
      final data = doc.data();
      final existingDate = data?['date'] as String?;
      final existingCount =
          (existingDate == today) ? (data?['dailyCalls'] as int? ?? 0) : 0;

      txn.set(ref, {
        'dailyCalls': existingCount + 1,
        'date': today,
      });
    });
  }

  /// Get remaining calls for an authenticated user.
  Future<int> remainingCallsForUser(String userId) async {
    final data = await _readUserRateLimit(userId);
    if (data == null) return AppConfig.maxDailyCalls;

    final date = data['date'] as String?;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (date != today) return AppConfig.maxDailyCalls;

    final count = data['dailyCalls'] as int? ?? 0;
    return (AppConfig.maxDailyCalls - count).clamp(0, AppConfig.maxDailyCalls);
  }

  // ─── Internal helpers ───

  /// Build a SharedPreferences key scoped to the device and today's date.
  String _buildKey(String deviceId) {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return '${AppConfig.rateLimitPrefix}${deviceId}_$today';
  }

  /// Get a stable device identifier.
  Future<String> _getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final android = await deviceInfo.androidInfo;
        return android.id;
      } else if (Platform.isIOS) {
        final ios = await deviceInfo.iosInfo;
        return ios.identifierForVendor ?? 'unknown-ios';
      }
    } catch (_) {
      // Device info unavailable — fall through to platform fallback.
    }
    return 'unknown-platform';
  }

  /// Firestore document reference for user rate limit data.
  DocumentReference<Map<String, dynamic>> _userRateLimitRef(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('rateLimits')
        .doc('daily');
  }

  /// Read the user's rate limit document from Firestore.
  Future<Map<String, dynamic>?> _readUserRateLimit(String userId) async {
    final doc = await _userRateLimitRef(userId).get();
    return doc.data();
  }
}
