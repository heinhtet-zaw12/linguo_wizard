import 'package:uuid/uuid.dart';

/// Who sent the message.
enum MessageSender { user, ai }

/// A single message in a conversation — either a user voice message or AI response.
class Message {
  final String id;
  final MessageSender sender;
  final String transcript;
  final DateTime timestamp;
  final Duration? audioDuration;

  const Message({
    required this.id,
    required this.sender,
    required this.transcript,
    required this.timestamp,
    this.audioDuration,
  });

  /// Creates a new [Message] with an auto-generated ID and current timestamp.
  factory Message.create({
    required MessageSender sender,
    required String transcript,
    Duration? audioDuration,
  }) {
    return Message(
      id: const Uuid().v4(),
      sender: sender,
      transcript: transcript,
      timestamp: DateTime.now(),
      audioDuration: audioDuration,
    );
  }
}
