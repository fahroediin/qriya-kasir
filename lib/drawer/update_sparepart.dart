import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class UpdateRecord extends StatefulWidget {
  const UpdateRecord({Key? key, required this.sparepartKey}) : super(key: key);

  final String sparepartKey;

  @override
  State<UpdateRecord> createState() => _UpdateRecordState();
}

class _UpdateRecordState extends State<UpdateRecord> {
  late DatabaseReference dbRef;

  late TextEditingController namaSparepartController;
  late TextEditingController merkSparepartController;
  late TextEditingController specSparepartController;
  late TextEditingController hargaSparepartController;
  late TextEditingController stokSparepartController;

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();
    dbRef = FirebaseDatabase.instance.reference().child('daftarSparepart');
    getDaftarSparepart();

    namaSparepartController = TextEditingController();
    merkSparepartController = TextEditingController();
    specSparepartController = TextEditingController();
    hargaSparepartController = TextEditingController();
    stokSparepartController = TextEditingController();
  }

  void getDaftarSparepart() async {
    DataSnapshot snapshot = await dbRef.child(widget.sparepartKey).get();
    Map<dynamic, dynamic> daftarSparepart =
        snapshot.value as Map<dynamic, dynamic>;

    setState(() {
      namaSparepartController.text = daftarSparepart['namaSparepart'];
      merkSparepartController.text = daftarSparepart['merkSparepart'];
      specSparepartController.text = daftarSparepart['specSparepart'];
      hargaSparepartController.text =
          daftarSparepart['hargaSparepart'].toString();
      stokSparepartController.text =
          daftarSparepart['stokSparepart'].toString();
    });
  }

  @override
  void dispose() {
    namaSparepartController.dispose();
    merkSparepartController.dispose();
    specSparepartController.dispose();
    hargaSparepartController.dispose();
    stokSparepartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Sparepart'),
        backgroundColor: const Color.fromARGB(255, 219, 42, 15),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                TextField(
                  controller: namaSparepartController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Nama Sparepart',
                    hintText: 'Masukkan Nama Sparepart',
                  ),
                  textCapitalization: TextCapitalization
                      .words, // Mengubah hanya huruf pertama pada setiap kata yang kapital
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: merkSparepartController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Merk',
                    hintText: 'Masukkan Merk Sparepart',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: specSparepartController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Spesifikasi',
                    hintText: 'Masukkan Spesifikasi',
                  ),
                  textCapitalization: TextCapitalization
                      .sentences, // Mengubah hanya huruf pertama yang kapital
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: hargaSparepartController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Harga',
                    hintText: 'Masukkan Harga Sparepart',
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: stokSparepartController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Stok',
                    hintText: 'Masukkan Stok Sparepart',
                  ),
                ),
                const SizedBox(height: 30),
                MaterialButton(
                  onPressed: () {
                    if (namaSparepartController.text.isEmpty ||
                        merkSparepartController.text.isEmpty ||
                        specSparepartController.text.isEmpty ||
                        hargaSparepartController.text.isEmpty ||
                        stokSparepartController.text.isEmpty) {
                      _showSnackBar('Mohon lengkapi semua field');
                    } else {
                      Map<String, dynamic> sparepart = {
                        'namaSparepart': namaSparepartController.text,
                        'merkSparepart': merkSparepartController.text,
                        'specSparepart': specSparepartController.text,
                        'hargaSparepart':
                            int.parse(hargaSparepartController.text),
                        'stokSparepart':
                            int.parse(stokSparepartController.text),
                      };

                      dbRef
                          .child(widget.sparepartKey)
                          .update(sparepart)
                          .then((_) {
                        _showSnackBar('Data berhasil diperbarui');
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
      ),
    );
  }
}
