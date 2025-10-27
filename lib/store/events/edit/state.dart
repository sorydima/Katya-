import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:katya/store/events/messages/model.dart';

part 'state.g.dart';

@JsonSerializable()
class EditState extends Equatable {
  final Map<String, bool> editingMessages;
  final Map<String, Message> messages;

  const EditState({
    this.editingMessages = const {},
    this.messages = const {},
  });

  @override
  List<Object> get props => [editingMessages, messages];

  EditState copyWith({
    Map<String, bool>? editingMessages,
    Map<String, Message>? messages,
  }) {
    return EditState(
      editingMessages: editingMessages ?? this.editingMessages,
      messages: messages ?? this.messages,
    );
  }

  bool isEditing(String eventId) => editingMessages[eventId] ?? false;

  Map<String, dynamic> toJson() => _$EditStateToJson(this);
  factory EditState.fromJson(Map<String, dynamic> json) => _$EditStateFromJson(json);
}
