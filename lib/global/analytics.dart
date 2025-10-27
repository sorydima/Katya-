import 'package:katya/global/print.dart';

/// Lightweight analytics shim.
/// Replace implementations with a real analytics SDK when available.
void trackEvent(String name, {Map<String, Object?>? params}) {
  // Do not log sensitive values. This shim writes to release logs.
  final safe = params == null ? '' : ' params=$params';
  log.release('[analytics] $name$safe');
}

void trackAuth(String action, {String? result, String? errcode}) {
  final name = 'auth_$action';
  final params = <String, Object?>{
    if (result != null) 'result': result,
    if (errcode != null) 'errcode': errcode,
  };
  trackEvent(name, params: params.isEmpty ? null : params);
}
