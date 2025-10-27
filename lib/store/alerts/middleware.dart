import 'package:katya/global/libs/matrix/errors.dart';
import 'package:katya/global/weburl.dart';
import 'package:katya/store/alerts/actions.dart';
import 'package:katya/store/index.dart';
import 'package:redux/redux.dart';

dynamic alertMiddleware<State>(
  Store<AppState> store,
  dynamic action,
  NextDispatcher next,
) async {
  switch (action.runtimeType) {
    case AddAlert:
      final alert = action.alert.error ?? '';

      // TODO: prompt user that they're going to be redirected for a terms
      // and conditions acceptance
      if (alert.contains(MatrixErrorsSoft.terms_and_conditions)) {
        final termsUrl = 'https${alert.split('https')[1]}';
        final termsUrlFormatted = termsUrl.replaceFirst('.', '', termsUrl.length - 1);

        await launchUrl(termsUrlFormatted);
      }

    default:
      break;
  }

  next(action);
}
