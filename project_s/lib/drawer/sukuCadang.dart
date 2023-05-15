import 'package:flutter/material.dart';
import 'package:project_s/pages/home_page.dart';

class SukuCadangPage extends StatefulWidget {
  @override
  _SukuCadangPageState createState() => _SukuCadangPageState();
}

class _SukuCadangPageState extends State<SukuCadangPage> {
  List<Map<String, dynamic>> _barangData = [];
  String? _selectedNama;
  String? _selectedMerk;
  int? _selectedJumlah;
  int? _selectedHarga;

  void _tambahData() {
    setState(() {
      _barangData.add({
        'nama': _selectedNama!,
        'merk': _selectedMerk!,
        'jumlah': _selectedJumlah!,
        'harga': _selectedHarga!,
      });
    });
  }

  void _editData(int index) {
    setState(() {
      _barangData[index]['nama'] = _selectedNama!;
      _barangData[index]['merk'] = _selectedMerk!;
      _barangData[index]['jumlah'] = _selectedJumlah!;
      _barangData[index]['harga'] = _selectedHarga!;
    });
  }

  void _hapusData(int index) {
    setState(() {
      _barangData.removeAt(index);
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
        title: Text('Halaman Suku Cadang'),
        backgroundColor: Color.fromARGB(255, 219, 42, 15),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Nama Sparepart',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              onChanged: (value) => _selectedNama = value,
              decoration: InputDecoration(
                hintText: 'Masukkan nama sparepart',
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Merk Sparepart',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              onChanged: (value) => _selectedMerk = value,
              decoration: InputDecoration(
                hintText: 'Masukkan merk sparepart',
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Jumlah',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              onChanged: (value) => _selectedJumlah = int.tryParse(value) ?? 0,
              decoration: InputDecoration(
                hintText: 'Masukkan jumlah sparepart',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            Text(
              'Harga',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              onChanged: (value) => _selectedHarga = int.tryParse(value) ?? 0,
              decoration: InputDecoration(
                hintText: 'Masukkan harga sparepart',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _tambahData,
              child: Text('Tambah Data'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _barangData.length,
                itemBuilder: (context, index) {
                  final barang = _barangData[index];
                  return ListTile(
                    title: Text('${barang['nama']} - ${barang['merk']}'),
                    subtitle: Text(
                        'Jumlah: ${barang['jumlah']} - Harga: ${barang['harga']}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _hapusData(index),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Edit Data'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Nama Sparepart',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextField(
                                  onChanged: (value) => _selectedNama = value,
                                  decoration: InputDecoration(
                                    hintText: 'Masukkan nama sparepart',
                                  ),
                                  controller: TextEditingController(
                                      text: barang['nama']),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Merk Sparepart',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextField(
                                  onChanged: (value) => _selectedMerk = value,
                                  decoration: InputDecoration(
                                    hintText: 'Masukkan merk sparepart',
                                  ),
                                  controller: TextEditingController(
                                      text: barang['merk']),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Jumlah',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextField(
                                  onChanged: (value) => _selectedJumlah =
                                      int.tryParse(value) ?? 0,
                                  decoration: InputDecoration(
                                    hintText: 'Masukkan jumlah sparepart',
                                  ),
                                  keyboardType: TextInputType.number,
                                  controller: TextEditingController(
                                      text: barang['jumlah'].toString()),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Harga',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextField(
                                  onChanged: (value) =>
                                      _selectedHarga = int.tryParse(value) ?? 0,
                                  decoration: InputDecoration(
                                    hintText: 'Masukkan harga sparepart',
                                  ),
                                  keyboardType: TextInputType.number,
                                  controller: TextEditingController(
                                      text: barang['harga'].toString()),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () {
                                  _editData(index);
                                  Navigator.pop(context);
                                },
                                child: Text('Simpan'),
                              ),
                            ],
                          );
                        },
                      );
                    },
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
