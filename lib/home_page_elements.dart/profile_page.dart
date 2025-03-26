import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController nameController;
  late TextEditingController dobController;
  late TextEditingController bloodGroupController;
  late TextEditingController districtController;
  
  bool isEditing = false;
  bool isDonor = false;
  int? age;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.fetchUser(); // Fetch user data on load

    nameController = TextEditingController();
    bloodGroupController = TextEditingController();
    districtController = TextEditingController();
    dobController = TextEditingController();

    _loadUserData();
  }

  void _loadUserData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    setState(() {
      nameController.text = userProvider.name;
      bloodGroupController.text = userProvider.bloodGroup;
      districtController.text = userProvider.district;
      isDonor = userProvider.isDonor;

      if (userProvider.dob != null) {
        dobController.text = DateFormat('dd-MM-yyyy').format(userProvider.dob!);
        age = userProvider.age;
      }
    });
  }

  int _calculateAge(DateTime dob) {
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  Future<void> _selectDOB(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        dobController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
        age = _calculateAge(pickedDate);
      });

      Provider.of<UserProvider>(context, listen: false).updateDOB(pickedDate);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    dobController.dispose();
    bloodGroupController.dispose();
    districtController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (userProvider.uid == null) {
      print("❌ UID is null! Unable to update user.");
      return;
    }

    Map<String, dynamic> updates = {
      "name": nameController.text,  // Use controller values
      "dob": dobController.text,
      "bloodGroup": bloodGroupController.text,
      "district": districtController.text,
      "isDonor": isDonor
    };

    await userProvider.updateUser(userProvider.uid!, updates);
    
    setState(() => isEditing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Profile updated successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
                  SizedBox(height: 10),
                  Text(nameController.text, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  if (age != null) Text('$age years old', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                ],
              ),
            ),
            SizedBox(height: 20),

            buildTextField("Name", nameController, (value) {
              Provider.of<UserProvider>(context, listen: false).updateName(value);
            }),

            GestureDetector(
              onTap: isEditing ? () => _selectDOB(context) : null,
              child: AbsorbPointer(child: buildTextField("Date of Birth", dobController, (value) {})),
            ),

            buildTextField("Blood Group", bloodGroupController, (value) {
              Provider.of<UserProvider>(context, listen: false).updateBloodGroup(value);
            }),

            buildTextField("District", districtController, (value) {
              Provider.of<UserProvider>(context, listen: false).updateDistrict(value);
            }),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Interested in Blood Donation", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Switch(
                  value: isDonor,
                  onChanged: isEditing
                      ? (value) {
                          setState(() => isDonor = value);
                          Provider.of<UserProvider>(context, listen: false).updateIsDonor(value);
                        }
                      : null,
                ),
              ],
            ),
            
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () => isEditing ? _saveProfile() : setState(() => isEditing = true),
                child: Text(isEditing ? "Save Changes" : "Edit Profile"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        enabled: isEditing,
        onChanged: isEditing ? onChanged : null,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }
}
