import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:project_s/pages/home_page.dart';
import 'package:flutter/services.dart';

class InputPelangganPage extends StatefulWidget {
  const InputPelangganPage({Key? key}) : super(key: key);

  @override
  _InputPelangganPageState createState() => _InputPelangganPageState();
}

class _InputPelangganPageState extends State<InputPelangganPage>
    with TickerProviderStateMixin {
  final TextEditingController _idPelangganController = TextEditingController();
  final TextEditingController _namaPelangganController =
      TextEditingController();
  final TextEditingController _nopolAwalanController = TextEditingController();
  final TextEditingController _nopolNomorController = TextEditingController();
  final TextEditingController _nopolAkhiranController = TextEditingController();
  final TextEditingController _tipeSpmController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference();
  List<Map<dynamic, dynamic>> _dataList = [];

  final databaseReference = FirebaseDatabase.instance.reference();

  List<String> merkSepedaMotor = [
    'HONDA',
    'YAMAHA',
    'SUZUKI',
    'KAWASAKI',
    'TVS',
    'BAJAJ',
    'KTM',
    'VESPA',
    'KYMCO',
  ];
  String? selectedMerkSepedaMotor;

  @override
  void initState() {
    super.initState();
    _nopolNomorController.addListener(_onNopolChanged);
    _nopolAkhiranController.addListener(_onNopolChanged);
  }

  @override
  void dispose() {
    _nopolNomorController.removeListener(_onNopolChanged);
    _nopolAkhiranController.removeListener(_onNopolChanged);
    super.dispose();
  }

  void _onNopolChanged() {
    String nopolAwalan = _nopolAwalanController.text.trim();
    String nopolNomor = _nopolNomorController.text.trim();
    String nopolAkhiran = _nopolAkhiranController.text.trim();
    String nopol = nopolAwalan + nopolNomor + nopolAkhiran;

    DatabaseReference pelangganRef =
        _databaseReference.child('daftarPelanggan').child(nopol);
    pelangganRef.get().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        Map<dynamic, dynamic>? values = snapshot.value as Map?;
        setState(() {
          _namaPelangganController.text = values?['namaPelanggan'];
          _tipeSpmController.text = values?['tipeSpm'];
          _alamatController.text = values?['alamat'];
          _noHpController.text = values?['noHp'];
          selectedMerkSepedaMotor = values?['merkSpm'];
        });
      }
    }).catchError((error) {
      final snackBar = SnackBar(
        content: Text('Gagal mengambil data pelanggan'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  Future<void> saveData() async {
    String nopolAwalan = _nopolAwalanController.text.trim();
    String nopolNomor = _nopolNomorController.text.trim();
    String nopolAkhiran = _nopolAkhiranController.text.trim();
    String tipeSpm = _tipeSpmController.text.trim();
    String namaPelanggan = _namaPelangganController.text.trim();
    String alamat = _alamatController.text.trim();
    String noHp = _noHpController.text.trim();
    if (namaPelanggan.isNotEmpty &&
        nopolAwalan.isNotEmpty &&
        nopolNomor.isNotEmpty &&
        nopolAkhiran.isNotEmpty &&
        tipeSpm.isNotEmpty &&
        alamat.isNotEmpty &&
        noHp.isNotEmpty &&
        selectedMerkSepedaMotor != null) {
      String nopol = nopolAwalan + nopolNomor + nopolAkhiran;

      DatabaseReference pelangganRef =
          _databaseReference.child('daftarPelanggan').child(nopol);
      try {
        DataSnapshot snapshot = await pelangganRef.get();
        if (snapshot.value != null) {
          // Data dengan nomor polisi tersebut telah terdaftar
          final snackBar = SnackBar(
            content: Text('Nomor polisi sudah terdaftar'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          // Data belum terdaftar, simpan data baru ke database
          await pelangganRef.set({
            'namaPelanggan': namaPelanggan,
            'nopol': nopol,
            'merkSpm': selectedMerkSepedaMotor!,
            'tipeSpm': tipeSpm,
            'alamat': alamat,
            'noHp': noHp,
          });
          final snackBar = SnackBar(
            content: Text('Data pelanggan berhasil disimpan'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);

          // Clear fields and navigate to the homepage
          _clearFields();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        }
      } catch (error) {
        final snackBar = SnackBar(
          content: Text('Gagal menyimpan data pelanggan: $error'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } else {
      // Show error messages for empty fields
      final snackBar = SnackBar(
        content: Text('Mohon isi semua data terlebih dahulu'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  void _clearFields() {
    _idPelangganController.clear();
    _namaPelangganController.clear();
    _nopolAwalanController.clear();
    _nopolNomorController.clear();
    _nopolAkhiranController.clear();
    _tipeSpmController.clear();
    _alamatController.clear();
    _noHpController.clear();
    setState(() {
      selectedMerkSepedaMotor = null;
    });
  }

  String? _validateInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor harus diisi';
    }
    if (int.tryParse(value) == null) {
      return 'Hanya angka yang diperbolehkan';
    }
    return null;
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
        title: Text('Input Pelanggan'),
        backgroundColor: Color.fromARGB(255, 219, 42, 15),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Nomor Polisi:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nopolAwalanController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Awalan',
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                        LengthLimitingTextInputFormatter(2),
                      ],
                      textCapitalization: TextCapitalization.characters,
                      onChanged: (value) {
                        // Force the value of the TextField to be in capslock.
                        _nopolAwalanController.value = TextEditingValue(
                          text: value.toUpperCase(),
                          selection:
                              TextSelection.collapsed(offset: value.length),
                        );
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Wajib diisi';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _nopolNomorController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Nomor',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Wajib diisi';
                        }
                        if (value.length < 1 || value.length > 4) {
                          return 'Harus terdiri dari 1 hingga 4 digit angka';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _nopolAkhiranController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Akhiran',
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                        LengthLimitingTextInputFormatter(3),
                      ],
                      textCapitalization: TextCapitalization.characters,
                      onChanged: (value) {
                        // Force the value of the TextField to be in capslock.
                        _nopolAkhiranController.value = TextEditingValue(
                          text: value.toUpperCase(),
                          selection:
                              TextSelection.collapsed(offset: value.length),
                        );
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Wajib diisi';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Merk SPM:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedMerkSepedaMotor,
                items: merkSepedaMotor.map((merk) {
                  return DropdownMenuItem<String>(
                    value: merk,
                    child: Text(merk),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedMerkSepedaMotor = value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Merk Sepeda Motor',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pilih Merk Sepeda Motor';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                'Tipe SPM:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _tipeSpmController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Contoh NMAX 2022',
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
              Text(
                'Nama Pemilik:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _namaPelangganController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Nama Pemilik',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
                  LengthLimitingTextInputFormatter(255),
                ],
                textCapitalization: TextCapitalization
                    .words, // Mengubah hanya huruf pertama yang kapital
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Wajib diisi';
                  }
                  if (value.length < 3) {
                    return 'Minimal 3 huruf';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                'Alamat:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _alamatController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Alamat',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Z 0-9/]')),
                ],
                textCapitalization: TextCapitalization.characters,
              ),
              SizedBox(height: 20),
              Text(
                'Nomor HP:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _noHpController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Nomor HP',
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  LengthLimitingTextInputFormatter(13),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Wajib diisi';
                  }
                  if (value.length < 11 || value.length > 13) {
                    return 'Harus terdiri dari 11 hingga 13 digit angka';
                  }
                  return null;
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
      ),
    );
  }
}
