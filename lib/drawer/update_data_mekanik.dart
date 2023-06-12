import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class UpdateRecord extends StatefulWidget {
  const UpdateRecord({Key? key, required this.mekanikKey}) : super(key: key);

  final String mekanikKey;

  @override
  State<UpdateRecord> createState() => _UpdateRecordState();
}

class _UpdateRecordState extends State<UpdateRecord> {
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

    namaMekanikController.text = mekanik['namaMekanik'];
    alamatController.text = mekanik['alamat'];
    noHpController.text = mekanik['noHp'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Mekanik'),
        backgroundColor: Color.fromARGB(255, 219, 42, 15), // Ubah warna AppBar
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: namaMekanikController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nama Mekanik',
                  hintText: 'Masukkan Nama Mekanik',
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              TextField(
                controller: alamatController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Alamat',
                  hintText: 'Masukkan alamat',
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              TextField(
                controller: noHpController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'No HP',
                  hintText: 'Masukkan nomer hp',
                ),
              ),
              SizedBox(height: 10),
              MaterialButton(
                onPressed: () {
                  Map<String, dynamic> mekanik = {
                    'namaMekanik': namaMekanikController.text,
                    'alamat': alamatController.text,
                    'noHp': noHpController.text,
                  };
                  dbRef.child(widget.mekanikKey).update(mekanik).then((_) {
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
                color: Color.fromARGB(255, 219, 42, 15),
                textColor: Colors.white,
                minWidth: 500,
                height: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
