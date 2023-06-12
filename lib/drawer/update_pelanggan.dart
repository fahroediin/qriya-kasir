import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class UpdatePelanggan extends StatefulWidget {
  final String pelangganKey;

  const UpdatePelanggan({Key? key, required this.pelangganKey})
      : super(key: key);

  @override
  _UpdatePelangganState createState() => _UpdatePelangganState();
}

class _UpdatePelangganState extends State<UpdatePelanggan> {
  final TextEditingController nopolController = TextEditingController();
  final TextEditingController merkSpmController = TextEditingController();
  final TextEditingController tipeSpmController = TextEditingController();
  final TextEditingController namaPelangganController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController noHpController = TextEditingController();

  late DatabaseReference dbRef;

  @override
  void initState() {
    super.initState();
    dbRef = FirebaseDatabase.instance.reference().child('daftarPelanggan');
    getPelangganData();
  }

  void getPelangganData() async {
    DataSnapshot snapshot = await dbRef.child(widget.pelangganKey).get();
    Map pelanggan = snapshot.value as Map;

    nopolController.text = pelanggan['nopol'];
    merkSpmController.text = pelanggan['merkSpm'];
    tipeSpmController.text = pelanggan['tipeSpm'];
    namaPelangganController.text = pelanggan['namaPelanggan'];
    alamatController.text = pelanggan['alamat'];
    noHpController.text = pelanggan['noHp'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Pelanggan'),
        backgroundColor:
            Color.fromARGB(255, 219, 42, 15), // Change AppBar color
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: nopolController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nomor Polisi',
                  hintText: 'Masukkan Nomor Polisi',
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              TextField(
                controller: merkSpmController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Merk SPM',
                  hintText: 'Masukkan Merk SPM',
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              TextField(
                controller: tipeSpmController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Tipe SPM',
                  hintText: 'Masukkan Tipe SPM',
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              TextField(
                controller: namaPelangganController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nama Pelanggan',
                  hintText: 'Masukkan Nama Pelanggan',
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              TextField(
                controller: alamatController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Alamat',
                  hintText: 'Masukkan Alamat',
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              TextField(
                controller: noHpController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nomor HP',
                  hintText: 'Masukkan Nomor HP',
                ),
              ),
              SizedBox(height: 10),
              MaterialButton(
                onPressed: () {
                  Map<String, dynamic> pelanggan = {
                    'nopol': nopolController.text,
                    'merkSpm': merkSpmController.text,
                    'tipeSpm': tipeSpmController.text,
                    'namaPelanggan': namaPelangganController.text,
                    'alamat': alamatController.text,
                    'noHp': noHpController.text,
                  };

                  dbRef.child(widget.pelangganKey).update(pelanggan).then((_) {
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
