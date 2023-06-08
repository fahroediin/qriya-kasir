import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:project_s/pages/home_page.dart';

class PelangganPage extends StatefulWidget {
  const PelangganPage({Key? key}) : super(key: key);

  @override
  _PelangganPageState createState() => _PelangganPageState();
}

class _PelangganPageState extends State<PelangganPage>
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
    'Honda',
    'Yamaha',
    'Suzuki',
    'Kawasaki',
    'TVS',
    'Bajaj',
    'KTM',
    'Vespa',
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

  @override
  Widget build(BuildContext context) {
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
                    child: TextField(
                      controller: _nopolAwalanController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Awalan',
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _nopolNomorController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Nomor',
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _nopolAkhiranController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Akhiran',
                      ),
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
              TextField(
                controller: _tipeSpmController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Tipe Sepeda Motor (contoh:"Beat 2021")',
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Nama Pemilik:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _namaPelangganController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Nama Pemilik kendaraan',
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Alamat:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _alamatController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Alamat',
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Nomor HP:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _noHpController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Nomor HP',
                ),
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
