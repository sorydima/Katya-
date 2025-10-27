import 'package:katya/store/events/edit/actions.dart';
import 'package:katya/store/events/edit/state.dart';

EditState editReducer(EditState state, dynamic action) {
  if (action is EditMessage) {
    // Create a new map with the updated message
    final updatedMessages = Map<String, Message>.from(state.messages);

    if (action.newContent != null) {
      final message = updatedMessages[action.eventId]?.copyWith(
        body: action.newContent,
        editedTimestamp: DateTime.now().millisecondsSinceEpoch,
      );

      if (message != null) {
        updatedMessages[action.eventId] = message;
      }
    }

    return state.copyWith(
      messages: updatedMessages,
      editingMessages: {
        ...state.editingMessages,
        action.eventId: action.isEdit,
      },
    );
  }

  if (action is SetMessageEdit) {
    return state.copyWith(
      editingMessages: {
        ...state.editingMessages,
        action.eventId: action.isEditing,
      },
    );
  }

  return state;
}
