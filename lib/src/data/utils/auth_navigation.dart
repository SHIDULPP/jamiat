import 'package:jamiat/src/data/models/user_model.dart';

String routeForUser(UserModel user) {
  if (user.canEnterApp) {
    return 'navBar';
  }
  return 'RoleSelection';
}
