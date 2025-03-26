/*import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
   
  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController dobController;
  late TextEditingController districtController;
  late TextEditingController addressController;

  bool isEditing = false;
  bool isLoading = true; // Added loading flag

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    ageController = TextEditingController();
    dobController = TextEditingController();
    districtController = TextEditingController();
    addressController = TextEditingController();

    _loadProfileData(); // Load saved data
  }

  // Load saved values from SharedPreferences
  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Only set controllers if data exists
    nameController.text = prefs.getString('name') ?? "";
    ageController.text = prefs.getString('age') ?? "";
    dobController.text = prefs.getString('dob') ?? "";
    districtController.text = prefs.getString('district') ?? "";
    addressController.text = prefs.getString('address') ?? "";

    setState(() {
      isLoading = false; // Data loaded
    });
  }

  // Save data to SharedPreferences
  Future<void> _saveProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', nameController.text);
    await prefs.setString('age', ageController.text);
    await prefs.setString('dob', dobController.text);
    await prefs.setString('district', districtController.text);
    await prefs.setString('address', addressController.text);
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    dobController.dispose();
    districtController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Page"),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // Show loader while fetching data
          : Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileInfo(
                      title: "Name",
                      controller: nameController,
                      isEditing: isEditing),
                  ProfileInfo(
                      title: "Age",
                      controller: ageController,
                      isEditing: isEditing),
                  ProfileInfo(
                      title: "Date of Birth",
                      controller: dobController,
                      isEditing: isEditing),
                  ProfileInfo(
                      title: "District",
                      controller: districtController,
                      isEditing: isEditing),
                  ProfileInfo(
                      title: "Address",
                      controller: addressController,
                      isEditing: isEditing),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        isEditing = !isEditing;
                      });
                      if (!isEditing) {
                        await _saveProfileData(); // Save data when switching back from edit mode
                      }
                    },
                    child: Text(isEditing ? "Save" : "Edit"),
                  ),
                ],
              ),
            ),
    );
  }
}

class ProfileInfo extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final bool isEditing;

  ProfileInfo(
      {required this.title, required this.controller, required this.isEditing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100, // Fixed width for labels
            child: Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: isEditing
                ? TextFormField(
                    controller: controller,
                    decoration: InputDecoration(border: OutlineInputBorder()),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      controller.text,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
*/