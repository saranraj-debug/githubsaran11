import 'package:flutter/material.dart';

class DoctorProfilePage extends StatelessWidget {
  final String doctorId; // Unique identifier for the doctor

  const DoctorProfilePage({Key? key, required this.doctorId}) : super(key: key);

  // Simulating API response for doctor details
  Future<Map<String, String>> fetchDoctorDetails() async {
    // In real scenario, fetch the data from API using doctorId.
    // Here we use some dummy data for simulation.
    await Future.delayed(Duration(seconds: 2));  // Simulating network delay
    
    return {
      // URL to doctor photo
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Doctor Profile")),
      body: FutureBuilder<Map<String, String>>(
        future: fetchDoctorDetails(),  // Fetch doctor details
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading doctor details'));
          }

          if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          }

          final doctorDetails = snapshot.data!;
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor photo
                Center(
                  child: CircleAvatar(
                    radius: 80,
                    
                  ),
                ),
                SizedBox(height: 20),
                // Doctor name and specialty
                Text(
                  doctorDetails['name']!,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  doctorDetails['specialty']!,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 20),
                // Number of patients attended
                Text(
                  "Patients Attended: ${doctorDetails['patientsAttended']}",
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                // Availability
                Text(
                  "Availability: ${doctorDetails['availability']}",
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
