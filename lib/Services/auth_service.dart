import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../Models/user_model.dart';
import '../Models/machine_model.dart';

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
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };
  
  String? _authToken;

  // Helpful debug logger for outgoing requests
  void _debugRequest(String method, Uri url, [String? body, Map<String, String>? headers]) {
    // Use print so it's visible in Flutter debug console
    print('HTTP $method -> $url');
    if (headers != null) {
      print('Headers: $headers');
    }
    if (body != null) print('Body: $body');
  }

  // Set authentication token
  void setAuthToken(String token) {
    _authToken = token;
    print('Token received: $token');
  }

  // Clear authentication token
  void clearAuthToken() {
    _authToken = null;
  }

  // Check if user is authenticated
  bool isAuthenticated() {
    return _authToken != null;
  }

  // Get headers with authentication if token is available
  Map<String, String> _getAuthHeaders() {
    final headers = Map<String, String>.from(_headers);
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
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
        final authResponse = AuthResponse(
          token: jsonResponse['token'],
          user: User.fromJson(jsonResponse['user']),
          message: jsonResponse['message'] ?? 'Login successful',
        );
        // Store the token for authenticated requests
        setAuthToken(authResponse.token);
        return authResponse;
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

  // --- MACHINE MANAGEMENT FUNCTIONS ---
  
  // Add new machine
  Future<MachineResponse> addMachine({
    required String machineId,
    required String machineModel,
    required String machineType,
  }) async {
    if (!isAuthenticated()) {
      throw Exception('User not authenticated. Please log in first.');
    }

    final url = Uri.parse('$baseUrl/machines');
    
    final body = jsonEncode({
      'machineId': machineId,
      'machineModel': machineModel,
      'MachineType': machineType, // Match backend field name
    });

    try {
      final headers = _getAuthHeaders();
      _debugRequest('POST', url, body, headers);
      final response = await http.post(url, headers: headers, body: body).timeout(requestTimeout);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return MachineResponse.fromJson(jsonResponse);
      } else if (response.statusCode == 400) {
        // Bad request - validation errors
        final errorBody = jsonDecode(response.body);
        throw Exception('Validation error: ${errorBody['message'] ?? 'Invalid machine data'}');
      } else if (response.statusCode == 401) {
        // Unauthorized
        throw Exception('Authentication failed. Please log in again.');
      } else if (response.statusCode == 403) {
        // Forbidden
        throw Exception('Access denied. You may not have permission to add machines.');
      } else if (response.statusCode == 409) {
        // Conflict - duplicate entry
        throw Exception('Machine with this ID already exists. Please use a different machine ID.');
      } else if (response.statusCode == 500) {
        // Server error - provide more helpful message
        final errorBody = jsonDecode(response.body);
        throw Exception('Server error: ${errorBody['message'] ?? 'Unknown server error'}. Please check server logs or contact administrator.');
      } else {
        // Other errors
        String errorMessage;
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? 'Failed to add machine.';
        } catch (e) {
          errorMessage = 'Server returned: ${response.body}';
        }
        throw Exception('HTTP ${response.statusCode}: $errorMessage');
      }
    } on TimeoutException {
      throw Exception('Request timed out. Please check your network and try again.');
    } on SocketException {
      throw Exception('Network error. Could not reach server. Is the API running and reachable?');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Get all machines
  Future<List<Machine>> getAllMachines() async {
    if (!isAuthenticated()) {
      throw Exception('User not authenticated. Please log in first.');
    }

    final url = Uri.parse('$baseUrl/machines');

    try {
      final headers = _getAuthHeaders();
      _debugRequest('GET', url, null, headers);
      final response = await http.get(url, headers: headers).timeout(requestTimeout);
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        // Handle different response formats
        List<dynamic> machinesJson;
        if (jsonResponse is List) {
          machinesJson = jsonResponse;
        } else if (jsonResponse['machines'] != null) {
          machinesJson = jsonResponse['machines'];
        } else {
          throw Exception('Unexpected response format');
        }
        
        return machinesJson.map((json) => Machine.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      } else if (response.statusCode == 403) {
        throw Exception('Access denied. You may not have permission to view machines.');
      } else {
        String errorMessage;
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? 'Failed to fetch machines.';
        } catch (e) {
          errorMessage = 'Server returned: ${response.body}';
        }
        throw Exception('HTTP ${response.statusCode}: $errorMessage');
      }
    } on TimeoutException {
      throw Exception('Request timed out. Please check your network and try again.');
    } on SocketException {
      throw Exception('Network error. Could not reach server. Is the API running and reachable?');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Get all technician users (endpoint: /alltechusers)
  Future<List<User>> getTechnicians() async {
    final url = Uri.parse('$baseUrl/alltechusers');

    try {
      final headers = _getAuthHeaders();
      _debugRequest('GET', url, null, headers);
      final response = await http.get(url, headers: headers).timeout(requestTimeout);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        List<dynamic> usersJson;
        if (jsonResponse is List) {
          usersJson = jsonResponse;
        } else if (jsonResponse['users'] != null) {
          usersJson = jsonResponse['users'];
        } else {
          throw Exception('Unexpected response format when fetching technicians');
        }

        return usersJson.map((u) => User.fromJson(u)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      } else {
        String errorMessage;
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? 'Failed to fetch technicians.';
        } catch (e) {
          errorMessage = 'Server returned: ${response.body}';
        }
        throw Exception('HTTP ${response.statusCode}: $errorMessage');
      }
    } on TimeoutException {
      throw Exception('Request timed out. Please check your network and try again.');
    } on SocketException {
      throw Exception('Network error. Could not reach server. Is the API running and reachable?');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Get machine by ID
  Future<Machine> getMachineById(String machineId) async {
    if (!isAuthenticated()) {
      throw Exception('User not authenticated. Please log in first.');
    }

    final url = Uri.parse('$baseUrl/machines/$machineId');

    try {
      final headers = _getAuthHeaders();
      _debugRequest('GET', url, null, headers);
      final response = await http.get(url, headers: headers).timeout(requestTimeout);
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return Machine.fromJson(jsonResponse);
      } else if (response.statusCode == 404) {
        throw Exception('Machine not found');
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      } else if (response.statusCode == 403) {
        throw Exception('Access denied. You may not have permission to view this machine.');
      } else {
        String errorMessage;
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? 'Failed to fetch machine details.';
        } catch (e) {
          errorMessage = 'Server returned: ${response.body}';
        }
        throw Exception('HTTP ${response.statusCode}: $errorMessage');
      }
    } on TimeoutException {
      throw Exception('Request timed out. Please check your network and try again.');
    } on SocketException {
      throw Exception('Network error. Could not reach server. Is the API running and reachable?');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Get personal information
  Future<User> getPersonalInfo() async {
    if (!isAuthenticated()) {
      throw Exception('User not authenticated. Please log in first.');
    }

    final url = Uri.parse('$baseUrl/personalinfo');

    try {
      final headers = _getAuthHeaders();
      _debugRequest('GET', url, null, headers);
      final response = await http.get(url, headers: headers).timeout(requestTimeout);
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return User.fromJson(jsonResponse['user']);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed or account not verified. Please log in again.');
      } else if (response.statusCode == 404) {
        throw Exception('User not found.');
      } else {
        String errorMessage;
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? 'Failed to fetch personal information.';
        } catch (e) {
          errorMessage = 'Server returned: ${response.body}';
        }
        throw Exception('HTTP ${response.statusCode}: $errorMessage');
      }
    } on TimeoutException {
      throw Exception('Request timed out. Please check your network and try again.');
    } on SocketException {
      throw Exception('Network error. Could not reach server. Is the API running and reachable?');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Change password
  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    if (!isAuthenticated()) {
      throw Exception('User not authenticated. Please log in first.');
    }

    final url = Uri.parse('$baseUrl/change-password');
    
    final body = jsonEncode({
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      'confirmNewPassword': confirmNewPassword,
    });

    try {
      final headers = _getAuthHeaders();
      _debugRequest('POST', url, body, headers);
      final response = await http.post(url, headers: headers, body: body).timeout(requestTimeout);
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['message'] ?? 'Password changed successfully.';
      } else if (response.statusCode == 400) {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Invalid password data.');
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed or account not verified. Please log in again.');
      } else if (response.statusCode == 404) {
        throw Exception('User not found.');
      } else {
        String errorMessage;
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? 'Failed to change password.';
        } catch (e) {
          errorMessage = 'Server returned: ${response.body}';
        }
        throw Exception('HTTP ${response.statusCode}: $errorMessage');
      }
    } on TimeoutException {
      throw Exception('Request timed out. Please check your network and try again.');
    } on SocketException {
      throw Exception('Network error. Could not reach server. Is the API running and reachable?');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Logout user
  Future<String> logout() async {
    if (!isAuthenticated()) {
      throw Exception('User not authenticated.');
    }

    final url = Uri.parse('$baseUrl/logout');

    try {
      final headers = _getAuthHeaders();
      _debugRequest('GET', url, null, headers);
      final response = await http.get(url, headers: headers).timeout(requestTimeout);
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        // Clear the stored auth token after successful logout
        clearAuthToken();
        return jsonResponse['message'] ?? 'Logout successful.';
      } else {
        String errorMessage;
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? 'Failed to logout.';
        } catch (e) {
          errorMessage = 'Server returned: ${response.body}';
        }
        // Even if logout fails on server, clear local token
        clearAuthToken();
        throw Exception('HTTP ${response.statusCode}: $errorMessage');
      }
    } on TimeoutException {
      // Clear token even on timeout
      clearAuthToken();
      throw Exception('Request timed out. Please check your network and try again.');
    } on SocketException {
      // Clear token even on network error
      clearAuthToken();
      throw Exception('Network error. Could not reach server. Is the API running and reachable?');
    } catch (e) {
      // Clear token on any error to ensure user is logged out locally
      clearAuthToken();
      throw Exception('Unexpected error: $e');
    }
  }

  // Create a new failure report
  Future<String> createFailureReport({
    required String machineName,
    required String machineType,
    required String machineId,
    required String description,
    required String assignedTo, // user id
    required String severity, // low | medium | critical
    required String assignedBy, // current user id
  }) async {
    if (!isAuthenticated()) {
      throw Exception('User not authenticated. Please log in first.');
    }

    final url = Uri.parse('$baseUrl/failures');
    final failureId = 'FAIL-${DateTime.now().millisecondsSinceEpoch}';
    final payload = {
      // Backend expects machineId lowercase for Machines.findById
      'machineId': machineId,

      // Duplicate common fields in both cases to be safe with schema
      'machineName': machineName,
      'MachineName': machineName,
      'machineType': machineType,
      'MachineType': machineType,

      // Required fields per validation error (capitalized)
      'Description': description,
      'AssignedTo': assignedTo,
      'ReportedBy': assignedBy,
      'failureId': failureId,

      // Severity (send both just in case)
      'severity': severity,
      'Severity': severity,
    };
    final body = jsonEncode(payload);

    try {
      final headers = _getAuthHeaders();
      _debugRequest('POST', url, body, headers);
      final response = await http.post(url, headers: headers, body: body).timeout(requestTimeout);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['message'] ?? 'Failure created successfully';
      } else if (response.statusCode == 404) {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Machine not found');
      } else if (response.statusCode == 400) {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Invalid failure data');
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please log in again.');
      } else {
        String errorMessage;
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? 'Failed to create failure.';
        } catch (_) {
          errorMessage = 'Server returned: ${response.body}';
        }
        throw Exception('HTTP ${response.statusCode}: $errorMessage');
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