import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:project_s/pages/home_page.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'servisSuccess.dart';

class ServisPage extends StatefulWidget {
  @override
  _ServisPageState createState() => _ServisPageState();
}

class _ServisPageState extends State<ServisPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDateTime = DateTime.now();
  String? _idServis;
  String _formattedDateTime = '';
  String? _idMekanik;
  String? _namaMekanik;
  String? _nopol;
  String? _namaPelanggan;
  String? _merkKendaraan;
  String? _tipeKendaraan;
  String? _kerusakan;
  List<Map<String, dynamic>> _sparepartItems = [];
  double _totalBayar = 0;
  double _bayar = 0;
  double _biayaServis = 0;
  double _kembalian = 0;
  double _diskon = 0;
  List<String> _mekanikList = [];
  Map<String, String> _mekanikNameMap = {};
  TextEditingController _namaMekanikController = TextEditingController();
  List<String> _nopolList = []; // Daftar Nomor Polisi
  Map<String, dynamic> _pelangganNameMap = {};
  final TextEditingController _namaPelangganController =
      TextEditingController();
  final TextEditingController _merkKendaraanController =
      TextEditingController();
  final TextEditingController _tipeKendaraanController =
      TextEditingController();
  final List<Map<String, dynamic>> _items = [];
  List<Map<dynamic, dynamic>> sparepartList = [];
  List<Map<dynamic, dynamic>> filteredSparepartList = [];
  List<Map<String, dynamic>> selectedSpareparts = [];
  TextEditingController diskonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeFirebase();
    generateIdServis();
    updateDateTime();
    getMekanikList();
    getPelangganList();
  }

  void updateDateTime() {
    setState(() {
      _formattedDateTime =
          DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
    });
  }

  void initializeFirebase() async {
    await Firebase.initializeApp();
  }

  void generateIdServis() {
    final now = DateTime.now();
    final formattedDateTime = DateFormat('ddMMyyyy').format(now);
    final randomNumbers = List.generate(
      6,
      (_) => Random().nextInt(10),
    );
    final idPenjualan = '$formattedDateTime-${randomNumbers.join('')}';

    setState(() {
      _idServis = idPenjualan;
    });
  }

  void submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      saveServisData();
    }
  }

  void saveServisData() {
    DatabaseReference reference =
        FirebaseDatabase.instance.reference().child('transaksiServis');

    double diskon = double.tryParse(diskonController.text) ?? 0;
    double totalHarga = calculateTotalPriceBeforeDiscount();

    Map<String, dynamic> data = {
      'idServis': _idServis,
      'dateTime': _formattedDateTime,
      'idMekanik': _idMekanik,
      'namaMekanik': _namaMekanik,
      'nopol': _nopol,
      'namaPelanggan': _namaPelangganController.text,
      'merkSpm': _merkKendaraanController.text,
      'tipeSpm': _tipeKendaraanController.text,
      'kerusakan': _kerusakan,
      'items': _items,
      'diskon': diskon,
      'totalHargaSparepart': totalHarga,
      'hargaAkhir': _totalBayar,
      'biayaServis': _biayaServis,
      'bayar': _bayar,
      'kembalian': _kembalian,
    };

    reference.push().set(data).then(
      (_) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ServisSuccessPage(
                    idServis: data['idServis'],
                    dateTime: data['dateTime'] ?? '',
                    idMekanik: data['idMekanik'],
                    namaMekanik: data['namaMekanik'],
                    nopol: data['nopol'],
                    namaPelanggan: data['namaPelanggan'],
                    merkSpm: data['merkSpm'],
                    tipeSpm: data['tipeSpm'],
                    kerusakan: data['kerusakan'],
                    items: data['items'],
                    totalHarga: data['totalHargaSparepart'],
                    diskon: data['diskon'],
                    biayaServis: data['biayaServis'],
                    hargaAkhir: data['hargaAkhir'],
                    bayar: data['bayar'],
                    kembalian: data['kembalian'],
                  )),
        );
      },
    );
  }

// Calculate total price before discount
  double calculateTotalPriceBeforeDiscount() {
    double totalHarga = 0;
    for (Map<String, dynamic> item in _items) {
      int hargaSparepart = item['hargaSparepart'];
      int jumlahSparepart = item['jumlahSparepart'];
      totalHarga += hargaSparepart * jumlahSparepart;
    }
    return totalHarga;
  }

// Calculate total price after discount
  double calculateTotalPriceAfterDiscount(double discount) {
    double totalHarga = calculateTotalPriceBeforeDiscount();
    double discountAmount = totalHarga * discount / 100;
    return totalHarga - discountAmount;
  }

  void _calculateTotalHarga() {
    double totalHarga = calculateTotalPriceBeforeDiscount();
    double discountAmount = _diskon;
    double totalHargaAfterDiscount = totalHarga - discountAmount;
    setState(() {
      _totalBayar = totalHargaAfterDiscount;
      calculateKembalian(); // Menghitung kembalian saat totalBayar diperbarui
    });
  }

  void calculateKembalian() {
    double kembalian = _bayar - (_totalBayar + _biayaServis);
    setState(() {
      _kembalian = kembalian;
    });
  }

  void getMekanikList() {
    FirebaseDatabase.instance.ref('mekanik').onValue.listen((event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> values =
            event.snapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          setState(() {
            _mekanikList.add(value['idMekanik']);
            _mekanikNameMap[value['idMekanik']] = value['namaMekanik'];
          });
        });
      }
    });
  }

  void _selectMekanik(String? value) {
    setState(() {
      _idMekanik = value;
      _namaMekanik = _mekanikNameMap[value];
      _namaMekanikController.text = _namaMekanik ?? '';
    });
  }

  void getPelangganList() {
    FirebaseDatabase.instance
        .reference()
        .child('daftarPelanggan')
        .onValue
        .listen((event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> values =
            event.snapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          setState(() {
            _nopolList.add(value['nopol']);
            _pelangganNameMap[value['nopol']] = {
              'namaPelanggan': value['namaPelanggan'],
              'merkSpm': value['merkSpm'],
              'tipeSpm': value['tipeSpm'],
            };
          });
        });
      }
    });
  }

  void _selectPelanggan(String? value) {
    setState(() {
      _nopol = value;
      _updateDataPelanggan(value);
      _namaPelangganController.text = _namaPelanggan ?? '';
      _merkKendaraanController.text = _merkKendaraan ?? '';
      _tipeKendaraanController.text = _tipeKendaraan ?? '';
    });
  }

  void _updateDataPelanggan(String? nopol) {
    if (nopol != null) {
      Map<String, dynamic>? pelangganData = _pelangganNameMap[nopol];
      if (pelangganData != null) {
        setState(() {
          _namaPelanggan = pelangganData['namaPelanggan'];
          _merkKendaraan = pelangganData['merkSpm'];
          _tipeKendaraan = pelangganData['tipeSpm'];
        });
        _merkKendaraanController.text = _merkKendaraan ?? '';
        _tipeKendaraanController.text = _tipeKendaraan ?? '';
      } else {
        setState(() {
          _namaPelanggan = null;
          _merkKendaraan = null;
          _tipeKendaraan = null;
        });
        _merkKendaraanController.text = '';
        _tipeKendaraanController.text = '';
      }
    }
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        List<Map<String, dynamic>> selectedSpareparts = [];

        List<Map<dynamic, dynamic>> sparepartList = [];
        List<Map<dynamic, dynamic>> filteredSparepartList = [];
        TextEditingController jumlahItemController = TextEditingController();

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Daftar Sparepart'),
              content: Container(
                width: double.maxFinite,
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Cari Sparepart',
                      ),
                      onChanged: (value) {
                        filteredSparepartList =
                            sparepartList.where((sparepart) {
                          String namaSparepart = sparepart['namaSparepart']
                              .toString()
                              .toLowerCase();
                          String specSparepart = sparepart['specSparepart']
                              .toString()
                              .toLowerCase();
                          String searchKeyword = value.toLowerCase();
                          return namaSparepart.contains(searchKeyword) ||
                              specSparepart.contains(searchKeyword);
                        }).toList();
                        setState(() {});
                      },
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: FutureBuilder<DataSnapshot>(
                        future: FirebaseDatabase.instance
                            .reference()
                            .child('daftarSparepart')
                            .get(),
                        builder: (BuildContext context,
                            AsyncSnapshot<DataSnapshot> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasData &&
                              snapshot.data != null) {
                            DataSnapshot dataSnapshot = snapshot.data!;
                            Map<dynamic, dynamic>? data =
                                dataSnapshot.value as Map<dynamic, dynamic>?;

                            if (data != null) {
                              sparepartList = [];
                              data.forEach((key, value) {
                                sparepartList
                                    .add(Map<dynamic, dynamic>.from(value));
                              });
                              filteredSparepartList = sparepartList;
                            }

                            if (filteredSparepartList.isEmpty) {
                              return Center(
                                child: Text('Tidak ada data sparepart'),
                              );
                            }
                            return ListView.separated(
                              shrinkWrap: true,
                              itemCount: filteredSparepartList.length,
                              separatorBuilder:
                                  (BuildContext context, int index) => Divider(
                                color: Colors.grey,
                                thickness: 1.0,
                              ),
                              itemBuilder: (BuildContext context, int index) {
                                Map<dynamic, dynamic> sparepart =
                                    filteredSparepartList[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color.fromARGB(255, 237, 85, 85)
                                            .withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      'ID Sparepart: ${sparepart['idSparepart']}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 8.0),
                                        Text(
                                          'Nama Sparepart: ${sparepart['namaSparepart']}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 4.0),
                                        Text(
                                            'Merk Sparepart: ${sparepart['merkSparepart']}'),
                                        SizedBox(height: 4.0),
                                        Text(
                                            'Spec Sparepart: ${sparepart['specSparepart']}'),
                                        SizedBox(height: 4.0),
                                        Text(
                                            'Harga Sparepart: ${sparepart['hargaSparepart']}'),
                                        SizedBox(height: 4.0),
                                        Text(
                                            'Stok Sparepart: ${sparepart['stokSparepart']}'),
                                        SizedBox(height: 8.0),
                                      ],
                                    ),
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Jumlah Item'),
                                            content: TextField(
                                              controller: jumlahItemController,
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                labelText: 'Jumlah Item',
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  int jumlahItem = int.tryParse(
                                                          jumlahItemController
                                                              .text) ??
                                                      0;
                                                  int stokSparepart = sparepart[
                                                          'stokSparepart'] ??
                                                      0;
                                                  if (jumlahItem > 0 &&
                                                      jumlahItem <=
                                                          stokSparepart) {
                                                    _selectItem(
                                                      Map<String, dynamic>.from(
                                                          sparepart),
                                                      jumlahItem,
                                                    );
                                                  } else {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title:
                                                              Text('Kesalahan'),
                                                          content: Text(
                                                              'Jumlah item tidak valid atau melebihi stok sparepart.'),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: Text('OK'),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  }
                                                },
                                                child: Text('OK'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          } else {
                            return Center(
                              child: Text('Tidak ada data sparepart'),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Tutup'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _selectItem(Map<dynamic, dynamic> sparepart, int jumlahItem) {
    int stokSparepart = (sparepart['stokSparepart']) ?? 0;

    if (jumlahItem > 0 && jumlahItem <= stokSparepart) {
      setState(() {
        _items.add({
          'idSparepart': sparepart['idSparepart'],
          'namaSparepart': sparepart['namaSparepart'],
          'hargaSparepart': sparepart['hargaSparepart'].toInt(),
          'jumlahSparepart': jumlahItem,
          'stokSparepart': stokSparepart,
        });
        sparepart['stokSparepart'] = (stokSparepart - jumlahItem).toString();
      });
      _calculateTotalHarga();

      // Update stokSparepart in the database
      DatabaseReference sparepartRef = FirebaseDatabase.instance
          .reference()
          .child('daftarSparepart')
          .child(sparepart['idSparepart']);
      sparepartRef.update({'stokSparepart': stokSparepart - jumlahItem});

      Navigator.of(context).pop(); // Menutup dialog
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Kesalahan'),
            content:
                Text('Jumlah item tidak valid atau melebihi stok sparepart.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _updateStokSparepart(String idSparepart, int stokSparepart) {
    DatabaseReference sparepartRef = FirebaseDatabase.instance
        .reference()
        .child('daftarSparepart')
        .child(idSparepart);
    sparepartRef.update({'stokSparepart': stokSparepart});
  }

  void _updateItem(int index, String field, dynamic value) {
    setState(() {
      _items[index][field] = value;
    });
    _calculateTotalHarga();
  }

  void _removeItem(int index) {
    setState(() {
      Map<String, dynamic> removedItem = _items.removeAt(index);
      String idSparepart = removedItem['idSparepart'];
      int jumlahSparepart = removedItem['jumlahSparepart'];
      int stokSparepart = removedItem['stokSparepart'];
      _updateStokSparepart(idSparepart, stokSparepart);
    });
    _calculateTotalHarga();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaksi Servis'),
        backgroundColor: Color.fromARGB(255, 219, 42, 15),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'ID Servis',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                initialValue: _idServis,
                readOnly: true,
                style: TextStyle(color: Colors.grey),
                decoration: InputDecoration(),
              ),
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
              // Dropdown untuk memilih mekanik berdasarkan idMekanik
              Text(
                'Data Mekanik',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                value: _idMekanik,
                decoration: InputDecoration(labelText: 'ID Mekanik'),
                items: _mekanikList.map((idMekanik) {
                  return DropdownMenuItem<String>(
                    value: idMekanik,
                    child: Text(idMekanik),
                  );
                }).toList(),
                onChanged: _selectMekanik,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _namaMekanikController,
                decoration: InputDecoration(
                  labelText: 'Nama Mekanik',
                ),
                readOnly: true,
              ),
              SizedBox(height: 10),
              Text(
                'Data Pelanggan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                value: _nopol,
                decoration: InputDecoration(labelText: 'Nomor Polisi'),
                items: _nopolList.map((nopol) {
                  return DropdownMenuItem<String>(
                    value: nopol,
                    child: Text(nopol),
                  );
                }).toList(),
                onChanged: _selectPelanggan,
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _namaPelangganController,
                      decoration: InputDecoration(
                        labelText: 'Nama',
                      ),
                      readOnly: true,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _merkKendaraanController,
                      decoration: InputDecoration(
                        labelText: 'Merk SPM',
                      ),
                      readOnly: true,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _tipeKendaraanController,
                      decoration: InputDecoration(
                        labelText: 'Tipe SPM',
                      ),
                      readOnly: true,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Kerusakan',
                ),
                onChanged: (value) {
                  setState(() {
                    _kerusakan = value;
                  });
                },
              ),
              SizedBox(height: 10),
              Text(
                'Data Sparepart',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> item = _items[index];
                  return Card(
                    child: ListTile(
                      title: Text(item['namaSparepart']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ID Sparepart: ${item['idSparepart']}'),
                          Text('Harga Sparepart: ${item['hargaSparepart']}'),
                          Text('Jumlah Sparepart: ${item['jumlahSparepart']}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Konfirmasi'),
                                content: Text(
                                    'Apakah Anda yakin ingin menghapus item ini?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Tidak'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _removeItem(index);
                                    },
                                    child: Text('Ya'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
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
              SizedBox(height: 16.0),
              Text(
                'Total Harga (Sparepart) : Rp ${_totalBayar.toStringAsFixed(0)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              TextFormField(
                decoration: InputDecoration(labelText: 'Biaya Servis'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  double biayaServis = double.tryParse(value) ?? 0;
                  setState(() {
                    _biayaServis = biayaServis;
                    calculateKembalian();
                  });
                },
              ),
              SizedBox(height: 8.0),
              TextFormField(
                controller: diskonController,
                decoration: InputDecoration(
                  labelText: 'Diskon',
                  hintText: 'Masukkan diskon dalam 10/20/dst',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                onChanged: (value) {
                  double discount = double.tryParse(value) ?? 0;
                  setState(() {
                    _totalBayar = calculateTotalPriceAfterDiscount(discount);
                    calculateKembalian();
                  });
                },
              ),
              SizedBox(height: 8.0),
              TextFormField(
                decoration: InputDecoration(labelText: 'Bayar'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kolom bayar tidak boleh kosong';
                  }
                },
                onChanged: (value) {
                  double bayar = double.tryParse(value) ?? 0;
                  setState(() {
                    _bayar = bayar;
                    calculateKembalian();
                  });
                },
              ),
              SizedBox(height: 10),
              Text(
                'Total Biaya : Rp ${(_totalBayar + _biayaServis).toStringAsFixed(0)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Kembalian : Rp ${_kembalian.toStringAsFixed(0)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 219, 42, 15),
                ),
                child: Text('Proses Servis'),
                onPressed: submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
