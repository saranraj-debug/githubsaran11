import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../services/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();
  TextEditingController _dobController = TextEditingController();

  IO.Socket? _socket; // Nullable WebSocket
  String? _jwtToken;
  bool isRegistering = false;
  String? _uid;
  String _name = "";
  String? _phone;
  DateTime? _dob;
  int _age = 0;
  String _bloodGroup = "";
  String _district = "";
  bool _isDonor = false;
  Map<String, bool> _doctorAvailability = {};

  // Getters
  Map<String, bool> get doctorAvailability => _doctorAvailability;
  String? get uid => _uid;
  String get name => _name;
  String? get phone => _phone;
  DateTime? get dob => _dob;
  int get age => _age;
  String get bloodGroup => _bloodGroup;
  String get district => _district;
  bool get isDonor => _isDonor;
  String? get jwtToken => _jwtToken;

  @override
  void dispose() {
    _dobController.dispose();
    if (_socket != null && _socket!.connected) {
      _socket!.disconnect();
    }
    super.dispose();
  }

  // Connect to WebSocket with JWT
  void connectToSocket() {
    if (_socket != null && _socket!.connected) {
      print("⚠️ Already connected to WebSocket");
      return;
    }

    _socket = IO.io("ws://192.168.192.252:5000", <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 2000,
      'extraHeaders': {
        'Authorization': 'Bearer $_jwtToken', // ✅ Send JWT for authentication
      },
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      print("🔗 Connected to WebSocket with JWT");
    });

    _socket!.on("update_availability", (data) {
      String doctorId = data["doctorId"];
      bool isAvailable = data["isAvailable"];
      print("🟢 Doctor $doctorId availability: $isAvailable");

      _doctorAvailability[doctorId] = isAvailable;
      notifyListeners();
    });

    _socket!.onDisconnect((_) {
      print("❌ Disconnected from WebSocket");
    });

    _socket!.onError((error) {
      print("⚠️ WebSocket Error: $error");
    });
  }

  // Setters & State Updates
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
    if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  void saveToken(String token) {
    _jwtToken = token;
    notifyListeners();
  }

  String? getToken() {
    return _jwtToken;
  }

  // User Authentication
  Future<bool> loginUser(String phone) async {
    bool success = await _userService.loginUser(phone);
    if (success) {
      _jwtToken = await _userService.getToken();
      notifyListeners();
    }
    return success;
  }

  // Fetch User Details
  Future<void> fetchUser() async {
    if (_phone == null) return;
    _jwtToken = await _userService.getToken();
    final userData = await _userService.fetchUser(_phone!);
    if (userData != null) {
      _name = userData['name'] ?? "";
      _phone = userData['phone'];
      _bloodGroup = userData['bloodGroup'] ?? "";
      _district = userData['district'] ?? "";
      _isDonor = userData['isDonor'] ?? false;
      if (userData['dob'] != null) {
        try {
          _dob = DateTime.parse(userData['dob'].replaceAll("/", "-"));
          _dobController.text = DateFormat('dd/MM/yyyy').format(_dob!);
        } catch (e) {
          _dob = null;
        }
      }
      _uid = userData['_id']?.toString() ?? "";
      _age = _dob != null ? _calculateAge(_dob!) : 0;
      notifyListeners();
    }
  }

  // Update User Details
  Future<void> updateUser(String phone, Map<String, dynamic> updates) async {
    if (_phone == null) return;
    bool success = await _userService.updateUser(_phone!, updates);
    if (success) notifyListeners();
  }

  // Register User
  Future<void> registerUser(String name, String phone, String dob, String district, String bloodGroup, bool isDonor) async {
    if (isRegistering) return;

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
      _name = name;
      _phone = phone;
      _dob = DateFormat('yyyy-MM-dd').parse(dob);
      _district = district;
      _bloodGroup = bloodGroup;
      _isDonor = isDonor;
      _age = _calculateAge(_dob);
      _dobController.text = DateFormat('dd/MM/yyyy').format(_dob!);
      notifyListeners();
    }

    isRegistering = false;
    notifyListeners();
  }
}
