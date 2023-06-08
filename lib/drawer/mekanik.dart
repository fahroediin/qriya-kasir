import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:project_s/pages/home_page.dart';

class MekanikPage extends StatefulWidget {
  const MekanikPage({Key? key}) : super(key: key);

  @override
  _MekanikPageState createState() => _MekanikPageState();
}

class _MekanikPageState extends State<MekanikPage> {
  final TextEditingController _idMekanikController = TextEditingController();
  final TextEditingController _namaMekanikController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();

  final databaseReference = FirebaseDatabase.instance.reference();

  void saveData() {
    String idMekanik = _idMekanikController.text.trim();
    String namaMekanik = _namaMekanikController.text.trim();
    String alamat = _alamatController.text.trim();
    String noHp = _noHpController.text.trim();

    if (idMekanik.isNotEmpty &&
        namaMekanik.isNotEmpty &&
        alamat.isNotEmpty &&
        noHp.isNotEmpty) {
      databaseReference.child('mekanik').child(idMekanik).set({
        'namaMekanik': namaMekanik,
        'alamat': alamat,
        'noHp': noHp,
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Data mekanik berhasil disimpan')));
        _clearFields();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Terjadi kesalahan saat menyimpan data mekanik')));
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Mohon lengkapi semua field')));
    }
  }

  void _clearFields() {
    _idMekanikController.clear();
    _namaMekanikController.clear();
    _alamatController.clear();
    _noHpController.clear();
  }

  @override
  void dispose() {
    _idMekanikController.dispose();
    _namaMekanikController.dispose();
    _alamatController.dispose();
    _noHpController.dispose();
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
        title: Text('Halaman Mekanik'),
        backgroundColor: Color.fromARGB(255, 219, 42, 15),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'ID Mekanik:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _idMekanikController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'ID Mekanik',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Nama Mekanik:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _namaMekanikController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Nama Mekanik',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Alamat:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _alamatController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Alamat Mekanik',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Nomor HP:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _noHpController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Nomor HP Mekanik',
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
