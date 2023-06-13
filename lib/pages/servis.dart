import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:project_s/pages/home_page.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

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
  String? _namaPemilik;
  String? _merkKendaraan;
  String? _tipeKendaraan;
  String? _kerusakan;
  List<Map<String, dynamic>> _sparepartItems = [];
  double _totalBayar = 0;
  double _bayar = 0;
  double _biayaServis = 0;
  double _kembalian = 0;

  @override
  void initState() {
    super.initState();
    initializeFirebase();
    generateIdServis();
    updateDateTime();
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
    setState(() {
      _idServis = Uuid().v4();
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
    Map<String, dynamic> data = {
      'idServis': _idServis,
      'dateTime': _formattedDateTime,
      'idMekanik': _idMekanik,
      'namaMekanik': _namaMekanik,
      'nopol': _nopol,
      'namaPemilik': _namaPemilik,
      'merkKendaraan': _merkKendaraan,
      'tipeKendaraan': _tipeKendaraan,
      'kerusakan': _kerusakan,
      'sparepartItems': _sparepartItems,
      'totalBayar': _totalBayar,
      'biayaServis': _biayaServis,
      'bayar': _bayar,
      'kembalian': _kembalian,
    };

    reference.push().set(data).then((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Proses sukses'),
            content: Text('Servis berhasil diproses'),
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

  void addItem() {
    setState(() {
      _sparepartItems.add({
        'idSparepart': '',
        'namaSparepart': '',
        'hargaSparepart': 0,
        'jumlahItem': 0,
        'biayaServis': 0,
      });
    });
  }

  void updateItem(int index, String field, dynamic value) {
    setState(() {
      _sparepartItems[index][field] = value;
      if (field == 'hargaSparepart' || field == 'jumlahItem') {
        double hargaSparepart = _sparepartItems[index]['hargaSparepart'];
        int jumlahItem = _sparepartItems[index]['jumlahItem'];
        _sparepartItems[index]['biayaServis'] = hargaSparepart * jumlahItem;
      }
      calculateTotalBayar();
    });
  }

  void removeItem(int index) {
    setState(() {
      _sparepartItems.removeAt(index);
      calculateTotalBayar();
    });
  }

  void calculateTotalBayar() {
    double total = 0;
    for (var item in _sparepartItems) {
      total += item['biayaServis'];
    }
    setState(() {
      _totalBayar = total;
      calculateKembalian();
    });
  }

  void calculateKembalian() {
    double kembalian = _bayar - (_totalBayar + _biayaServis);
    setState(() {
      _kembalian = kembalian;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Halaman Servis'),
        backgroundColor: Color.fromARGB(255, 219, 42, 15),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'ID Transaksi',
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
              SizedBox(height: 8.0),
              TextFormField(
                decoration: InputDecoration(labelText: 'ID Mekanik'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ID Mekanik tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) {
                  _idMekanik = value;
                },
              ),
              SizedBox(height: 8.0),
              TextFormField(
                decoration: InputDecoration(labelText: 'Nama Mekanik'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama Mekanik tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) {
                  _namaMekanik = value;
                },
              ),
              SizedBox(height: 8.0),
              TextFormField(
                decoration: InputDecoration(labelText: 'Nomor Polisi'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor Polisi tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) {
                  _nopol = value;
                },
              ),
              SizedBox(height: 8.0),
              TextFormField(
                decoration: InputDecoration(labelText: 'Nama Pemilik'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama Pemilik tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) {
                  _namaPemilik = value;
                },
              ),
              SizedBox(height: 8.0),
              TextFormField(
                decoration: InputDecoration(labelText: 'Merk Kendaraan'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Merk Kendaraan tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) {
                  _merkKendaraan = value;
                },
              ),
              SizedBox(height: 8.0),
              TextFormField(
                decoration: InputDecoration(labelText: 'Tipe Kendaraan'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tipe Kendaraan tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) {
                  _tipeKendaraan = value;
                },
              ),
              SizedBox(height: 8.0),
              TextFormField(
                decoration: InputDecoration(labelText: 'Kerusakan'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kerusakan tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) {
                  _kerusakan = value;
                },
              ),
              SizedBox(height: 16.0),
              Text(
                'Data Sparepart',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _sparepartItems.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: TextFormField(
                              onChanged: (value) {
                                updateItem(index, 'idSparepart', value);
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
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: TextFormField(
                              onChanged: (value) {
                                updateItem(index, 'namaSparepart', value);
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
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: TextFormField(
                              onChanged: (value) {
                                double hargaSparepart =
                                    double.tryParse(value) ?? 0;
                                updateItem(
                                    index, 'hargaSparepart', hargaSparepart);
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
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: TextFormField(
                              onChanged: (value) {
                                int jumlahItem = int.tryParse(value) ?? 0;
                                updateItem(index, 'jumlahItem', jumlahItem);
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
                        ),
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            removeItem(index);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 8.0),
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
                  onTap: addItem,
                  borderRadius: BorderRadius.circular(25),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Text('Total Bayar: $_totalBayar'),
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
                decoration: InputDecoration(labelText: 'Bayar'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kolom bayar tidak boleh kosong';
                  }
                  return null;
                },
                onChanged: (value) {
                  double bayar = double.tryParse(value) ?? 0;
                  setState(() {
                    _bayar = bayar;
                    calculateKembalian();
                  });
                },
              ),
              SizedBox(height: 8.0),
              Text('Kembalian: $_kembalian'),
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
