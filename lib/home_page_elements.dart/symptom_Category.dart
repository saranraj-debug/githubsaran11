import 'package:flutter/material.dart';
import 'package:flutter_application_122/home_page_elements.dart/search_page.dart';

import 'doctor_list_page.dart';

class DoctorCategoriesGrid extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {"icon": Icons.thermostat, "label": "Fever", "color": Colors.blue},
    {"icon": Icons.ac_unit, "label": "Cold", "color": Colors.pink},
    {"icon": Icons.pregnant_woman, "label": "Women's Health", "color": Colors.purple},
    {"icon": Icons.medical_services, "label": "Dental", "color": Colors.orange},
    {"icon": Icons.child_care, "label": "Cough", "color": Colors.green},
    {"icon": Icons.add, "label": "More", "color": Colors.teal},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        shrinkWrap: true, // Prevents unnecessary scrolling issues
        physics: NeverScrollableScrollPhysics(), // Prevents nested scrolling conflicts
        itemCount: categories.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1, // Keeps items square
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (categories[index]["label"] == "More") {
                // Navigate to a different page when "More" is clicked
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchPage(), // Replace with your actual page
                  ),
                );
              } else {
                // Ensure passing the symptom label correctly
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DoctorListPage(symptom: categories[index]["label"]),
                  ),
                );
              }
            },
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(categories[index]["icon"], size: 35, color: categories[index]["color"]),
                  SizedBox(height: 10),
                  Text(
                    categories[index]["label"],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}