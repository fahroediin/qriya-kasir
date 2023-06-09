import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class UpdateRecord extends StatefulWidget {
  const UpdateRecord({Key? key, required this.mekanikKey}) : super(key: key);

  final String mekanikKey;

  @override
  State<UpdateRecord> createState() => _UpdateRecordState();
}

class _UpdateRecordState extends State<UpdateRecord> {
  final TextEditingController idMekanikController = TextEditingController();
  final TextEditingController namaMekanikController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController noHpController = TextEditingController();

  late DatabaseReference dbRef;

  @override
  void initState() {
    super.initState();
    dbRef = FirebaseDatabase.instance.reference().child('mekanik');
    getMekanikData();
  }

  void getMekanikData() async {
    DataSnapshot snapshot = await dbRef.child(widget.mekanikKey).get();

    Map mekanik = snapshot.value as Map;

    idMekanikController.text = mekanik['idMekanik'];
    namaMekanikController.text = mekanik['namaMekanik'];
    alamatController.text = mekanik['alamat'];
    noHpController.text = mekanik['noHp'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Updating record'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 50),
              const Text(
                'Updating data in Firebase Realtime Database',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: idMekanikController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'ID Mekanik',
                  hintText: 'Enter ID Mekanik',
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: namaMekanikController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nama Mekanik',
                  hintText: 'Enter Nama Mekanik',
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: alamatController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Alamat',
                  hintText: 'Enter Alamat',
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: noHpController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'No. HP',
                  hintText: 'Enter No. HP',
                ),
              ),
              const SizedBox(height: 30),
              MaterialButton(
                onPressed: () {
                  Map<String, String> mekanikData = {
                    'idMekanik': idMekanikController.text,
                    'namaMekanik': namaMekanikController.text,
                    'alamat': alamatController.text,
                    'noHp': noHpController.text,
                  };

                  dbRef.child(widget.mekanikKey).update(mekanikData).then((_) {
                    Navigator.pop(context);
                  }).catchError((error) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content: Text('Failed to update record: $error'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  });
                },
                child: const Text('Update Data'),
                color: Colors.blue,
                textColor: Colors.white,
                minWidth: 300,
                height: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
