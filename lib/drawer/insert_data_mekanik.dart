import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:project_s/pages/home_page.dart';
import 'mekanik.dart';
import 'dart:math';

class AddMekanikPage extends StatefulWidget {
  const AddMekanikPage({Key? key}) : super(key: key);

  @override
  _AddMekanikPageState createState() => _AddMekanikPageState();
}

class _AddMekanikPageState extends State<AddMekanikPage> {
  final TextEditingController _idMekanikController = TextEditingController();
  final TextEditingController _namaMekanikController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  bool _isNoHpValid = true; // Variabel untuk menunjukkan validitas nomor HP

  final databaseReference = FirebaseDatabase.instance.reference();

  @override
  void initState() {
    super.initState();
    _idMekanikController.text = _generateIdMekanik();
  }

  String _generateIdMekanik() {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();

    String id = 'MK'; // Menginisialisasi dengan 'MK' sebagai awalan

    // Generate 2 angka acak
    int angka1 = random.nextInt(10);
    int angka2 = random.nextInt(10);

    // Generate 2 huruf acak
    String huruf1 = chars[random.nextInt(26)];
    String huruf2 = chars[random.nextInt(26)];

    id +=
        '$angka1$huruf1$angka2$huruf2'; // Menambahkan angka dan huruf acak ke ID

    return id;
  }

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
            SnackBar(content: Text('Mekanik successfully added')));
        _clearFields();

        // Navigasi ke halaman MekanikPage setelah data berhasil disimpan
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MekanikPage()),
        );
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
              MaterialPageRoute(builder: (context) => MekanikPage()),
            );
          },
        ),
        title: Text('Tambah Mekanik'),
        backgroundColor: Color.fromARGB(255, 219, 42, 15),
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 10),
            TextField(
              controller: _idMekanikController,
              keyboardType: TextInputType.text,
              enabled: false, // Membuat TextField menjadi read-only
              style: TextStyle(
                color:
                    Colors.grey, // Mengatur warna teks menjadi abu-abu (grey)
              ),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'ID Mekanik',
                hintText: '',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _namaMekanikController,
              keyboardType: TextInputType.name,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nama Mekanik',
                hintText: '',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _alamatController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Alamat',
                hintText: '',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _noHpController,
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
                    _noHpController.text = value;
                    _noHpController.selection = TextSelection.fromPosition(
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
