import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'doctor_speciality.dart';
import 'profile_page.dart';
import 'symptom_Category.dart';
import 'search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

@override
void initState() {
  super.initState();
  
  Future.microtask(() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.fetchUser(); // ✅ Runs once without infinite loop
  });
}




  @override
  Widget build(BuildContext context) {
    // Access the user data from the UserProvider
    final userProvider = Provider.of<UserProvider>(context);
    
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white70,
        toolbarHeight: 120,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              child: CircleAvatar(radius: 37),
            ),
            SizedBox(width: 10),
            Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text("Hello,", style: TextStyle(color: Colors.grey, fontSize: 19)),
    
    FutureBuilder(
      future: userProvider.name.isEmpty ? userProvider.fetchUser() : null, // ✅ Avoids redundant API calls
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && userProvider.name.isEmpty) {
          return Text("Loading...", style: TextStyle(fontSize: 24)); 
        }
        return Text(
          userProvider.name.isNotEmpty ? userProvider.name : "Guest",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        );
      },
    ),
  ],
)

          ],
        ),
      ),
      drawer: ClipRRect(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        child: Drawer(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                DrawerHeader(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: CircleAvatar(radius: 40),
                          ),
                          SizedBox(width: 10),
                          Text(
                            userProvider.name.isNotEmpty ? userProvider.name : "Guest",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.person_2_rounded, color: Colors.black),
                  title: Text("Profile", style: TextStyle(color: Colors.black)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings, color: Colors.black),
                  title: Text("My Consultations", style: TextStyle(color: Colors.black)),
                  onTap: () {}, // TODO: Implement consultations
                ),
                ListTile(
                  leading: Icon(Icons.settings, color: Colors.black),
                  title: Text("My Appointments", style: TextStyle(color: Colors.black)),
                  onTap: () {}, // TODO: Implement appointments
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white38, width: 2.0),
              ),
              child: ListTile(
                title: Hero(
                  tag: 'searchTag',
                  child: Material(
                    child: TextField(
                      readOnly: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SearchPage()),
                        );
                      },
                      decoration: InputDecoration(
                        hintText: 'Search for Symptoms..',
                        prefixIcon: Icon(Icons.search, color: Colors.blueGrey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Find Doctors For Your Health Problem',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),

            // Doctor Categories
            SizedBox(height: 300, child: DoctorCategoriesGrid()),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Connect With Top Specialities',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(height: 300, child: DoctorSpecialtiesGrid()),

            // Find a Doctor Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GestureDetector(
                onTap: () {
                  print("Find a Doctor Clicked!");
                },
                child: Container(
                  height: 200,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFF0D47b7),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "Find a Doctor",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GestureDetector(
                onTap: () {
                  print("Find a Doctor Clicked!");
                },
                child: Container(
                  height: 150,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.amberAccent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "All things Men",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 0),
          ],
        ),
      ),
    );
  }
}
