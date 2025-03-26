import 'package:flutter/material.dart';
import 'doctor_profile.dart';

class DoctorListPage extends StatelessWidget {
  final String? symptom;
  final String? specialty;

  DoctorListPage({Key? key, this.symptom, this.specialty}) : super(key: key);

  final Map<String, String> symptomToSpecialty = {
    "Fever": "General Physician",
    "Cold": "General Physician",
    "Cough": "General Physician",
    "Ear Pain": "ENT Specialist",
    "Throat Infection": "ENT Specialist",
    "Skin Rash": "Dermatology",
    "Stomach Pain": "Gastroenterologist",
    "Indigestion": "Gastroenterologist",
    "Women's Health": "Gynecologist",
    "Dental": "Dentist"
  };

  final List<Map<String, String>> doctors = [
    {"doctorId": "1", "name": "Dr. John Doe", "specialty": "General Physician", "contact": "+123456789", "fee": "500"},
    {"doctorId": "2", "name": "Dr. Jane Smith", "specialty": "General Physician", "contact": "+987654321", "fee": "700"},
    {"doctorId": "3", "name": "Dr. Emily Brown", "specialty": "ENT Specialist", "contact": "+555555555", "fee": "600"},
    {"doctorId": "4", "name": "Dr. Alice Green", "specialty": "Dermatology", "contact": "+444444444", "fee": "800"},
    {"doctorId": "5", "name": "Dr. Mark Wilson", "specialty": "Cardiology", "contact": "+333333333", "fee": "1200"},
    {"doctorId": "6", "name": "Dr. Sarah Adams", "specialty": "Gynecologist", "contact": "+666666666", "fee": "900"},
    {"doctorId": "7", "name": "Dr. Kevin Brown", "specialty": "Dentist", "contact": "+777777777", "fee": "500"},
  ];

  @override
  Widget build(BuildContext context) {
    String? resolvedSpecialty = symptomToSpecialty[symptom ?? ""];

    List<Map<String, String>> filteredDoctors = doctors.where((doctor) {
      if (symptom != null) {
        return doctor['specialty'] == resolvedSpecialty;
      } else if (specialty != null) {
        return doctor['specialty'] == specialty;
      }
      return false;
    }).toList();

    String fee = filteredDoctors.isNotEmpty ? filteredDoctors[0]['fee']! : '0';

    return Scaffold(
      appBar: AppBar(title: Text(symptom != null ? "Doctors for $symptom" : "Doctors for $specialty")),
      body: Column(
        children: [
          Expanded(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
              ),
              child: filteredDoctors.isNotEmpty
                  ? ListView.builder(
                      itemCount: filteredDoctors.length,
                      itemBuilder: (context, index) {
                        var doctor = filteredDoctors[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            title: Text(doctor['name']!, style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(doctor['specialty']!),
                            trailing: Text("₹${doctor['fee']}", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DoctorProfilePage(doctorId: doctor['doctorId']!),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        "No doctors available for this specialty.",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('You Will Be Assigned the Best Available Doctors.',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text('- Ensure Proper Internet Connection', style: TextStyle(fontSize: 18)),
                Text('- Choose a Quiet & Well-lit Space', style: TextStyle(fontSize: 18)),
                Text('- Describe Symptoms Clearly', style: TextStyle(fontSize: 18)),
                Text('- Join the Call on Time', style: TextStyle(fontSize: 18)),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.blueAccent, blurRadius: 10, offset: Offset(0, 5))],
                  ),
                  child: MaterialButton(
                    onPressed: () {
                      _showPaymentOptions(context, fee);
                    },
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.payment, color: Colors.white),
                        SizedBox(width: 10),
                        Text("₹$fee | Pay & Consult", style: TextStyle(fontSize: 18, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Payment options are secure and simple.",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentOptions(BuildContext context, String fee) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Choose Payment Method", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              _buildPaymentOption(context, "Google Pay", Icons.payment),
              _buildPaymentOption(context, "Paytm", Icons.payment),
              _buildPaymentOption(context, "Amazon Pay", Icons.payment),
              _buildPaymentOption(context, "Enter UPI ID", Icons.account_balance),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentOption(BuildContext context, String method, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(method, style: TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.pop(context);
        _showPaymentConfirmation(context, method);
      },
    );
  }

  void _showPaymentConfirmation(BuildContext context, String method) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Payment Confirmation"),
          content: Text("You have selected $method. Please follow the instructions to complete the payment."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showPaymentSuccess(context);
              },
              child: Text("Proceed"),
            ),
          ],
        );
      },
    );
  }

  void _showPaymentSuccess(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Payment Successful"),
          content: Text("Your payment was successful. Please proceed with your consultation."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
