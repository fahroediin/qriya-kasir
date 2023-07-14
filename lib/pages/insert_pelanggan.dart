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

  void saveData() {
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

      databaseReference.child('daftarPelanggan').child(nopol).set({
        'namaPelanggan': namaPelanggan,
        'nopol': nopol,
        'merkSpm': selectedMerkSepedaMotor!,
        'tipeSpm': tipeSpm,
        'alamat': alamat,
        'noHp': noHp,
      }).then((_) {
        final snackBar =
            SnackBar(content: Text('Data pelanggan berhasil disimpan'));
        ScaffoldMessenger.of(context).showSnackBar(
          snackBar,
        );
        _clearFields();
      }).catchError((error) {
        final snackBar =
            SnackBar(content: Text('Gagal menyimpan data pelanggan: $error'));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: AnimationController(
                  vsync: this,
                  duration: Duration(milliseconds: 500),
                ),
                curve: Curves.easeOut,
              )),
              child: snackBar,
            ),
          ),
        );
      });
    } else {
      final snackBar = SnackBar(content: Text('Mohon lengkapi semua field'));
      ScaffoldMessenger.of(context).showSnackBar(
        snackBar,
      );
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

  @override
  void dispose() {
    _idPelangganController.dispose();
    _namaPelangganController.dispose();
    _nopolAwalanController.dispose();
    _nopolNomorController.dispose();
    _nopolAkhiranController.dispose();
    _tipeSpmController.dispose();
    _alamatController.dispose();
    _noHpController.dispose();
    super.dispose();
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
                textCapitalization: TextCapitalization.characters,
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
