import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:project_s/pages/home_page.dart';

class SukuCadangPage extends StatefulWidget {
  const SukuCadangPage({Key? key}) : super(key: key);

  @override
  _SukuCadangPageState createState() => _SukuCadangPageState();
}

class _SukuCadangPageState extends State<SukuCadangPage>
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
        final snackBar =
            SnackBar(content: Text('Data suku cadang berhasil disimpan'));
        ScaffoldMessenger.of(context).showSnackBar(
          snackBar,
        );
        _clearFields();
      }).catchError((error) {
        final snackBar =
            SnackBar(content: Text('Gagal menyimpan data suku cadang: $error'));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: AnimationController(
                  vsync: this,
                  duration: Duration(milliseconds: 500),
                ),
                curve: Curves.easeOut,
              )),
              child: snackBar,
            ),
          ),
        );
      });
    } else {
      final snackBar = SnackBar(content: Text('Mohon lengkapi semua field'));
      ScaffoldMessenger.of(context).showSnackBar(
        snackBar,
      );
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
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
        title: Text('Input Suku Cadang'),
        backgroundColor: Color.fromARGB(255, 219, 42, 15),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'ID Sparepart:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _idSparepartController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'ID Sparepart',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Nama Sparepart:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _namaSparepartController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Nama Sparepart',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Merk Sparepart:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _merkSparepartController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Merk Sparepart',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Spec Sparepart:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _specSparepartController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Spec Sparepart',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Harga Sparepart:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _hargaSparepartController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Harga Sparepart',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Stok Sparepart:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _stokSparepartController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Stok Sparepart',
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
