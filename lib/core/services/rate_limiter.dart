import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

/// Device-based daily rate limiter for guest users.
///
/// Uses a device identifier combined with a SharedPreferences sliding-window
/// counter to enforce the daily AI-call limit. The key scheme ensures automatic
/// daily reset without manual cleanup.
class RateLimiterService {
  /// Check if the user can make an AI call today.
  ///
  /// Returns `true` if today's call count is below [AppConfig.maxDailyCalls].
  Future<bool> canMakeCall() async {
    final deviceId = await _getDeviceId();
    final key = _buildKey(deviceId);

    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(key) ?? 0;
    return count < AppConfig.maxDailyCalls;
  }

  /// Record that an AI call was made.
  ///
  /// Reads the current counter, increments it atomically, and persists the new
  /// value. The write is awaited to ensure accuracy.
  Future<void> recordCall() async {
    final deviceId = await _getDeviceId();
    final key = _buildKey(deviceId);

    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, current + 1);
  }

  /// Get the number of remaining AI calls available today.
  ///
  /// Clamped to the range `[0, AppConfig.maxDailyCalls]`.
  Future<int> remainingCalls() async {
    final deviceId = await _getDeviceId();
    final key = _buildKey(deviceId);

    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(key) ?? 0;
    return (AppConfig.maxDailyCalls - count).clamp(0, AppConfig.maxDailyCalls);
  }

  // ─── Internal helpers ───

  /// Build a SharedPreferences key scoped to the device and today's date.
  String _buildKey(String deviceId) {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return '${AppConfig.rateLimitPrefix}${deviceId}_$today';
  }

  /// Get a stable device identifier.
  ///
  /// - Android: `androidInfo.id` (Android ID — stable across OS updates)
  /// - iOS: `iosInfo.identifierForVendor`
  /// - Fallback: `'unknown-platform'`
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
}
