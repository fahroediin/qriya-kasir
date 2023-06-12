import 'dart:core';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:project_s/pages/home_page.dart';

class ServisPage extends StatefulWidget {
  @override
  _ServisPageState createState() => _ServisPageState();
}

class _ServisPageState extends State<ServisPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  String _idServis = '';
  String? _hariTanggal;
  String? _idMekanik;
  String? _namaMekanik;
  String? _nopol;
  String? _namaPemilik;
  String? _merkSpm;
  String? _tipeSpm;
  String? _kerusakan;
  String? _idSparepart;
  String? _namaSparepart;
  int? _hargaSparepart;
  int? _jumlahSparepart;
  int? _biayaServis;
  int? _totalBayar;
  int? _jumlahBayar;
  int? _kembalian;

  @override
  void initState() {
    super.initState();
    initializeFirebase();
  }

  void initializeFirebase() async {
    await Firebase.initializeApp();
  }

  String _generateIdServis() {
    DateTime now = DateTime.now();
    String formattedDate =
        '${now.year}${_addLeadingZero(now.month)}${_addLeadingZero(now.day)}';
    return formattedDate + _addLeadingZero(now.microsecondsSinceEpoch % 10000);
  }

  String _addLeadingZero(int number) {
    if (number.toString().length < 2) {
      return '0$number';
    }
    return number.toString();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _idServis = _generateIdServis();
        _totalBayar = _hargaSparepart! * _jumlahSparepart! + _biayaServis!;
        _kembalian = _jumlahBayar! - _totalBayar!;
      });

      saveTransaksiServis();
    }
  }

  void saveTransaksiServis() {
    DatabaseReference reference =
        FirebaseDatabase.instance.reference().child('transaksiServis');

    reference.push().set({
      'idServis': _idServis,
      'hariTanggal': _hariTanggal,
      'idMekanik': _idMekanik,
      'namaMekanik': _namaMekanik,
      'nopol': _nopol,
      'namaPemilik': _namaPemilik,
      'merkSpm': _merkSpm,
      'tipeSpm': _tipeSpm,
      'kerusakan': _kerusakan,
      'idSparepart': _idSparepart,
      'namaSparepart': _namaSparepart,
      'hargaSparepart': _hargaSparepart,
      'jumlahSparepart': _jumlahSparepart,
      'biayaServis': _biayaServis,
      'totalBayar': _totalBayar,
      'jumlahBayar': _jumlahBayar,
      'kembalian': _kembalian,
    }).then((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Data Servis Berhasil Disimpan'),
            content: Text('Data servis berhasil disimpan.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
              ),
            ],
          );
        },
      );
    }).catchError((error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Terjadi Kesalahan'),
            content: Text('Terjadi kesalahan saat menyimpan data servis.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(fontWeight: FontWeight.bold);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    HomePage(),
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
                transitionDuration: Duration(milliseconds: 300),
              ),
            );
          },
        ),
        title: Text('Halaman Servis'),
        backgroundColor: Color.fromARGB(255, 219, 42, 15),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'ID Servis',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  initialValue: _idServis,
                  enabled: false,
                  decoration: InputDecoration(
                    hintText: 'ID Servis akan dihasilkan otomatis',
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Hari/Tanggal',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  onSaved: (value) => _hariTanggal = value,
                  decoration: InputDecoration(
                    hintText: 'Masukkan Hari/Tanggal',
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'ID Mekanik',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  onSaved: (value) => _idMekanik = value,
                  decoration: InputDecoration(
                    hintText: 'Masukkan ID Mekanik',
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Nama Mekanik',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  onSaved: (value) => _namaMekanik = value,
                  decoration: InputDecoration(
                    hintText: 'Masukkan Nama Mekanik',
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Nomor Polisi',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  onSaved: (value) => _nopol = value,
                  decoration: InputDecoration(
                    hintText: 'Masukkan Nomor Polisi',
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Nama Pemilik',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  onSaved: (value) => _namaPemilik = value,
                  decoration: InputDecoration(
                    hintText: 'Masukkan Nama Pemilik',
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Merk Kendaraan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  onSaved: (value) => _merkSpm = value,
                  decoration: InputDecoration(
                    hintText: 'Masukkan Merk Kendaraan',
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Tipe Kendaraan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  onSaved: (value) => _tipeSpm = value,
                  decoration: InputDecoration(
                    hintText: 'Masukkan Tipe Kendaraan',
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Kerusakan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  onSaved: (value) => _kerusakan = value,
                  decoration: InputDecoration(
                    hintText: 'Masukkan Kerusakan',
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'ID Sparepart',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  onSaved: (value) => _idSparepart = value,
                  decoration: InputDecoration(
                    hintText: 'Masukkan ID Sparepart',
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Nama Sparepart',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  onSaved: (value) => _namaSparepart = value,
                  decoration: InputDecoration(
                    hintText: 'Masukkan Nama Sparepart',
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Harga Sparepart',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  onSaved: (value) => _hargaSparepart = int.tryParse(value!),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Masukkan Harga Sparepart',
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Jumlah Sparepart',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  onSaved: (value) => _jumlahSparepart = int.tryParse(value!),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Masukkan Jumlah Sparepart',
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Biaya Servis',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  onSaved: (value) => _biayaServis = int.tryParse(value!),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Masukkan Biaya Servis',
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Jumlah Bayar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  onSaved: (value) => _jumlahBayar = int.tryParse(value!),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Masukkan Jumlah Bayar',
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Simpan'),
                ),
                SizedBox(height: 10),
                if (_totalBayar != null)
                  Text(
                    'Total Bayar: Rp $_totalBayar',
                    style: textStyle,
                  ),
                if (_kembalian != null)
                  Text(
                    'Kembalian: Rp $_kembalian',
                    style: textStyle,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
