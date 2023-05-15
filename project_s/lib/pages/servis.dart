import 'package:flutter/material.dart';
import 'home_page.dart';

class ServisPage extends StatefulWidget {
  const ServisPage({Key? key}) : super(key: key);

  @override
  _ServisPageState createState() => _ServisPageState();
}

class _ServisPageState extends State<ServisPage> {
  final List<String> _merkMotorList = [
    'Honda',
    'Yamaha',
    'Suzuki',
    'Kawasaki',
    'Ducati',
    'Harley Davidson',
    'BMW',
    'Aprilia',
    'KTM',
    'Triumph',
  ];

  final _namaPelangganController = TextEditingController();
  final _nomorTeleponController = TextEditingController();
  final _merkMotorController = TextEditingController();
  final _tipeMotorController = TextEditingController();
  final _kerusakanController = TextEditingController();
  final _platNomorController = TextEditingController();

  List<Map<String, String>> _servisList = [];

  void _tambahServis() {
    final servis = {
      'namaPelanggan': _namaPelangganController.text,
      'nomorTelepon': _nomorTeleponController.text,
      'merkMotor': _merkMotorController.text,
      'tipeMotor': _tipeMotorController.text,
      'kerusakan': _kerusakanController.text,
      'platNomor': _platNomorController.text,
    };
    setState(() {
      _servisList.add(servis);
    });
    _clearForm();
  }

  void _ubahServis(int index) {
    final servis = _servisList[index];
    _namaPelangganController.text = servis['namaPelanggan']!;
    _nomorTeleponController.text = servis['nomorTelepon']!;
    _merkMotorController.text = servis['merkMotor']!;
    _tipeMotorController.text = servis['tipeMotor']!;
    _kerusakanController.text = servis['kerusakan']!;
    _platNomorController.text = servis['platNomor']!;
    setState(() {
      _servisList.removeAt(index);
    });
  }

  void _hapusServis(int index) {
    setState(() {
      _servisList.removeAt(index);
    });
  }

  void _clearForm() {
    _namaPelangganController.clear();
    _nomorTeleponController.clear();
    _merkMotorController.clear();
    _tipeMotorController.clear();
    _kerusakanController.clear();
    _platNomorController.clear();
  }

  @override
  void dispose() {
    _namaPelangganController.dispose();
    _nomorTeleponController.dispose();
    _merkMotorController.dispose();
    _tipeMotorController.dispose();
    _kerusakanController.dispose();
    _platNomorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Halaman Servis'),
        backgroundColor: Color.fromARGB(255, 219, 42, 15),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _namaPelangganController,
              decoration: InputDecoration(
                labelText: 'Nama Pelanggan',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _nomorTeleponController,
              decoration: InputDecoration(
                labelText: 'Nomor Telepon',
              ),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField(
              value: null,
              hint: Text('Pilih Merk Motor'),
              items: _merkMotorList
                  .map((merkMotor) => DropdownMenuItem(
                        child: Text(merkMotor),
                        value: merkMotor,
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _merkMotorController.text = value.toString();
                });
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: _tipeMotorController,
              decoration: InputDecoration(
                labelText: 'Tipe Motor',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _kerusakanController,
              decoration: InputDecoration(
                labelText: 'Kerusakan',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _platNomorController,
              decoration: InputDecoration(
                labelText: 'Plat Nomor',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _tambahServis,
              child: Text('Tambah Servis'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _servisList.length,
                itemBuilder: (context, index) {
                  final servis = _servisList[index];
                  return ListTile(
                    title: Text(servis['namaPelanggan']!),
                    subtitle: Text(servis['merkMotor']!),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _hapusServis(index),
                    ),
                    onTap: () => _ubahServis(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
