import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
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

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2), // Durasi tampil snackbar selama 2 detik
      behavior: SnackBarBehavior
          .floating, // Mengatur snackbar agar muncul selama durasi yang ditentukan
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
        'idMekanik': idMekanik,
        'namaMekanik': namaMekanik,
        'alamat': alamat,
        'noHp': noHp,
      }).then((_) {
        final snackBar = SnackBar(
          content: Text('Mekanik berhasil ditambahkan'),
          duration:
              Duration(seconds: 2), // Durasi tampil snackbar selama 2 detik
          behavior: SnackBarBehavior
              .floating, // Mengatur snackbar agar muncul selama durasi yang ditentukan
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        _clearFields();

        // Navigasi ke halaman MekanikPage setelah data berhasil disimpan
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MekanikPage()),
        );
      }).catchError((error) {
        final snackBar = SnackBar(
          content: Text('Terjadi kesalahan saat menyimpan data mekanik'),
          duration:
              Duration(seconds: 2), // Durasi tampil snackbar selama 2 detik
          behavior: SnackBarBehavior
              .floating, // Mengatur snackbar agar muncul selama durasi yang ditentukan
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });
    } else {
      final snackBar = SnackBar(
        content: Text('Mohon lengkapi semua field'),
        duration: Duration(seconds: 2), // Durasi tampil snackbar selama 2 detik
        behavior: SnackBarBehavior
            .floating, // Mengatur snackbar agar muncul selama durasi yang ditentukan
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                transitionDuration: Duration(milliseconds: 500),
                pageBuilder: (context, animation, secondaryAnimation) =>
                    MekanikPage(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  var begin = Offset(1.0, 0.0);
                  var end = Offset.zero;
                  var curve = Curves.ease;

                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
              ),
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
            TextFormField(
              controller: _namaMekanikController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Nama',
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
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
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _alamatController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Alamat',
                hintText: '',
              ),
              textCapitalization: TextCapitalization.characters,
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
