import 'package:flutter_test/flutter_test.dart';
import 'package:linguo_wizard/features/conversation/models/message.dart';

void main() {
  group('Message', () {
    test('create generates unique id and current timestamp', () {
      final msg1 = Message.create(sender: MessageSender.user, transcript: 'Hello');
      final msg2 = Message.create(sender: MessageSender.ai, transcript: 'Hi there');

      expect(msg1.id, isNotEmpty);
      expect(msg2.id, isNotEmpty);
      expect(msg1.id, isNot(equals(msg2.id)));
      expect(msg1.sender, MessageSender.user);
      expect(msg2.sender, MessageSender.ai);
      expect(msg1.transcript, 'Hello');
      expect(msg2.transcript, 'Hi there');
      expect(msg1.timestamp, isA<DateTime>());
    });

    test('create with audioDuration', () {
      final msg = Message.create(
        sender: MessageSender.user,
        transcript: 'Test',
        audioDuration: const Duration(seconds: 5),
      );

      expect(msg.audioDuration, const Duration(seconds: 5));
    });

    test('create without audioDuration defaults to null', () {
      final msg = Message.create(sender: MessageSender.user, transcript: 'Test');
      expect(msg.audioDuration, isNull);
    });

    test('constructor with all parameters', () {
      final timestamp = DateTime(2026, 7, 18);
      final msg = Message(
        id: 'test-id',
        sender: MessageSender.ai,
        transcript: 'Response',
        timestamp: timestamp,
        audioDuration: const Duration(seconds: 3),
      );

      expect(msg.id, 'test-id');
      expect(msg.sender, MessageSender.ai);
      expect(msg.transcript, 'Response');
      expect(msg.timestamp, timestamp);
      expect(msg.audioDuration, const Duration(seconds: 3));
    });
  });
}
