import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:project_s/pages/home_page.dart';

class PenjualanPage extends StatefulWidget {
  @override
  _PenjualanPageState createState() => _PenjualanPageState();
}

class _PenjualanPageState extends State<PenjualanPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  String? _idPenjualan;
  String? _namaPembeli;
  String? _idSparepart;
  String? _namaSparepart;
  int? _jumlahItem;
  int? _hargaSparepart;
  int? _totalBayar;

  @override
  void initState() {
    super.initState();
    initializeFirebase();
  }

  void initializeFirebase() async {
    await Firebase.initializeApp();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _totalBayar = _hargaSparepart! * _jumlahItem!;
      });

      saveTransaksiPenjualan();
    }
  }

  void saveTransaksiPenjualan() {
    DatabaseReference reference =
        FirebaseDatabase.instance.reference().child('transaksiPenjualan');

    reference.push().set({
      'idPenjualan': _idPenjualan,
      'namaPembeli': _namaPembeli,
      'idSparepart': _idSparepart,
      'namaSparepart': _namaSparepart,
      'jumlahItem': _jumlahItem,
      'hargaSparepart': _hargaSparepart,
      'totalBayar': _totalBayar,
    }).then((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Transaksi Berhasil'),
            content: Text('Transaksi penjualan berhasil disimpan.'),
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
            content: Text('Terjadi kesalahan saat menyimpan transaksi.'),
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
        title: Text('Halaman Penjualan'),
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
                  'ID Penjualan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  onSaved: (value) => _idPenjualan = value,
                  decoration: InputDecoration(
                    hintText: 'Masukkan ID Penjualan',
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Nama Pembeli',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  onSaved: (value) => _namaPembeli = value,
                  decoration: InputDecoration(
                    hintText: 'Masukkan Nama Pembeli',
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
                  'Jumlah Item',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  onSaved: (value) => _jumlahItem = int.tryParse(value!),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Masukkan Jumlah Item',
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
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Bayar'),
                ),
                SizedBox(height: 10),
                if (_totalBayar != null)
                  Text(
                    'Nominal yang Harus Dibayar: Rp $_totalBayar',
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
