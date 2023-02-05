import 'package:katya/context/types.dart';

bool selectScreenLockEnabled(AppContext context) {
  return context.pinHash.isNotEmpty && context.secretKeyEncrypted.isNotEmpty;
}
