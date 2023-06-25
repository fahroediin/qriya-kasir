import 'dart:math';
import 'dart:ffi';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:project_s/pages/home_page.dart';
import 'package:project_s/pages/transaksiSuccess.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'transaksiSuccess.dart';

class TransaksiPenjualanPage extends StatefulWidget {
  @override
  _TransaksiPenjualanPageState createState() => _TransaksiPenjualanPageState();
}

class _TransaksiPenjualanPageState extends State<TransaksiPenjualanPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  String? _idPenjualan;
  String _formattedDateTime = '';
  String? _namaPembeli;
  double _totalHarga = 0;
  double _bayar = 0;
  double _kembalian = 0;
  final List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    initializeFirebase();
    generateIdPenjualan();
    _updateDateTime();
  }

  void _updateDateTime() {
    setState(() {
      _formattedDateTime =
          DateFormat('dd/MM/yyyy HH:mm:ss').format(_selectedDate);
    });
  }

  void initializeFirebase() async {
    await Firebase.initializeApp();
  }

  void generateIdPenjualan() {
    final now = DateTime.now();
    final formattedDateTime = DateFormat('ddMMyyyy').format(now);
    final randomNumbers = List.generate(
      6,
      (_) => Random().nextInt(10),
    );
    final idPenjualan = '$formattedDateTime-${randomNumbers.join('')}';

    setState(() {
      _idPenjualan = idPenjualan;
    });
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
      'dateTime': _formattedDateTime,
      'namaPembeli': _namaPembeli,
      'items': _items,
      'totalHarga': _totalHarga,
      'bayar': _bayar,
      'kembalian': _kembalian,
    };

    reference.push().set(data).then((_) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TransaksiSuccessPage(
            idPenjualan: data['idPenjualan'],
            formattedDateTime: data['formattedDateTime'] ?? '',
            namaPembeli: data['namaPembeli'],
            totalHarga: data['totalHarga'].toDouble(),
            bayar: data['bayar'].toDouble(),
            kembalian: _kembalian.toDouble(),
            items: List<Map<String, dynamic>>.from(data['items']),
          ),
        ),
      );
    }).catchError((onError) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Proses gagal'),
            content: Text('Terjadi kesalahan saat menyimpan transaksi'),
            actions: <Widget>[
              TextButton(
                child: Text('Tutup'),
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
    setState(() {
      _items.add({
        'idSparepart': '',
        'namaSparepart': '',
        'hargaSparepart': 0,
        'jumlahSparepart': 0,
      });
    });
  }

  void _updateItem(int index, String field, dynamic value) {
    setState(() {
      _items[index][field] = value;
    });
    _calculateTotalHarga();
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
    _calculateTotalHarga();
  }

  void _calculateTotalHarga() {
    double totalHarga = 0;
    for (var item in _items) {
      double harga = double.tryParse(item['hargaSparepart'].toString()) ?? 0;
      int jumlah = int.tryParse(item['jumlahSparepart'].toString()) ?? 0;
      totalHarga += harga * jumlah;
    }
    setState(() {
      _totalHarga = totalHarga;
    });
  }

  void _calculateKembalian(double jumlahBayar) {
    double kembalian = jumlahBayar - _totalHarga;
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
          child: ListView(
            children: [
              Text(
                'ID Transaksi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                initialValue: _idPenjualan,
                readOnly: true,
                style: TextStyle(color: Colors.grey),
                decoration: InputDecoration(),
              ),
              SizedBox(height: 10),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tanggal dan Waktu',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _formattedDateTime,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(labelText: 'Nama Pembeli'),
                textCapitalization: TextCapitalization.words,
                onSaved: (value) {
                  _namaPembeli = value ?? 'Anonim';
                },
                initialValue: 'Anonim',
              ),
              SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            onChanged: (value) {
                              _updateItem(index, 'idSparepart', value);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'ID Sparepart tidak boleh kosong';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'ID Sparepart',
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            onChanged: (value) {
                              _updateItem(index, 'namaSparepart', value);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nama Sparepart tidak boleh kosong';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Nama Sparepart',
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            onChanged: (value) {
                              double harga = double.tryParse(value) ?? 0;
                              _updateItem(index, 'hargaSparepart', harga);
                            },
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Harga Sparepart tidak boleh kosong';
                              }
                              return null;
                            },
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.]')),
                            ],
                            decoration: InputDecoration(
                              labelText: 'Harga Sparepart',
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            onChanged: (value) {
                              int jumlah = int.tryParse(value) ?? 0;
                              _updateItem(index, 'jumlahSparepart', jumlah);
                            },
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Jumlah Sparepart tidak boleh kosong';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Jumlah Sparepart',
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            _removeItem(index);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 10),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(255, 219, 42, 15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: _addItem,
                  borderRadius: BorderRadius.circular(25),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Total Harga: $_totalHarga',
                style: textStyle,
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(labelText: 'Bayar'),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                onChanged: (value) {
                  _bayar = double.parse(value);
                  double kembalian = _bayar - _totalHarga;
                  setState(() {
                    _kembalian = max(0, kembalian);
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Jumlah bayar tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              Text(
                'Kembalian: $_kembalian',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 219, 42, 15),
                ),
                child: Text('Proses Transaksi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
