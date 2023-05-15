import 'package:flutter/material.dart';
import 'package:project_s/pages/home_page.dart';

class PenjualanPage extends StatefulWidget {
  @override
  _PenjualanPageState createState() => _PenjualanPageState();
}

class _PenjualanPageState extends State<PenjualanPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  String? _idPenjualan;
  String? _nama;
  String? _item;
  int? _jumlahItem;
  int? _hargaItem;
  int? _bayar;
  int? _totalHarga;
  int? _kembalian;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _totalHarga = _hargaItem! * _jumlahItem!;
        _kembalian = _bayar! - _totalHarga!;
      });
    }
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
        title: Text('Halaman Penjualan'),
        backgroundColor: Color.fromARGB(255, 219, 42, 15),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'ID Penjualan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  onSaved: (value) => _idPenjualan = value,
                  decoration: InputDecoration(
                    hintText: 'Masukkan ID Penjualan',
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Nama',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  onSaved: (value) => _nama = value,
                  decoration: InputDecoration(
                    hintText: 'Masukkan Nama',
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Tanggal Transaksi',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            setState(() {
                              _selectedDate = selectedDate;
                            });
                          }
                        },
                        child: Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(_selectedDate),
                          );
                          if (selectedTime != null) {
                            setState(() {
                              _selectedDate = DateTime(
                                _selectedDate.year,
                                _selectedDate.month,
                                _selectedDate.day,
                                selectedTime.hour,
                                selectedTime.minute,
                              );
                            });
                          }
                        },
                        child: Text(
                          '${_selectedDate.hour}:${_selectedDate.minute}',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'Item',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  onSaved: (value) => _item = value,
                  decoration: InputDecoration(
                    hintText: 'Masukkan Nama Item',
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Jumlah Item',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  onSaved: (value) => _jumlahItem = int.tryParse(value!),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Masukkan Jumlah Item',
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Harga Item',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  onSaved: (value) => _hargaItem = int.tryParse(value!),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Masukkan Harga Item',
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Bayar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextFormField(
                  onSaved: (value) => _bayar = int.tryParse(value!),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Masukkan Jumlah Uang Bayar',
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Hitung Total'),
                ),
                SizedBox(height: 10),
                if (_totalHarga != null && _kembalian != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Total Harga: Rp $_totalHarga',
                        style: textStyle,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Bayar: Rp $_bayar',
                        style: textStyle,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Kembalian: Rp $_kembalian',
                        style: textStyle,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
