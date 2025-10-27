import 'package:katya/store/events/security/actions.dart';
import 'package:katya/store/events/security/model.dart';
import 'package:katya/store/index.dart';
import 'package:redux/redux.dart';

class SecurityStore {
  final bool isLoading;
  final List<SecurityEvent> events;

  const SecurityStore({
    this.isLoading = false,
    this.events = const [],
  });

  SecurityStore copyWith({
    bool? isLoading,
    List<SecurityEvent>? events,
  }) {
    return SecurityStore(
      isLoading: isLoading ?? this.isLoading,
      events: events ?? this.events,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SecurityStore &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          events == other.events;

  @override
  int get hashCode => isLoading.hashCode ^ events.hashCode;
}

SecurityStore securityReducer([SecurityStore state = const SecurityStore(), dynamic action]) {
  if (action is SetSecurityLoading) {
    return state.copyWith(isLoading: action.loading);
  }

  if (action is LoadSecurityEvents) {
    return state.copyWith(isLoading: true);
  }

  if (action is AddSecurityEvent) {
    return state.copyWith(
      events: [action.event, ...state.events],
    );
  }

  if (action is ClearSecurityEvents) {
    return state.copyWith(events: []);
  }

  return state;
}

// Middleware for handling async actions
List<Middleware<AppState>> createSecurityMiddleware() {
  return [
    TypedMiddleware<AppState, LoadSecurityEvents>(
      (store, action, next) async {
        next(const SetSecurityLoading(true));
        try {
          // TODO: Replace with actual API call to fetch security events
          await Future.delayed(const Duration(milliseconds: 500));

          // Mock data for now
          final mockEvents = List.generate(
            action.pageSize,
            (index) => SecurityEvent(
              id: '${DateTime.now().millisecondsSinceEpoch}-$index',
              type: _getRandomEventType(),
              description: 'Security event ${action.page * action.pageSize + index + 1}',
              timestamp: DateTime.now().subtract(Duration(hours: index)),
              ipAddress: '192.168.1.${index % 255}',
              userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            ),
          );

          // In a real app, we would append the new events to the existing ones
          // and handle pagination properly
          next(const ClearSecurityEvents());
          for (final event in mockEvents) {
            next(AddSecurityEvent(event));
          }
        } catch (e) {
          // Handle error
          print('Error loading security events: $e');
        } finally {
          next(const SetSecurityLoading(false));
        }
      },
    ).call,
  ];
}

// Helper function to generate random event types for mock data
SecurityEventType _getRandomEventType() {
  final random = DateTime.now().millisecondsSinceEpoch % SecurityEventType.values.length;
  return SecurityEventType.values[random];
}
