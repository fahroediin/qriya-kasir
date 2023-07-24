import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';

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
  final TextEditingController namaPelangganController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController noHpController = TextEditingController();
  final TextEditingController tipeSpmController = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // Add a GlobalKey for the form
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
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey, // Assign the GlobalKey to the form
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: nopolController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9 ]')),
                      LengthLimitingTextInputFormatter(255),
                    ],
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Wajib diisi';
                      }
                      if (value.length < 3) {
                        return 'Minimal terdiri dari 3 karakter';
                      }
                      return null;
                    },
                    enabled: false,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    controller: merkSpmController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9 ]')),
                      LengthLimitingTextInputFormatter(255),
                    ],
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Wajib diisi';
                      }
                      if (value.length < 3) {
                        return 'Minimal terdiri dari 3 karakter';
                      }
                      return null;
                    },
                    enabled: false,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    controller: tipeSpmController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Contoh NMAX 2022',
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9 ]')),
                      LengthLimitingTextInputFormatter(255),
                    ],
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Wajib diisi';
                      }
                      if (value.length < 3) {
                        return 'Minimal terdiri dari 3 karakter';
                      }
                      return null;
                    },
                    enabled: false,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    controller: namaPelangganController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Nama Pemilik',
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
                      LengthLimitingTextInputFormatter(255),
                    ],
                    textCapitalization: TextCapitalization
                        .words, // Mengubah hanya huruf pertama yang kapital
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Wajib diisi';
                      }
                      if (value.length < 3) {
                        return 'Minimal 3 huruf';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    controller: alamatController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Alamat',
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Z 0-9/]')),
                    ],
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    controller: noHpController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Nomor HP',
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      LengthLimitingTextInputFormatter(13),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Wajib diisi';
                      }
                      if (value.length < 11 || value.length > 13) {
                        return 'Harus terdiri dari 11 hingga 13 digit angka';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  MaterialButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Validate the form using the GlobalKey
                        Map<String, dynamic> pelanggan = {
                          'nopol': nopolController.text,
                          'merkSpm': merkSpmController.text,
                          'tipeSpm': tipeSpmController.text,
                          'namaPelanggan': namaPelangganController.text,
                          'alamat': alamatController.text,
                          'noHp': noHpController.text,
                        };

                        dbRef
                            .child(widget.pelangganKey)
                            .update(pelanggan)
                            .then((_) {
                          final snackBar = SnackBar(
                            content: Text('Data berhasil diperbarui'),
                            duration: Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          Navigator.pop(context);
                        }).catchError((error) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Error'),
                                content:
                                    Text('Failed to update record: $error'),
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
                      } else {
                        final snackBar = SnackBar(
                          content: Text('Mohon lengkapi semua field'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
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
        ),
      ),
    );
  }
}
