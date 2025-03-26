import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();
  TextEditingController _dobController = TextEditingController();

  @override
  void dispose() {
    _dobController.dispose();
    super.dispose();
  }

  bool isRegistering = false;
  String? _uid;
  String _name = "";
  String? _phone;
  DateTime? _dob;
  int _age = 0;
  String _bloodGroup = "";
  String _district = "";
  bool _isDonor = false;
  String? _jwtToken; // 🔹 Store JWT token

  String? get uid => _uid;
  String get name => _name;
  String? get phone => _phone;
  DateTime? get dob => _dob;
  int get age => _age;
  String get bloodGroup => _bloodGroup;
  String get district => _district;
  bool get isDonor => _isDonor;
  String? get jwtToken => _jwtToken; // 🔹 Getter for token

  void setPhone(String phone) {
    _phone = phone;
    notifyListeners();
  }

  void updateName(String newName) {
    _name = newName;
    notifyListeners();
  }

  void updateDistrict(String newDistrict) {
    _district = newDistrict;
    notifyListeners();
  }

  void updateIsDonor(bool value) {
    _isDonor = value;
    notifyListeners();
  }

  void updateBloodGroup(String newBloodGroup) {
    _bloodGroup = newBloodGroup;
    notifyListeners();
  }

  void updateDOB(DateTime newDob) {
    _dob = newDob;
    _age = _calculateAge(newDob);
    _dobController.text = DateFormat('dd/MM/yyyy').format(newDob);
    notifyListeners();
  }

  int _calculateAge(DateTime? dob) {
    if (dob == null) return 0;
    DateTime today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day))
      age--;
    return age;
  }

  //! ✅ Store JWT Token
  void saveToken(String token) {
    _jwtToken = token;
   
    notifyListeners();
  }

  // ✅ Function to retrieve token
  String? getToken() {
    print("📤 Retrieving JWT Token: $_jwtToken"); // Debug print
    return _jwtToken;
  }

  //! ✅ Login User
Future<bool> loginUser(String phone) async {
  print("📌 loginUser() called in UserProvider with phone: $phone"); // 🔍 Debugging

  bool success = await _userService.loginUser(phone);

  if (success) {
    _jwtToken = await _userService.getToken();
    
    if (_jwtToken == null || _jwtToken!.isEmpty) {
      print("❌ JWT Token is missing after login!");
    } else {
      print("✅ JWT Token successfully set: $_jwtToken");
    }

    notifyListeners();
  } else {
    print("❌ Login failed, no token received!");
  }
  return success;
}


  //! ✅ Fetch User from MongoDB
Future<void> fetchUser() async {
  if (_phone == null) {
    print("❌ No phone number found for user.");
    return;
  }

  _jwtToken = await _userService.getToken();
  print("📤 Fetched JWT Token: $_jwtToken");

  if (_jwtToken == null || _jwtToken!.isEmpty) {
    print("❌ Cannot fetch user, JWT token is missing!");
    return;
  }

  final userData = await _userService.fetchUser(_phone!);
  print("🔍 Full API Response: $userData");

  if (userData != null) {
    _name = userData['name'] ?? "";
    _phone = userData['phone'];
    _bloodGroup = userData['bloodGroup'] ?? "";
    _district = userData['district'] ?? "";
    _isDonor = userData['isDonor'] ?? false;

    if (userData['dob'] != null) {
      try {
        String fixedDob = userData['dob'].replaceAll("/", "-");
        _dob = DateTime.parse(fixedDob);
        _dobController.text = DateFormat('dd/MM/yyyy').format(_dob!);
      } catch (e) {
        print("❌ Error parsing date: $e");
        _dob = null;
      }
    }

    // ✅ Ensure `_uid` is always updated
    if (userData.containsKey('_id') && userData['_id'] != null) {
      _uid = userData['_id'].toString();
      print("✅ Assigned UID: $_uid");
    } else {
      print("❌ No UID found in API response!");
      _uid = ""; // Ensure it's not null
    }

    _age = (_dob != null ? _calculateAge(_dob!) : 0);
    notifyListeners(); // ✅ Notify UI after updating user data
  } else {
    print("⚠️ No user data found in fetchUser.");
  }
}



  //! ✅ Update User
  Future<void> updateUser(String phone, Map<String, dynamic> updates) async {
  if (_phone == null) {
    print("❌ Cannot update, phone is null");
    return;
  }

  bool success = await _userService.updateUser(_phone!, updates);
  if (success) notifyListeners();
}


  //! ✅ Register User
  Future<void> registerUser(
    String name,
    String phone,
    String dob,
    String district,
    String bloodGroup,
    bool isDonor,
  ) async {
    if (isRegistering) {
      print("⚠️ Already registering, skipping duplicate request...");
      return;
    }

    isRegistering = true;
    notifyListeners();

    Map<String, dynamic> userData = {
      "name": name,
      "phone": phone,
      "dob": dob,
      "district": district,
      "bloodGroup": bloodGroup,
      "isDonor": isDonor,
    };

    bool success = await _userService.registerUser(userData);
    if (success) {
      print("✅ Registered successfully, fetching user...");
      _name = name;
      _phone = phone;
      _dob = DateFormat('yyyy-MM-dd').parse(dob);
      _district = district;
      _bloodGroup = bloodGroup;
      _isDonor = isDonor;
      _age = _calculateAge(_dob);
      _dobController.text = DateFormat('dd/MM/yyyy').format(_dob!);
      notifyListeners();
    } else {
      print("❌ Registration failed, check API response.");
    }

    isRegistering = false;
    notifyListeners();
  }
}
