import 'package:flutter/material.dart';
import 'package:flutter_application_122/home_page_elements.dart/user_details.dart';
import 'package:flutter_application_122/providers/user_provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class MobileNumberSignin extends StatefulWidget {
  @override
  _MobileNumberSigninState createState() => _MobileNumberSigninState();
}

class _MobileNumberSigninState extends State<MobileNumberSignin> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _validateMobileNumber(String? value) {
    final pattern = r'^[6-9]\d{9}$';
    final regExp = RegExp(pattern);
    if (value == null || value.isEmpty) {
      return 'Please enter your mobile number';
    } else if (!regExp.hasMatch(value)) {
      return 'Please enter a valid Indian mobile number';
    }
    return null;
  }

 Future<void> sendOTP() async {
  if (_formKey.currentState!.validate()) {
    final phoneNumber = _controller.text.trim();
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Store phone number in provider
    userProvider.setPhone(phoneNumber);
    print("✅ Stored Phone in UserProvider: ${userProvider.phone}"); // Debugging

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:5000/api/users/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": phoneNumber}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("✅ OTP Sent Successfully! Now calling loginUser()...");

        bool loginSuccess = await userProvider.loginUser(phoneNumber);

        if (loginSuccess) {
          print("✅ Login successful, JWT token stored!");

          // Debugging - Retrieve token immediately after login
          String? storedToken = await userProvider.getToken();
          print("🔍 Token after login: $storedToken");

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPVerification(phone: phoneNumber),
            ),
          );
        } else {
          print("❌ Login failed, no token received!");
        }
      } else {
        print("❌ Error sending OTP: ${response.body}");
      }
    } catch (e) {
      print("❌ Error in sendOTP(): $e");
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sign In',
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
        backgroundColor: Color(0xFF0D47b7),
        toolbarHeight: 75,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Please enter your mobile number to continue",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _controller,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: 'Enter your mobile number',
                ),
                validator: _validateMobileNumber,
              ),
              SizedBox(height: 16),
              ElevatedButton(onPressed: sendOTP, child: Text('Continue')),
            ],
          ),
        ),
      ),
    );
  }
}

class OTPVerification extends StatefulWidget {
  final String phone;
  OTPVerification({required this.phone});

  @override
  _OTPVerificationState createState() => _OTPVerificationState();
}

class _OTPVerificationState extends State<OTPVerification> {
  final TextEditingController _otpController = TextEditingController();

  Future<void> verifyOtp() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final otp = _otpController.text.trim();

    if (otp.length == 6) {
      try {
        final response = await http.post(
          Uri.parse("http://10.0.2.2:5000/api/users/verify-otp"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"phone": widget.phone, "otp": otp}),
        );

        print("📥 OTP Verification Response: ${response.body}"); // Debugging

        if (response.statusCode == 200) {
          bool loginSuccess = await userProvider.loginUser(widget.phone);

          if (loginSuccess) {
            print("✅ Login successful, JWT token stored!");
            
            // Debugging - Retrieve token immediately after login
            String? storedToken = await userProvider.getToken();
            print("🔍 Token after login: $storedToken");

            if (storedToken != null && storedToken.isNotEmpty) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DetailsPage()),
              );
            } else {
              print("❌ Token storage issue - JWT token missing after login!");
            }
          } else {
            print("❌ Login failed, no token received!");
          }
        } else {
          print("❌ OTP Verification Failed: ${response.body}");
        }
      } catch (e) {
        print("❌ Error verifying OTP: $e");
      }
    } else {
      print("❌ Invalid OTP. Must be 6 digits.");
    }
  }
  void resendOtp() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('OTP Resent!'))); // OTP resend action
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'VERIFY OTP',
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        backgroundColor: Color(0xFF0D47b7),
        toolbarHeight: 75,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Enter the 6-digit OTP sent to your number",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            PinCodeTextField(
              appContext: context,
              length: 6,
              controller: _otpController,
              keyboardType: TextInputType.number,
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(5),
                fieldHeight: 50,
                fieldWidth: 40,
                activeColor: Colors.blue,
                inactiveColor: Colors.grey,
                selectedColor: Colors.blueAccent,
              ),
              onChanged: (value) {}, // OTP input field
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailsPage(),
                  ), // Navigate to details page
                );
              },
              child: Text('Verify OTP'),
            ), // Verify OTP button
            SizedBox(height: 20),
            TextButton(
              onPressed: resendOtp, // Resend OTP action
              child: Text(
                "Resend OTP",
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
