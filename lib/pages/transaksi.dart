import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:project_s/pages/home_page.dart';

class TransaksiPenjualanPage extends StatefulWidget {
  @override
  _TransaksiPenjualanPageState createState() => _TransaksiPenjualanPageState();
}

class _TransaksiPenjualanPageState extends State<TransaksiPenjualanPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  String? _idPenjualan;
  String? _namaPembeli;
  List<Map<String, dynamic>> _items = [];
  double _totalHarga = 0;
  double _bayar = 0;
  double _kembalian = 0;

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
      saveTransaksiPenjualan();
    }
  }

  void saveTransaksiPenjualan() {
    DatabaseReference reference =
        FirebaseDatabase.instance.reference().child('transaksiPenjualan');

    Map<String, dynamic> data = {
      'idPenjualan': _idPenjualan,
      'namaPembeli': _namaPembeli,
      'items': _items,
      'totalHarga': _totalHarga,
      'bayar': _bayar,
      'kembalian': _kembalian,
    };

    reference.push().set(data).then((_) {
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

  void _addItem() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Map<String, dynamic> item = {
        'idSparepart': '',
        'namaSparepart': '',
        'jumlahItem': 0,
        'hargaSparepart': 0,
      };
      setState(() {
        _items.add(item);
      });
    }
  }

  void _updateItem(int index, String field, dynamic value) {
    setState(() {
      _items[index][field] = value;
    });
    calculateTotalHarga();
  }

  void calculateTotalHarga() {
    double total = 0;
    for (var item in _items) {
      double harga =
          item['hargaSparepart'] != null ? item['hargaSparepart'] : 0;
      int jumlah = item['jumlahItem'] != null ? item['jumlahItem'] : 0;
      total += harga * jumlah;
    }
    setState(() {
      _totalHarga = total;
    });
  }

  void _updateBayar(String value) {
    double? bayar = double.tryParse(value);
    if (bayar != null) {
      _bayar = bayar;
      calculateKembalian();
    }
  }

  void calculateKembalian() {
    double kembalian = _bayar - _totalHarga;
    setState(() {
      _kembalian = kembalian;
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
        title: Text('Transaksi Penjualan'),
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
                  'Item',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        SizedBox(height: 10),
                        Text(
                          'Sparepart ${index + 1}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextFormField(
                          onChanged: (value) =>
                              _updateItem(index, 'idSparepart', value),
                          decoration: InputDecoration(
                            hintText: 'Masukkan ID Sparepart',
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          onChanged: (value) =>
                              _updateItem(index, 'namaSparepart', value),
                          decoration: InputDecoration(
                            hintText: 'Masukkan Nama Sparepart',
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          onChanged: (value) => _updateItem(
                              index, 'jumlahItem', int.tryParse(value)),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Masukkan Jumlah Item',
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          onChanged: (value) => _updateItem(
                              index, 'hargaSparepart', double.tryParse(value)),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Masukkan Harga Sparepart',
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addItem,
                  child: Icon(Icons.add),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(16),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Jumlah yang Harus Dibayar:',
                  style: textStyle,
                ),
                TextFormField(
                  initialValue: _totalHarga.toString(),
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Jumlah yang Harus Dibayar',
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Bayar:',
                  style: textStyle,
                ),
                TextFormField(
                  onChanged: (value) => _updateBayar(value),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Masukkan Jumlah Bayar',
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Kembalian:',
                  style: textStyle,
                ),
                TextFormField(
                  initialValue: _kembalian.toString(),
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Kembalian',
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Bayar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
