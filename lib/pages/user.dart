import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late DatabaseReference userReference;

  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  String selectedRole = 'Owner';
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    userReference = FirebaseDatabase.instance.reference().child('user');
    getUserData();
  }

  void getUserData() {
    userReference.onValue.listen((event) {
      if (event.snapshot.value != null) {
        var userData = event.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          nameController.text = userData['name'];
          selectedRole = userData['role'];
          addressController.text = userData['address'];
        });
      }
    });
  }

  void saveData() {
    String name = nameController.text;
    String address = addressController.text;

    userReference.set({
      'name': name,
      'role': selectedRole,
      'address': address,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data saved successfully')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save data')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('User Page'),
        ),
        body: ListView(padding: EdgeInsets.all(16), children: [
          CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: AssetImage('assets/airamotor.png'),
            radius: 40,
          ),
          SizedBox(width: 16),
          Row(children: [
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 5),
                    Text(
                      nameController.text,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      selectedRole,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 5),
                    Text(
                      addressController.text,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                setState(() {
                  isEditing = true;
                });
              },
            ),
          ]),
          Divider(),
          SizedBox(height: 16),
          Text(
            'Name',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter your name',
            ),
            enabled: isEditing,
          ),
          SizedBox(height: 16),
          Text(
            'Role',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedRole,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Select role',
            ),
            items: ['Owner', 'Cashier'].map((String role) {
              return DropdownMenuItem<String>(
                value: role,
                child: Text(role),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                selectedRole = value!;
              });
            },
          ),
          SizedBox(height: 16),
          Text(
            'Address',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: addressController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter your address',
            ),
            enabled: isEditing,
          ),
          ElevatedButton(
            onPressed: saveData,
            child: Text('Save'),
            // Disable the button if not in editing mode
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.resolveWith<Color>((states) {
                return isEditing ? Colors.blue : Colors.grey;
              }),
            ),
          ),
        ]));
  }
}
