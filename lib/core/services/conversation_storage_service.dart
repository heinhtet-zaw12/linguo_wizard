import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/conversation/models/message.dart';
import '../../features/scenario_selection/models/scenario.dart';

/// Serializable snapshot of a conversation for persistence.
class ConversationSnapshot {
  final String scenarioId;
  final List<Map<String, dynamic>> messagesJson;
  final int turnCount;
  final String savedAt;

  const ConversationSnapshot({
    required this.scenarioId,
    required this.messagesJson,
    required this.turnCount,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
        'scenarioId': scenarioId,
        'messages': messagesJson,
        'turnCount': turnCount,
        'savedAt': savedAt,
      };

  factory ConversationSnapshot.fromJson(Map<String, dynamic> json) {
    return ConversationSnapshot(
      scenarioId: json['scenarioId'] as String? ?? '',
      messagesJson: (json['messages'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      turnCount: json['turnCount'] as int? ?? 0,
      savedAt: json['savedAt'] as String? ?? '',
    );
  }
}

/// Persistence layer for in-progress conversations.
///
/// Guests: serialized to SharedPreferences as JSON keyed by scenario ID.
/// Auth users: saved to Firestore under `users/{uid}/conversations/{scenarioId}`.
class ConversationStorageService {
  static const String _guestPrefix = 'saved_conversation_';

  /// Save a conversation for a guest user (SharedPreferences).
  Future<void> saveConversationGuest({
    required Scenario scenario,
    required List<Message> messages,
    required int turnCount,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final snapshot = ConversationSnapshot(
      scenarioId: scenario.id,
      messagesJson: messages
          .map((m) => {
                'sender': m.sender.name,
                'transcript': m.transcript,
                'id': m.id,
                'timestamp': m.timestamp.toIso8601String(),
              })
          .toList(),
      turnCount: turnCount,
      savedAt: DateTime.now().toIso8601String(),
    );
    await prefs.setString(
      '$_guestPrefix${scenario.id}',
      jsonEncode(snapshot.toJson()),
    );
  }

  /// Load a saved conversation for a guest user, or null if none exists.
  Future<ConversationSnapshot?> loadConversationGuest(String scenarioId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_guestPrefix$scenarioId');
    if (raw == null) return null;
    try {
      return ConversationSnapshot.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  /// Delete a saved conversation for a guest user.
  Future<void> deleteConversationGuest(String scenarioId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_guestPrefix$scenarioId');
  }

  /// Check if a saved conversation exists for a guest user.
  Future<bool> hasConversationGuest(String scenarioId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('$_guestPrefix$scenarioId');
  }

  // ─── Authenticated user (Firestore) ───

  /// Save a conversation for an authenticated user (Firestore).
  Future<void> saveConversationUser({
    required String uid,
    required Scenario scenario,
    required List<Message> messages,
    required int turnCount,
  }) async {
    final snapshot = ConversationSnapshot(
      scenarioId: scenario.id,
      messagesJson: messages
          .map((m) => {
                'sender': m.sender.name,
                'transcript': m.transcript,
                'id': m.id,
                'timestamp': m.timestamp.toIso8601String(),
              })
          .toList(),
      turnCount: turnCount,
      savedAt: DateTime.now().toIso8601String(),
    );
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('conversations')
        .doc(scenario.id)
        .set(snapshot.toJson());
  }

  /// Load a saved conversation for an authenticated user, or null.
  Future<ConversationSnapshot?> loadConversationUser({
    required String uid,
    required String scenarioId,
  }) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('conversations')
          .doc(scenarioId)
          .get();
      if (!doc.exists) return null;
      return ConversationSnapshot.fromJson(doc.data()!);
    } catch (_) {
      return null;
    }
  }

  /// Delete a saved conversation for an authenticated user.
  Future<void> deleteConversationUser({
    required String uid,
    required String scenarioId,
  }) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('conversations')
        .doc(scenarioId)
        .delete();
  }

  /// Check if a saved conversation exists for an authenticated user.
  Future<bool> hasConversationUser({
    required String uid,
    required String scenarioId,
  }) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('conversations')
          .doc(scenarioId)
          .get();
      return doc.exists;
    } catch (_) {
      return false;
    }
  }

  /// Reconstruct [Message] list from snapshot JSON.
  static List<Message> messagesFromSnapshot(ConversationSnapshot snapshot) {
    return snapshot.messagesJson.map((m) {
      final sender = m['sender'] == 'user'
          ? MessageSender.user
          : MessageSender.ai;
      return Message(
        id: m['id'] as String? ?? '',
        sender: sender,
        transcript: m['transcript'] as String? ?? '',
        timestamp: DateTime.tryParse(m['timestamp'] as String? ?? '') ??
            DateTime.now(),
      );
    }).toList();
  }
}
