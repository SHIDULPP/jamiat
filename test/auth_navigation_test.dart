import 'package:flutter_test/flutter_test.dart';
import 'package:jamiat/src/data/models/api_response.dart';
import 'package:jamiat/src/data/models/user_model.dart';
import 'package:jamiat/src/data/utils/auth_navigation.dart';

void main() {
  group('auth navigation', () {
    test('active users with complete profiles enter the app', () {
      final user = UserModel.fromJson({
        '_id': 'user-1',
        'phone': '+919999999999',
        'status': 'active',
        'role': 'normal_member',
        'is_profile_complete': true,
      });

      expect(routeForUser(user), 'navBar');
    });

    test('incomplete users continue onboarding', () {
      final user = UserModel.fromJson({
        '_id': 'user-1',
        'phone': '+919999999999',
        'status': 'inactive',
        'role': 'jamiat_member',
        'is_profile_complete': false,
      });

      expect(routeForUser(user), 'RoleSelection');
    });
  });

  test('nestedData extracts the backend response envelope', () {
    final data = nestedData({
      'status': 200,
      'data': {'token': 'token'},
    });

    expect(data, {'token': 'token'});
  });
}
