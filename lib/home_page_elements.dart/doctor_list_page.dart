import 'package:flutter/material.dart';
import 'package:flutter_application_122/home_page_elements.dart/videocall.dart' show VideoCallScreen;
import 'package:flutter_application_122/services/socket_service.dart'
    show WebSocketService;
import 'doctor_profile.dart';
import 'dart:async';


class DoctorListPage extends StatefulWidget {
  final String? symptom;
  final String? specialty;

  DoctorListPage({Key? key, this.symptom, this.specialty}) : super(key: key);

  @override
  _DoctorListPageState createState() => _DoctorListPageState();
}

class _DoctorListPageState extends State<DoctorListPage> {
  final WebSocketService _webSocketService = WebSocketService();
  late StreamSubscription<Map<String, bool>> _availabilitySubscription;
  List<Map<String, dynamic>> doctors = [];

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
    "Dental": "Dentist",
  };

  @override
  void initState() {
    super.initState();
    _webSocketService.connectToWebSocket();
    _availabilitySubscription = _webSocketService.availabilityStream.listen((
      data,
    ) {
      setState(() {
        doctors.forEach((doctor) {
          if (data.containsKey(doctor['doctorId'])) {
            doctor['isAvailable'] = data[doctor['doctorId']];
          }
        });
      });
    });
  }

  @override
 

  @override
Widget _buildPaymentOption(BuildContext context, String title, IconData icon) {
  return ListTile(
    leading: Icon(icon, color: Colors.blue),
    title: Text(title, style: TextStyle(fontSize: 16)),
    onTap: () {
      Navigator.pop(context);
      print("Selected Payment: $title");
    },
  );
}

@override
Widget build(BuildContext context) {
  String? resolvedSpecialty = widget.symptom != null
      ? symptomToSpecialty[widget.symptom]
      : widget.specialty;

  List<Map<String, dynamic>> filteredDoctors = doctors.where((doctor) {
    return resolvedSpecialty != null && doctor['specialty'] == resolvedSpecialty;
  }).toList();

  String fee = (filteredDoctors.isNotEmpty && filteredDoctors[0]['fee'] != null)
      ? filteredDoctors[0]['fee'].toString()
      : '0';

  return Scaffold(
    appBar: AppBar(
      title: Text(
        widget.symptom != null
            ? "Doctors for ${widget.symptom}"
            : "Doctors for ${widget.specialty}",
      ),
    ),
    body: Column(
      children: [
        Expanded(
          child: StreamBuilder<Map<String, bool>>(
            stream: _webSocketService.availabilityStream,
            builder: (context, snapshot) {
              return Container(
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              title: Text(
                                doctor['name']!,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(doctor['specialty']!),
                              trailing: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "₹${doctor['fee']}",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(
                                    Icons.circle,
                                    color: (doctor['isAvailable'] ?? false)
                                        ? Colors.green
                                        : Colors.red,
                                    size: 12,
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DoctorProfilePage(
                                      doctorId: doctor['doctorId']!,
                                    ),
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
              );
            },
          ),
        ),
        _buildPayAndConsultSection(context, fee),
      ],
    ),
  );
}


  Widget _buildPayAndConsultSection(BuildContext context, String fee) {
  return Padding(
    padding: const EdgeInsets.all(10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'You Will Be Assigned the Best Available Doctors.',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text('- Ensure Proper Internet Connection', style: TextStyle(fontSize: 18)),
        Text('- Choose a Quiet & Well-lit Space', style: TextStyle(fontSize: 18)),
        Text('- Describe Symptoms Clearly', style: TextStyle(fontSize: 18)),
        Text('- Join the Call on Time', style: TextStyle(fontSize: 18)),
        SizedBox(height: 20),

        // Payment Button
        Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
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
                Text(
                  "₹$fee | Pay & Consult",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 10),
        Text(
          "Payment options are secure and simple.",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.grey),
        ),

        SizedBox(height: 20),

        // **New Video Call Button**
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoCallScreen(
                    channelName: "video_consult_001", // Replace with actual channel name
                    uid: DateTime.now().millisecondsSinceEpoch.remainder(100000),  
 // Replace with actual user ID
                    token: "007eJxTYBBd3bnONfz2tA/z6p9FHEl4HPh3YfKaLa4h80/LrWjtEAlSYEhNsTBJNjFJMjEFkinJyUnJScaGFoaJialGlhYGqUnrjJ+nNwQyMsRf4mJhZIBAEF+QoSwzJTU/Pjk/r7g0pyTewMCQgQEA6hkmjw==", // Replace with actual Agora token
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              "Join Video Call",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
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
              Text(
                "Choose Payment Method",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              _buildPaymentOption(context, "Google Pay", Icons.payment),
              _buildPaymentOption(context, "Paytm", Icons.payment),
              _buildPaymentOption(context, "Amazon Pay", Icons.payment),
              _buildPaymentOption(
                context,
                "Enter UPI ID",
                Icons.account_balance,
              ),
            ],
          ),
        );
      },
    );
  }
}
