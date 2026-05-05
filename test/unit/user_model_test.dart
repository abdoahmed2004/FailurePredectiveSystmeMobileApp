import 'package:flutter_test/flutter_test.dart';
import 'package:fpms_app/Models/user_model.dart';

void main() {
  group('User Model - Unit Tests', () {
    // ✅ Test 1: fromJson parses user with fullName key
    test('fromJson parses user correctly with fullName key', () {
      final json = {
        '_id': 'user_001',
        'fullName': 'Ahmed Ashraf',
        'email': 'ahmed@company.com',
        'role': 'engineer',
        'isVerified': true,
      };

      final user = User.fromJson(json);

      expect(user.id, 'user_001');
      expect(user.fullName, 'Ahmed Ashraf');
      expect(user.email, 'ahmed@company.com');
      expect(user.role, 'engineer');
      expect(user.isVerified, true);
    });

    // ✅ Test 2: fromJson tries multiple name keys (FullName, name, displayName)
    test('fromJson resolves name from FullName key', () {
      final json = {
        'id': 'user_002',
        'FullName': 'Omar Khaled',
        'email': 'omar@company.com',
        'role': 'admin',
        'isVerified': true,
      };

      final user = User.fromJson(json);
      expect(user.fullName, 'Omar Khaled');
    });

    test('fromJson falls back to name key if fullName missing', () {
      final json = {
        'id': 'user_003',
        'name': 'Ali Ahmed',
        'email': 'ali@company.com',
        'role': 'technician',
        'isVerified': false,
      };

      final user = User.fromJson(json);
      expect(user.fullName, 'Ali Ahmed');
    });

    // ✅ Test 3: fromJson returns 'N/A' when all name fields are missing
    test('fromJson sets fullName to N/A when no name key present', () {
      final json = {
        'id': 'user_004',
        'email': 'test@company.com',
        'role': 'engineer',
        'isVerified': false,
      };

      final user = User.fromJson(json);
      expect(user.fullName, 'N/A');
    });

    // ✅ Test 4: isVerified defaults to false when not in JSON
    test('fromJson defaults isVerified to false when missing', () {
      final json = {
        '_id': 'user_005',
        'fullName': 'Test User',
        'email': 'test2@company.com',
        'role': 'technician',
      };

      final user = User.fromJson(json);
      expect(user.isVerified, false);
    });
  });

  group('AuthResponse Model - Unit Tests', () {
    // ✅ Test 5: AuthResponse.fromJson wraps token, user, and message
    test('fromJson creates full AuthResponse correctly', () {
      final json = {
        'token': 'eyJhbGci.abc.xyz',
        'message': 'Login successful',
        'user': {
          '_id': 'user_010',
          'fullName': 'Manager User',
          'email': 'manager@company.com',
          'role': 'manager',
          'isVerified': true,
        },
      };

      final authResponse = AuthResponse.fromJson(json);

      expect(authResponse.token, 'eyJhbGci.abc.xyz');
      expect(authResponse.message, 'Login successful');
      expect(authResponse.user.role, 'manager');
      expect(authResponse.user.fullName, 'Manager User');
    });

    // ✅ Test 6: AuthResponse.fromJson uses default message when missing
    test('fromJson uses default message when message field is absent', () {
      final json = {
        'token': 'some_token',
        'user': {
          '_id': 'u1',
          'fullName': 'Test',
          'email': 'x@y.com',
          'role': 'engineer',
          'isVerified': true,
        },
      };

      final authResponse = AuthResponse.fromJson(json);
      expect(authResponse.message, 'Operation successful');
    });
  });
}
