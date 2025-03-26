import 'package:flutter/material.dart';
import 'package:flutter_application_122/home_page_elements.dart/home_page.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'package:intl/intl.dart';

class DetailsPage extends StatefulWidget {
  DetailsPage();

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  String? _selectedBloodGroup;
  String? _isDonor;
  String? _donorError; // To store the error message

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
  ];
  final List<String> _donorOptions = ['Yes', 'No'];

  /// Function to pick and format date
  void _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  /// Function to show a selection popup
  void _showPopup(
    List<String> options,
    String title,
    Function(String) onSelect,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Center(
            child: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          content: Container(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(options[index]),
                  onTap: () {
                    onSelect(options[index]);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background to pure white
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Enter Your Details',style: TextStyle(color: Colors.white, fontSize: 25),),
        backgroundColor: Color(0xFF0D47b7),
        toolbarHeight: 75,
        
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  filled: true,
                  fillColor: Colors.white, // Set textfield background to white
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.black), // Black border
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.black), // Black border
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.black,
                      width: 2,
                    ), // Black border
                  ),
                ),
                validator:
                    (value) => value!.isEmpty ? 'Please enter your name' : null,
              ),
              SizedBox(height: 16),

              /// Date of Birth Picker
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dobController,
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      filled: true,
                      fillColor:
                          Colors.white, // Set textfield background to white
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.black,
                        ), // Black border
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.black,
                        ), // Black border
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 2,
                        ), // Black border
                      ),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    validator:
                        (value) =>
                            value!.isEmpty
                                ? 'Please select your date of birth'
                                : null,
                  ),
                ),
              ),
              SizedBox(height: 16),

              /// Blood Group Picker
              GestureDetector(
                onTap:
                    () => _showPopup(_bloodGroups, 'Select Blood Group', (
                      selected,
                    ) {
                      setState(() {
                        _selectedBloodGroup = selected;
                      });
                    }),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black), // Black border
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedBloodGroup ?? 'Select Blood Group',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              /// District Field
              TextFormField(
                controller: _districtController,
                decoration: InputDecoration(
                  labelText: 'District',
                  filled: true,
                  fillColor: Colors.white, // Set textfield background to white
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.black), // Black border
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.black), // Black border
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.black,
                      width: 2,
                    ), // Black border
                  ),
                ),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Please enter your district' : null,
              ),
              SizedBox(height: 16),

              /// Blood Donation Interest Picker
              GestureDetector(
                onTap:
                    () => _showPopup(
                      _donorOptions,
                      'Are you interested in Blood Donation?',
                      (selected) {
                        setState(() {
                          _isDonor = selected;
                          _donorError = null; // Clear the error when selected
                        });
                      },
                    ),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _donorError != null ? Colors.red : Colors.black,
                    ), // Black border
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white, // Set background to white
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isDonor ?? 'Are you interested in Blood Donation?',
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              _donorError != null ? Colors.red : Colors.black,
                        ),
                      ),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),

              /// Error message below Blood Donation field (if not selected)
              if (_donorError != null)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    _donorError!,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),

              SizedBox(height: 24),

              /// Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (_isDonor == null) {
                        setState(() {
                          _donorError = "Please select Yes or No";
                        });
                        return;
                      }

                      final userProvider = Provider.of<UserProvider>(
                        context,
                        listen: false,
                      );
                      await userProvider.registerUser(
                        _nameController.text.trim(),
                        userProvider.phone ?? "",
                        DateFormat(
                          'dd/MM/yyyy',
                        ).parse(_dobController.text).toIso8601String(),
                        _districtController.text.trim(),
                        _selectedBloodGroup ?? "",
                        _isDonor == "Yes",
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    }
                  },
                  child: Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
