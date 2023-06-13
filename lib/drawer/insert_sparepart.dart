import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:project_s/drawer/sparepart.dart';
import 'package:project_s/pages/home_page.dart';
import 'dart:math';

class InputSparepartPage extends StatefulWidget {
  const InputSparepartPage({Key? key}) : super(key: key);

  @override
  _InputSparepartPageState createState() => _InputSparepartPageState();
}

class _InputSparepartPageState extends State<InputSparepartPage>
    with TickerProviderStateMixin {
  final TextEditingController _idSparepartController = TextEditingController();
  final TextEditingController _namaSparepartController =
      TextEditingController();
  final TextEditingController _merkSparepartController =
      TextEditingController();
  final TextEditingController _specSparepartController =
      TextEditingController();
  final TextEditingController _hargaSparepartController =
      TextEditingController();
  final TextEditingController _stokSparepartController =
      TextEditingController();

  final databaseReference = FirebaseDatabase.instance.reference();

  @override
  void initState() {
    super.initState();
    _idSparepartController.text = generateID();
  }

  String generateID() {
    // Generate 4 random digits
    String randomDigits = '';
    for (int i = 0; i < 4; i++) {
      randomDigits += '${Random().nextInt(10)}';
    }

    return 'SP$randomDigits';
  }

  void saveData() {
    String idSparepart = _idSparepartController.text.trim();
    String namaSparepart = _namaSparepartController.text.trim();
    String merkSparepart = _merkSparepartController.text.trim();
    String specSparepart = _specSparepartController.text.trim();
    String hargaSparepart = _hargaSparepartController.text.trim();
    String stokSparepart = _stokSparepartController.text.trim();

    if (idSparepart.isNotEmpty &&
        namaSparepart.isNotEmpty &&
        merkSparepart.isNotEmpty &&
        specSparepart.isNotEmpty &&
        hargaSparepart.isNotEmpty &&
        stokSparepart.isNotEmpty) {
      databaseReference.child('daftarSparepart').child(idSparepart).set({
        'idSparepart': idSparepart,
        'namaSparepart': namaSparepart,
        'merkSparepart': merkSparepart,
        'specSparepart': specSparepart,
        'hargaSparepart': hargaSparepart,
        'stokSparepart': stokSparepart,
      }).then((_) {
        final snackBar = SnackBar(content: Text('Berhasil menyimpan data'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        _clearFields();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SparepartPage()),
        );
      }).catchError((error) {
        final snackBar =
            SnackBar(content: Text('Gagal menyimpan data suku cadang: $error'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    } else {
      final snackBar = SnackBar(content: Text('Mohon lengkapi semua field'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void _clearFields() {
    _idSparepartController.clear();
    _namaSparepartController.clear();
    _merkSparepartController.clear();
    _specSparepartController.clear();
    _hargaSparepartController.clear();
    _stokSparepartController.clear();
  }

  @override
  void dispose() {
    _idSparepartController.dispose();
    _namaSparepartController.dispose();
    _merkSparepartController.dispose();
    _specSparepartController.dispose();
    _hargaSparepartController.dispose();
    _stokSparepartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SparepartPage()),
            );
          },
        ),
        title: Text('Tambah Suku Cadang'),
        backgroundColor: Color.fromARGB(255, 219, 42, 15),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 10),
            TextField(
              controller: _idSparepartController,
              enabled: false, // Set TextField menjadi read-only
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'ID Sparepart',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _namaSparepartController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nama Sparepart',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _merkSparepartController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Merk Sparepart',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _specSparepartController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Spec Sparepart',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _hargaSparepartController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Harga Sparepart',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _stokSparepartController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Stok Sparepart',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveData,
              child: Text('Simpan'),
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 219, 42, 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
