import 'package:connectivity/connectivity.dart';
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
  bool _isLoading = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    initializeFirebase();
    generateIdServis();
    updateDateTime();
    getMekanikList();
    getPelangganList();
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
    final idServis = '$formattedDateTime-${randomNumbers.join('')}';

    setState(() {
      _idServis = idServis;
    });
  }

  void updateDateTime() {
    setState(() {
      _formattedDateTime =
          DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
    });
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

  /// Calculate total price after discount
  double calculateTotalPriceAfterDiscount(double discount) {
    const double minDiscountPercentage = 0.0;
    const double maxDiscountPercentage = 20.0;
    double validDiscount =
        discount.clamp(minDiscountPercentage, maxDiscountPercentage);

    double totalHarga = calculateTotalPriceBeforeDiscount();
    double discountAmount = totalHarga * validDiscount / 100;
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

  void submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_bayar < (_totalBayar + _biayaServis)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nominal Bayar Kurang'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      // Check for internet connectivity
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak ada koneksi internet'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      saveServisData();
    }
  }

  void saveServisData() {
    DatabaseReference reference =
        // ignore: deprecated_member_use
        FirebaseDatabase.instance.reference().child('transaksiServis');

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
        'jumlahSparepart': jumlahSparepart,
      };
    }).toList();

    double diskon = double.tryParse(diskonController.text) ?? 0;
    double totalHarga = 0;
    int totalJumlahSparepart = 0; // Menyimpan total jumlahSparepart

    for (var item in _items) {
      double harga = double.tryParse(item['hargaSparepart'].toString()) ?? 0;
      int jumlah = int.tryParse(item['jumlahSparepart'].toString()) ?? 0;
      totalHarga += harga * jumlah; // Perbaikan perhitungan totalHargaSparepart
      totalJumlahSparepart +=
          jumlah; // Menambahkan jumlahSparepart ke totalJumlahSparepart
    }

    double totalDiskon = totalHarga * (diskon / 100); // Calculate totalDiskon

    double hargaAkhir = totalHarga - totalDiskon;
    double totalAkhir = hargaAkhir + _biayaServis;

    // Mendapatkan bulan dari dateTime
    String bulan = DateFormat('MMMM y', 'id_ID').format(DateTime.now());

    Map<String, dynamic> data = {
      'idServis': _idServis,
      'dateTime': _formattedDateTime,
      'bulan': bulan, // Menambahkan property 'bulan'
      'idMekanik': _idMekanik,
      'namaMekanik': _namaMekanik,
      'nopol': _nopol,
      'namaPelanggan': _namaPelangganController.text,
      'merkSpm': _merkKendaraanController.text,
      'tipeSpm': _tipeKendaraanController.text,
      'keluhan': _kerusakan,
      'items': _items,
      'jumlahItem': totalJumlahSparepart,
      'diskon': diskon,
      'totalDiskon': totalDiskon,
      'totalHargaSparepart': totalHarga,
      'hargaAkhir': _totalBayar,
      'biayaServis': _biayaServis,
      'totalAkhir': totalAkhir,
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
              kerusakan: data['keluhan'],
              items: data['items'],
              totalHarga: data['totalHargaSparepart'],
              diskon: data['diskon'],
              biayaServis: data['biayaServis'],
              hargaAkhir: data['hargaAkhir'],
              bayar: data['bayar'],
              kembalian: data['kembalian'],
            ),
          ),
        );
      },
    );
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
        // ignore: deprecated_member_use
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

  String formatCurrency(int value) {
    final format = NumberFormat("#,###");
    return format.format(value);
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
                        labelText: 'Cari Nama atau Spesifikasi',
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
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Center(
                                    child: Text(
                                      'Data tidak ditemukan',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                      height:
                                          5), // Jarak antara teks dan teks yang ditambahkan
                                  Text(
                                    'Pastikan ejaan dengan benar',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black38,
                                    ),
                                  ),
                                ],
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
                                                              'Jumlah item lebih banyak dari stok yang ada'),
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
                              child: Text('Data tidak ditemukan'),
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
          Navigator.of(context).pop(); // Menutup dialog
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
        if (jumlahItem <= stokSparepart) {
          // Menambahkan pengecekan stok sebelum menambah item baru
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
          Navigator.of(context).pop(); // Menutup dialog
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
                decoration: InputDecoration(
                  labelText: 'ID Mekanik',
                ),
                items: _mekanikList.map((idMekanik) {
                  return DropdownMenuItem<String>(
                    value: idMekanik,
                    child: Text(idMekanik),
                  );
                }).toList(),
                onChanged: _selectMekanik,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pilih Mekanik';
                  }
                  return null;
                },
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
                decoration: InputDecoration(
                  labelText: 'Nomor Polisi',
                ),
                items: _nopolList.map((nopol) {
                  return DropdownMenuItem<String>(
                    value: nopol,
                    child: Text(nopol),
                  );
                }).toList(),
                onChanged: _selectPelanggan,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pilih Pelanggan';
                  }
                  return null;
                },
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
                  labelText: 'Keluhan',
                ),
                onChanged: (value) {
                  setState(() {
                    _kerusakan = value;
                  });
                },
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tidak boleh kosong';
                  }
                  if (value.length < 6) {
                    return 'Minimal 6 karakter';
                  }
                  return null;
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
                                content: Text('Hapus item?'),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Harga (Sparepart)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  Text(
                    'Rp ${formatCurrency(_totalBayar.toInt())}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 10),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kolom bayar tidak boleh kosong';
                  }
                  return null;
                },
              ),

              SizedBox(height: 10),
              TextFormField(
                controller: diskonController,
                decoration: InputDecoration(
                  labelText: 'Diskon (%)',
                  hintText: 'Maksimal diskon 0 s/d 25',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^0*(?:[0-9][0-9]?|25)$')),
                ],
                onChanged: (value) {
                  double discount = double.tryParse(value) ?? 0;

                  if (discount > 25) {
                    diskonController.text =
                        ''; // Reset to empty if the value exceeds the limit
                    discount = 0;
                    // Show the snackbar when the discount exceeds 25
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Maksimal diskon adalah 25%'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                  setState(() {
                    _totalBayar = calculateTotalPriceAfterDiscount(discount);
                    calculateKembalian();
                  });
                },
              ),

              SizedBox(height: 10),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Biaya',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Rp ${formatCurrency((_totalBayar + _biayaServis).toInt())}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
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
              SizedBox(height: 16.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 219, 42, 15),
                ),
                child: _isLoading
                    ? CircularProgressIndicator() // Show loading indicator if _isLoading is true
                    : Text('Proses Servis'),
                onPressed: _isLoading
                    ? null
                    : submitForm, // Disable button when loading
              ),
            ],
          ),
        ),
      ),
    );
  }
}
