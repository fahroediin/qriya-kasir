import 'dart:ffi';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:project_s/pages/home_page.dart';
import 'package:project_s/pages/transaksiSuccess.dart';
import 'package:intl/intl.dart';

class TransaksiPenjualanPage extends StatefulWidget {
  @override
  _TransaksiPenjualanPageState createState() => _TransaksiPenjualanPageState();
}

class _TransaksiPenjualanPageState extends State<TransaksiPenjualanPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  String? _idPenjualan;
  String _formattedDateTime = '';
  String _formattedMonth = DateFormat('MM').format(DateTime.now());
  String? _namaPembeli;
  double _totalHarga = 0;
  double _bayar = 0;
  double _kembalian = 0;
  double harga = 0;
  final List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> selectedSpareparts = [];
  TextEditingController diskonController = TextEditingController();
  Query dbRef = FirebaseDatabase.instance.reference().child('daftarSparepart');
  TextEditingController searchController = TextEditingController();
  TextEditingController bayarController = TextEditingController();

  List<Map> searchResultList = [];
  List<Map> sparepartList = [];
  List<Map> filteredList = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    initializeFirebase();
    generateIdPenjualan();
    _updateDateTime();
    filteredList = [];
  }

  void searchList(String query) {
    searchResultList.clear();

    if (query.isNotEmpty) {
      List<Map> searchResult = sparepartList
          .where((sparepart) =>
              sparepart['namaSparepart']
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              sparepart['specSparepart']
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();

      if (searchResult.isNotEmpty) {
        setState(() {
          isSearching = true;
          searchResultList.add(searchResult.first);
        });
      } else {
        setState(() {
          isSearching = false;
        });
      }
    } else {
      setState(() {
        isSearching = false;
      });
    }
  }

  void _updateDateTime() {
    setState(() {
      _formattedDateTime =
          DateFormat('dd/MM/yyyy HH:mm:ss').format(_selectedDate);
      _formattedMonth = DateFormat('MM').format(_selectedDate);
    });
  }

  List<String> _namaBulan = [
    '', // Indeks 0 tidak digunakan
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

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

      // Check if the buyer's name is empty or null
      if (_namaPembeli == null || _namaPembeli!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nama pembeli tidak boleh kosong'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      // Check if there are any selected spare parts
      if (_items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pilih sparepart terlebih dahulu'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        return; // Exit the method if there are no selected spare parts
      }

      // Update the stock of spare parts
      for (var sparepart in selectedSpareparts) {
        DatabaseReference sparepartRef = FirebaseDatabase.instance
            .reference()
            .child('daftarSparepart')
            .child(sparepart['idSparepart']);
        int stokSparepart = sparepart['stokSparepart'];
        int jumlahSparepart = sparepart['jumlahSparepart'];
        sparepartRef.update({'stokSparepart': stokSparepart - jumlahSparepart});
      }

      // Check if the payment amount is sufficient
      if (_totalHarga > _bayar) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nominal Bayar Kurang'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );

        return; // Exit the method if the payment amount is insufficient
      }

      // Save the transaction data
      saveTransaksiPenjualan();
    }
  }

  void _calculateTotalHarga() {
    double totalHarga = 0;
    for (var item in _items) {
      double harga = double.tryParse(item['hargaSparepart'].toString()) ?? 0;
      int jumlah = int.tryParse(item['jumlahSparepart'].toString()) ?? 0;
      totalHarga += harga * jumlah;
    }

    double diskon = double.tryParse(diskonController.text) ?? 0;
    double diskonAmount =
        totalHarga * (diskon / 100); // Mengubah diskon menjadi persen
    totalHarga -= diskonAmount;

    setState(() {
      _totalHarga = totalHarga;
    });
  }

  void _calculateKembalian(double jumlahBayar) {
    double kembalian = jumlahBayar - _totalHarga;
    setState(() {
      _kembalian = max(0, kembalian);
    });
  }

  String formatCurrency(int value) {
    final format = NumberFormat("#,###");
    return format.format(value);
  }

  void saveTransaksiPenjualan() {
    DatabaseReference reference =
        FirebaseDatabase.instance.reference().child('transaksiPenjualan');

    List<Map<String, dynamic>> items = _items.map((item) {
      int jumlahSparepart = item['jumlahSparepart'];
      int totalJumlahItem = 0;

      // Menghitung total jumlahItem berdasarkan jumlahSparepart
      if (jumlahSparepart != null) {
        totalJumlahItem = jumlahSparepart.toInt();
      }

      return {
        'idSparepart': item['idSparepart'],
        'namaSparepart': item['namaSparepart'],
        'hargaSparepart': item['hargaSparepart'].toInt(),
        'merkSparepart': item['merkSparepart'],
        'jumlahSparepart': jumlahSparepart,
      };
    }).toList();

    double diskon = double.tryParse(diskonController.text) ?? 0;

    double totalHarga = 0;
    int totalJumlahSparepart = 0; // Menyimpan total jumlahSparepart

    for (var item in _items) {
      double harga = double.tryParse(item['hargaSparepart'].toString()) ?? 0;
      int jumlah = int.tryParse(item['jumlahSparepart'].toString()) ?? 0;
      totalHarga += harga * jumlah;
      totalJumlahSparepart +=
          jumlah; // Menambahkan jumlahSparepart ke totalJumlahSparepart
    }

    double totalDiskon = totalHarga * (diskon / 100); // Calculate totalDiskon

    double hargaAkhir = totalHarga - totalDiskon;
    String namaBulan = DateFormat('MMMM yyyy', 'id_ID').format(
        _selectedDate); // Menggunakan DateFormat untuk mendapatkan nama bulan

    Map<String, dynamic> data = {
      'idPenjualan': _idPenjualan,
      'bulan': namaBulan,
      'dateTime': _formattedDateTime,
      'namaPembeli': _namaPembeli,
      'items': items,
      'totalHarga': totalHarga,
      'hargaAkhir': hargaAkhir,
      'jumlahItem':
          totalJumlahSparepart, // Menggunakan totalJumlahSparepart sebagai jumlahItem
      'bayar': _bayar,
      'kembalian': _kembalian,
      'diskon': diskon.toInt(),
      'totalDiskon': totalDiskon,
    };

    reference.push().set(data).then((_) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TransaksiSuccessPage(
            idPenjualan: data['idPenjualan'],
            tanggalTransaksi: data['dateTime'] ?? '',
            namaPembeli: data['namaPembeli'],
            totalHarga: totalHarga,
            bayar: data['bayar'].toDouble(),
            kembalian: _kembalian.toDouble(),
            items: List<Map<String, dynamic>>.from(data['items']),
            diskon: diskon.toDouble(),
            hargaAkhir: hargaAkhir,
          ),
        ),
      );
    });
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        List<Map<String, dynamic>> selectedSpareparts = [];
        List<Map<dynamic, dynamic>> sparepartList = [];
        List<Map<dynamic, dynamic>> filteredSparepartList = [];
        TextEditingController jumlahItemController = TextEditingController();
        TextEditingController searchController =
            TextEditingController(); // Tambahkan controller untuk TextField pencarian

        // Fungsi untuk memperbarui daftar sparepart berdasarkan pencarian
        void updateFilteredSparepartList() {
          filteredSparepartList = sparepartList.where((sparepart) {
            String namaSparepart =
                sparepart['namaSparepart'].toString().toLowerCase();
            String specSparepart =
                sparepart['specSparepart'].toString().toLowerCase();
            String searchKeyword = searchController.text.toLowerCase();
            return namaSparepart.contains(searchKeyword) ||
                specSparepart.contains(searchKeyword);
          }).toList();
        }

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Daftar Sparepart'),
              content: Container(
                width: double.maxFinite,
                child: Column(
                  children: [
                    TextField(
                      controller:
                          searchController, // Tambahkan controller ke TextField pencarian
                      decoration: InputDecoration(
                        labelText: 'Cari Sparepart',
                      ),
                      onChanged: (value) {
                        updateFilteredSparepartList();
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
                              updateFilteredSparepartList(); // Perbarui daftar sparepart berdasarkan data terbaru
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
                                      '${sparepart['namaSparepart']}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 8.0),
                                        Text(
                                          'ID: ${sparepart['idSparepart']}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ),
                                        SizedBox(height: 4.0),
                                        Text(
                                          'Merk: ${sparepart['merkSparepart']}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 18),
                                        ),
                                        SizedBox(height: 4.0),
                                        Text(
                                          'Spesifikasi: ${sparepart['specSparepart']}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 18),
                                        ),
                                        SizedBox(height: 4.0),
                                        Text(
                                          'Harga: Rp ${formatCurrency(sparepart['hargaSparepart'])}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 18),
                                        ),
                                        SizedBox(height: 4.0),
                                        Text(
                                          'Stok: ${sparepart['stokSparepart']}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ),
                                        SizedBox(height: 8.0),
                                      ],
                                    ),
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Jumlah'),
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
                                                              'Jumlah item lebih banyak / kurang dari stok yang ada'),
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
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
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
      // Check if the sparepart already exists in the list
      int existingItemIndex = _items.indexWhere(
          (item) => item['idSparepart'] == sparepart['idSparepart']);

      if (existingItemIndex != -1) {
        // If the sparepart already exists, update the quantity instead of adding a new item
        int existingQuantity = _items[existingItemIndex]['jumlahSparepart'];
        int newQuantity = existingQuantity + jumlahItem;
        if (newQuantity <= stokSparepart) {
          setState(() {
            _items[existingItemIndex]['jumlahSparepart'] = newQuantity;
          });
          _calculateTotalHarga();
          // Update stokSparepart in the database
          _updateStokSparepart(
              sparepart['idSparepart'], stokSparepart - jumlahItem);
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Kesalahan'),
                content: Text('Jumlah item lebih banyak dari stok yang ada'),
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
          return; // Menambahkan return agar stok tidak dikurangi jika terjadi kesalahan
        }
      } else {
        setState(() {
          _items.add({
            'idSparepart': sparepart['idSparepart'],
            'namaSparepart': sparepart['namaSparepart'],
            'hargaSparepart': sparepart['hargaSparepart'].toInt(),
            'merkSparepart': sparepart['merkSparepart'],
            'jumlahSparepart': jumlahItem,
            'stokSparepart': stokSparepart,
          });
        });
        _calculateTotalHarga();
        // Update stokSparepart in the database
        _updateStokSparepart(
            sparepart['idSparepart'], stokSparepart - jumlahItem);
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Kesalahan'),
            content:
                Text('Jumlah item lebih banyak / kurang dari stok yang ada'),
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
    var textStyle = TextStyle(fontWeight: FontWeight.bold);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            _items.forEach((item) {
              _updateStokSparepart(item['idSparepart'], item['stokSparepart']);
            });

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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama Pembeli tidak boleh kosong';
                  }
                  return null; // Return null if the value is valid
                },
              ),
              SizedBox(height: 10),
              Text(
                'Data Sparepart',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
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
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  Text(
                    'Rp ${formatCurrency(_totalHarga.toInt())}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 10),
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
                  setState(() {
                    _calculateTotalHarga();
                  });
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: bayarController,
                decoration: InputDecoration(labelText: 'Bayar'),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                onChanged: (value) {
                  setState(() {
                    _bayar = double.parse(value);
                    _calculateKembalian(_bayar);
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Kolom bayar tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kembalian',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  Text(
                    'Rp ${formatCurrency(_kembalian.toInt())}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
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
