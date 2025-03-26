import 'package:flutter/material.dart';
import 'doctor_list_page.dart'; // Import the doctor list page

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  List<String> symptoms = [
    "Fever", "Cough", "Ear Pain", "Throat Infection", "Skin Rash"
  ];
  List<String> filteredSymptoms = [];

  @override
  void initState() {
    super.initState();
    filteredSymptoms = symptoms; // Initialize with all symptoms
  }

  void _filterSymptoms(String query) {
    setState(() {
      filteredSymptoms = symptoms
          .where((symptom) => symptom.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search Symptoms")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search symptoms...",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterSymptoms, // Calls function on text change
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredSymptoms.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredSymptoms[index]),
                  leading: Icon(Icons.local_hospital),
                  onTap: () {
                    // Navigate to DoctorListPage when a symptom is clicked
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DoctorListPage(symptom: filteredSymptoms[index]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
