import 'package:katya/global/libs/matrix/constants.dart';
import 'package:katya/store/events/messages/model.dart';
import 'package:katya/store/events/selectors.dart';
import 'package:test/test.dart';

void main() {
  group('Event Selectors]', () {
    test('latestMessage - one message works', () {
      const messageLatest = Message(
        id: 'test1',
        sender: '',
        timestamp: 2,
        type: MatrixMessageTypes.text,
        roomId: 'test_room',
      );
      final result = latestMessage([messageLatest]);

      expect(result, equals(messageLatest));
    });

    test('latestMessage - largest timestamp of 2 wins', () {
      const messageLatest = Message(
        id: 'test2',
        sender: '',
        timestamp: 2,
        type: MatrixMessageTypes.text,
        roomId: 'test_room',
      );
      final result = latestMessage([messageLatest, Message(id: '')]);

      expect(result, equals(messageLatest));
    });

    test('latestMessage - empty list', () {
      final result = latestMessage([]);

      expect(result, equals(null));
    });
  });
}
