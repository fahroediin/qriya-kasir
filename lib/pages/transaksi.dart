import 'dart:math';
import 'dart:ffi';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:project_s/pages/home_page.dart';
import 'package:uuid/uuid.dart';
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
  String? _namaPembeli;
  double _totalHarga = 0;
  double _bayar = 0;
  double _kembalian = 0;
  final List<Map<String, dynamic>> _items = [];
  List<BluetoothDevice> devices = [];
  BluetoothDevice? selectedDevice;
  BlueThermalPrinter printer = BlueThermalPrinter.instance;

  @override
  void initState() {
    super.initState();
    initializeFirebase();
    generateIdPenjualan();
    _updateDateTime();
    getDevices();
  }

  void getDevices() async {
    devices = await printer.getBondedDevices();
    setState(() {});
  }

  void _updateDateTime() {
    setState(() {
      _formattedDateTime =
          DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
    });
  }

  void initializeFirebase() async {
    await Firebase.initializeApp();
  }

  void _selectPrinter() async {
    if (devices.isEmpty) {
      return;
    }

    final selectedDevice = await showDialog<BluetoothDevice>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Pilih Printer'),
          content: SingleChildScrollView(
            child: ListBody(
              children: devices.map((device) {
                return ListTile(
                  onTap: () {
                    Navigator.of(context).pop(device);
                  },
                  leading: Icon(Icons.print),
                  title: Text(device.name.toString()),
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    if (selectedDevice != null) {
      setState(() {
        this.selectedDevice = selectedDevice;
      });

      printReceipt();
    }
  }

  void printReceipt() {
    if (selectedDevice != null) {
      try {
        // Size
        // 0: Normal, 1: Normal - Bold, 2: Medium - Bold, 3: Large - Bold
        // Align
        // 0: left, 1: center, 2: right
        printer.connect(selectedDevice!).then((_) {
          printer.paperCut();
          printer.printNewLine();
          printer.printCustom(
            'Aira Motor Padangjaya',
            3,
            1,
          );
          printer.printCustom(
            'Jl. Marta Atmaja RT 003/011',
            0,
            1,
          );
          printer.printCustom(
            'Jatinegara, Padangjaya',
            0,
            1,
          );
          printer.printCustom(
            'Majenang 53257 Cilacap',
            0,
            1,
          );
          printer.printCustom(
            'HP 0818-0280-7674',
            1,
            1,
          );
          printer.printNewLine();
          printer.printCustom('ID Penjualan: $_idPenjualan', 1, 0);
          printer.printCustom('Date/Time: $_formattedDateTime', 1, 0);
          printer.printNewLine();
          printer.printCustom('Nama Pembeli: $_namaPembeli', 1, 0);
          printer.printNewLine();
          printer.printCustom('--------------------------------', 0, 0);
          printer.printCustom('Items               Qty   Price', 0, 0);

          for (var item in _items) {
            String itemName = item['namaSparepart'];
            int quantity = item['jumlahSparepart'];
            double price = item['hargaSparepart'];

            // Pad the strings to align the columns
            String paddedItemName = itemName.padRight(18);
            String paddedQuantity = quantity.toString().padLeft(5);
            String paddedPrice = price.toStringAsFixed(0).padLeft(8);

            // Calculate the indentation for quantity and price
            int quantityIndentation = (5 - paddedQuantity.length) ~/ 2;
            int priceIndentation = (8 - paddedPrice.length) ~/ 2;

            // Create the final formatted line
            String formattedLine = '$paddedItemName';
            formattedLine += '${' ' * quantityIndentation}$paddedQuantity';
            formattedLine += '${' ' * priceIndentation}$paddedPrice';

            printer.printCustom(formattedLine, 1, 0);
          }

          printer.printNewLine();
          printer.printCustom('--------------------------------', 0, 0);
          printer.printCustom(
              'Total: Rp ${_totalHarga.toStringAsFixed(0)}', 1, 0);
          printer.printCustom('Bayar: Rp ${_bayar.toStringAsFixed(0)}', 1, 0);
          printer.printCustom(
              'Kembalian: Rp ${_kembalian.toStringAsFixed(0)}', 1, 0);
          printer.printNewLine();
          printer.printCustom('Terima Kasih', 2, 1);
          printer.printCustom('Semoga Hari Anda Menyenangkan!', 1, 1);
          printer.paperCut();
          printer.disconnect();
          // Save the transaction
          saveTransaksiPenjualan();
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Transaksi Berhasil'),
                content: Text('Transaksi berhasil dicetak.'),
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
      } on PlatformException catch (e) {
        print(e.message);
      }
    }
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
      _selectPrinter();
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
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Proses sukses'),
            content: Text('Transaksi berhasil disimpan'),
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
      ).then((_) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      });
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
