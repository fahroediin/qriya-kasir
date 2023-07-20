import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';

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
  bool _isNoHpValid = true;
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

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration:
          const Duration(seconds: 2), // Durasi muncul snackbar selama 2 detik
      behavior: SnackBarBehavior.floating, // Mengatur snackbar menjadi floating
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Mekanik'),
        backgroundColor:
            const Color.fromARGB(255, 219, 42, 15), // Ubah warna AppBar
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: namaMekanikController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Nama',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
                  LengthLimitingTextInputFormatter(255),
                ],
                onChanged: (value) {
                  String formattedValue = '';
                  bool capitalizeNext = true;

                  for (int i = 0; i < value.length; i++) {
                    String char = value[i];
                    if (char == ' ') {
                      capitalizeNext = true;
                    } else {
                      if (capitalizeNext) {
                        char = char.toUpperCase();
                      } else {
                        char = char.toLowerCase();
                      }
                      capitalizeNext = false;
                    }
                    formattedValue += char;
                  }

                  namaMekanikController.value =
                      namaMekanikController.value.copyWith(
                    text: formattedValue,
                    selection:
                        TextSelection.collapsed(offset: formattedValue.length),
                  );
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Wajib diisi';
                  }
                  if (value.length < 3) {
                    return 'Minimal terdiri dari 3 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                controller: alamatController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Alamat',
                  hintText: '',
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(
                height: 30,
              ),
              TextField(
                controller: noHpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nomer HP',
                  hintText: '',
                ),
                onChanged: (value) {
                  if (value.length > 13) {
                    // Jika panjang digit lebih dari 13
                    // Potong nilai input menjadi 13 karakter
                    value = value.substring(0, 13);

                    setState(() {
                      noHpController.text = value;
                      noHpController.selection = TextSelection.fromPosition(
                        TextPosition(offset: value.length),
                      );
                    });
                  }

                  if (value.length < 10 || value.length > 13) {
                    setState(() {
                      _isNoHpValid = false;
                    });
                  } else {
                    setState(() {
                      _isNoHpValid = true;
                    });
                  }
                },
              ),
              SizedBox(height: 10),
              MaterialButton(
                onPressed: () {
                  if (namaMekanikController.text.isEmpty ||
                      alamatController.text.isEmpty ||
                      noHpController.text.isEmpty) {
                    _showSnackBar('Mohon lengkapi semua field');
                  } else {
                    Map<String, dynamic> mekanik = {
                      'namaMekanik': namaMekanikController.text,
                      'alamat': alamatController.text,
                      'noHp': noHpController.text,
                    };
                    dbRef.child(widget.mekanikKey).update(mekanik).then((_) {
                      _showSnackBar('Mekanik berhasil diperbarui');
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
                  }
                },
                child: const Text('Update Data'),
                color: const Color.fromARGB(255, 219, 42, 15),
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
