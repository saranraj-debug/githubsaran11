import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class UserService {
  final String apiUrl = "http://10.0.2.2:5000/api/users";
  final FlutterSecureStorage storage =
      FlutterSecureStorage(); // Secure Storage instance

  Future<void> saveToken(String token) async {
    try {
      print("📌 Attempting to save token: $token");
      await storage.write(key: "jwt_token", value: token);
      print("✅ Token successfully saved!");
    } catch (e) {
      print("❌ Error saving token: $e");
    }
  }

  Future<String?> getToken() async {
    try {
      String? token = await storage.read(key: "jwt_token");
      print("🔍 Retrieved token: $token");
      return token;
    } catch (e) {
      print("❌ Error retrieving token: $e");
      return null;
    }
  }

  Future<void> debugTokenStorage() async {
    String? token = await getToken();
    if (token == null || token.isEmpty) {
      print("❌ No JWT token found in storage!");
    } else {
      print("🔍 Retrieved JWT Token: $token");
    }
  }

  // ✅ Delete Token on Logout
  Future<void> deleteToken() async {
    await storage.delete(key: "jwt_token");
    print("🗑️ Token deleted!");
  }

  // ✅ Login User and get JWT token
  Future<bool> loginUser(String phone) async {
    print("📌 loginUser() called with phone: $phone"); // 🔍 Debugging

    final response = await http.post(
      Uri.parse("$apiUrl/login"),
      body: json.encode({"phone": phone}),
      headers: {"Content-Type": "application/json"},
    );

    print("📥 Full Login API Response: ${response.body}"); // 🔍 Debugging

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      if (responseData.containsKey("token") && responseData["token"] != null) {
        String token = responseData["token"];
        print("✅ Token received: $token");

        await saveToken(token); // Store the token securely
        return true;
      } else {
        print("❌ Token key missing in API response!");
        return false;
      }
    } else {
      print("❌ Login failed with status code: ${response.statusCode}");
      return false;
    }
  }

  // ✅ Background isolate for JSON parsing
  Map<String, dynamic> parseJson(String responseBody) {
    return jsonDecode(responseBody);
  }

  // ✅ Fetch user details by phone
  Future<Map<String, dynamic>?> fetchUser(String phone) async {
    final String apiurl = "http://10.0.2.2:5000/api/users/user";
    String? token = await getToken(); // Get token from secure storage

    if (token == null) {
      print("❌ Cannot fetch user, JWT token is missing!");
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse("$apiurl/$phone"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("📡 API Response Code: ${response.statusCode}");
      print("📡 API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return compute(parseJson, response.body); // ✅ Offload JSON parsing
      } else {
        print("❌ Error fetching user: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ Exception fetching user: $e");
      return null;
    }
  }

  // ✅ Update User Details
  Future<bool> updateUser(String phone, Map<String, dynamic> updates) async {
    String? token = await getToken(); // Get token from secure storage

    if (token == null) {
      print("❌ Cannot update user, JWT token is missing!");
      return false;
    }

    try {
      // ✅ Offload JSON encoding to background
      String encodedBody = await compute(encodeJson, updates);

      final response = await http.put(
        Uri.parse(
          "http://10.0.2.2:5000/api/users/update/$phone",
        ), // ✅ Use phone instead of UID
        headers: {
          "Authorization": "Bearer $token", // Ensure authentication
          "Content-Type": "application/json",
        },
        body: encodedBody,
      );

      print(
        "📡 Update User Response: ${response.statusCode} - ${response.body}",
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("❌ Failed to update user: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Exception updating user: $e");
      return false;
    }
  }

  // ✅ Background isolate for JSON encoding
  String encodeJson(Map<String, dynamic> data) {
    return jsonEncode(data);
  }

  // ✅ Register User
  Future<bool> registerUser(Map<String, dynamic> userData) async {
    try {
      // ✅ Offload JSON encoding to background isolate
      String encodedBody = await compute(encodeJson, userData);

      final response = await http.post(
        Uri.parse("$apiUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: encodedBody,
      );

      print("📡 API Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        print("❌ Registration failed. Response: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Exception in registerUser: $e");
      return false;
    }
  }

  // ✅ Logout User (Delete JWT Token)
  Future<void> logout() async {
    await deleteToken();
    print("🔒 User logged out successfully!");
  }
}
