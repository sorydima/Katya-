import 'package:katya/store/events/security/model.dart';

class LoadSecurityEvents {
  final int page;
  final int pageSize;

  const LoadSecurityEvents({
    this.page = 0,
    this.pageSize = 20,
  });
}

class AddSecurityEvent {
  final SecurityEvent event;

  const AddSecurityEvent(this.event);
}

class ClearSecurityEvents {
  const ClearSecurityEvents();
}

class SetSecurityLoading {
  final bool loading;

  const SetSecurityLoading(this.loading);
}
