import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../Models/user_model.dart';

// Base URL resolver:
// - You can override at build time with `--dart-define=API_BASE_URL=http://192.168.1.4:3000/api`
// - Defaults: Android -> 10.0.2.2 (emulator), others -> 127.0.0.1
const String _envBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
final String baseUrl = _resolveBaseUrl();
const Duration requestTimeout = Duration(seconds: 10);

String _resolveBaseUrl() {
  if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
  try {
    if (Platform.isAndroid) {
      // Android emulator mapping to host machine
      return 'http://10.0.2.2:3000/api';
    }
  } catch (_) {}
  // Default for iOS simulator, desktop and others
  return 'http://127.0.0.1:3000/api';
}
class AuthService {
  final Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  // Helpful debug logger for outgoing requests
  void _debugRequest(String method, Uri url, [String? body]) {
    // Use print so it's visible in Flutter debug console
    print('HTTP $method -> $url');
    if (body != null) print('Body: $body');
  }

  // --- REGISTRATION FUNCTION ---
  Future<AuthResponse> registerUser({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    
    final body = jsonEncode({
      'fullName': fullName,
      'email': email,
      'password': password,
      'role': role.toLowerCase(), // Ensure lowercase for backend enum
    });

    try {
      _debugRequest('POST', url, body);
      final response = await http.post(url, headers: _headers, body: body).timeout(requestTimeout);

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return AuthResponse(
          token: jsonResponse['token'],
          user: User.fromJson(jsonResponse['user']),
          message: jsonResponse['message'] ?? 'Registration successful!',
        );
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to register user.');
      }
    } on TimeoutException {
      throw Exception('Request timed out. Please check your network and try again.');
    } on SocketException {
      throw Exception('Network error. Could not reach server. Is the API running and reachable?');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }


Future<String> resendVerificationEmail({required String email}) async {
    final url = Uri.parse('$baseUrl/resend-verification');
    
    try {
      final body = jsonEncode({'email': email});
      _debugRequest('POST', url, body);
      final response = await http.post(url, headers: _headers, body: body).timeout(requestTimeout);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['message'] ?? 'Email resent successfully!';
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to resend verification email.');
      }
    } on TimeoutException {
      throw Exception('Request timed out. Please check your network and try again.');
    } on SocketException {
      throw Exception('Network error. Could not reach server. Is the API running and reachable?');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
}


Future<String> forgotPassword({required String email}) async {
    // CRITICAL: Ensure the baseUrl is using your working IP: http://192.168.1.4:3000/api
    final url = Uri.parse('$baseUrl/forgot-password');

    try {
      final body = jsonEncode({'email': email});
      _debugRequest('POST', url, body);
      final response = await http.post(url, headers: _headers, body: body).timeout(requestTimeout);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['message'] ?? 'Password reset link sent. Check your inbox.';
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to initiate password reset.');
      }
    } on TimeoutException {
      throw Exception('Request timed out. Please check your network and try again.');
    } on SocketException {
      throw Exception('Network error. Could not reach server. Is the API running and reachable?');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
}

  // --- LOGIN FUNCTION (The Verification Gatekeeper) ---
  Future<AuthResponse> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');
    
    final body = jsonEncode({
      'email': email,
      'password': password,
    });

    try {
      _debugRequest('POST', url, body);
      final response = await http.post(url, headers: _headers, body: body).timeout(requestTimeout);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return AuthResponse(
          token: jsonResponse['token'],
          user: User.fromJson(jsonResponse['user']),
          message: jsonResponse['message'] ?? 'Login successful',
        );
      } else if (response.statusCode == 401) {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Authentication failed.');
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Login failed due to server error.');
      }
    } on TimeoutException {
      throw Exception('Request timed out. Please check your network and try again.');
    } on SocketException {
      throw Exception('Network error. Could not reach server. Is the API running and reachable?');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}