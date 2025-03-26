import 'package:flutter/material.dart';
import 'doctor_list_page.dart';

class DoctorSpecialtiesGrid extends StatelessWidget {
  final List<Map<String, dynamic>> specialties = [
    {"name": "General Physician", "icon": Icons.local_hospital},
    {"name": "Dermatology", "icon": Icons.face},
    {"name": "Pediatrics", "icon": Icons.child_care},
    {"name": "Cardiology", "icon": Icons.favorite},
    {"name": "Orthopedics", "icon": Icons.accessibility_new},
    {"name": "More", "icon": Icons.add},
  ];

  @override
  Widget build(BuildContext context) {
    final int crossAxisCount = MediaQuery.of(context).size.width > 600 ? 4 : 3;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: specialties.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (specialties[index]["name"] == "More") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SpecialityMore(),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DoctorListPage(specialty: specialties[index]["name"]),
                  ),
                );
              }
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    specialties[index]["icon"],
                    size: 40,
                    color: Colors.blue,
                  ),
                  SizedBox(height: 8),
                  Text(
                    specialties[index]["name"],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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

class SpecialityMore extends StatefulWidget {
  const SpecialityMore({super.key});

  @override
  State<SpecialityMore> createState() => _SpecialityMoreState();
}

class _SpecialityMoreState extends State<SpecialityMore> {
  List<Map<String, dynamic>> moreSpecialties = [
    {"name": "General Physician", "icon": Icons.local_hospital, "symptoms": "headaches, seizures, multiple sclerosis, etc."},
    {"name": "Dermatology", "icon": Icons.face, "symptoms": "headaches, seizures, multiple sclerosis, etc."},
    {"name": "Pediatrics", "icon": Icons.child_care, "symptoms": "headaches, seizures, multiple sclerosis, etc."},
    {"name": "Cardiology", "icon": Icons.favorite, "symptoms": "headaches, seizures, multiple sclerosis, etc."},
    {"name": "Orthopedics", "icon": Icons.accessibility_new, "symptoms": "headaches, seizures, multiple sclerosis, etc."},
    {"name": "Neurology", "icon": Icons.memory, "symptoms": "headaches, seizures, multiple sclerosis, etc."},
    {"name": "Gastroenterology", "icon": Icons.restaurant, "symptoms": "stomach pain, ulcers, irritable bowel syndrome, etc."},
    {"name": "Endocrinology", "icon": Icons.science, "symptoms": "diabetes, thyroid disorders, hormonal imbalances, etc."},
    {"name": "Rheumatology", "icon": Icons.self_improvement, "symptoms": "arthritis, autoimmune diseases, chronic pain, etc."},
    {"name": "Oncology", "icon": Icons.healing, "symptoms": "cancer symptoms, tumor management, chemotherapy, etc."},
    // Add more specialties as needed
  ];

  late List<Map<String, dynamic>> filteredSpecialties;

  @override
  void initState() {
    super.initState();
    filteredSpecialties = moreSpecialties;
  }

  void _filterSpecialties(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredSpecialties = moreSpecialties;
      } else {
        filteredSpecialties = moreSpecialties
            .where((specialty) => specialty["name"].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("More Specialties")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _filterSpecialties,
              decoration: InputDecoration(
                labelText: "Search for Specialities",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredSpecialties.length,
              itemBuilder: (context, index) {
                return CategoryContainer(category: filteredSpecialties[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryContainer extends StatefulWidget {
  final Map<String, dynamic> category;

  CategoryContainer({required this.category});

  @override
  _CategoryContainerState createState() => _CategoryContainerState();
}

class _CategoryContainerState extends State<CategoryContainer> {
  bool _showSymptoms = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorListPage(specialty: widget.category["name"]),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(widget.category["icon"], size: 40, color: Colors.blue),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.category["name"],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showSymptoms = !_showSymptoms;
                    });
                  },
                  child: Text(
                    _showSymptoms ? "Hide Symptoms" : "Show Symptoms",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            if (_showSymptoms)
              Padding(
                padding: const EdgeInsets.only(left: 50, top: 10),
                child: Text(
                  "Symptoms: ${widget.category["symptoms"]}",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
