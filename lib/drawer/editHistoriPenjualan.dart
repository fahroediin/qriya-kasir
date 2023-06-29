import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:project_s/pages/transaksi.dart';

class EditHistoriPenjualanPage extends StatefulWidget {
  final String idPenjualan;

  const EditHistoriPenjualanPage({Key? key, required this.idPenjualan})
      : super(key: key);

  @override
  State<EditHistoriPenjualanPage> createState() =>
      _EditHistoriPenjualanPageState();
}

class _EditHistoriPenjualanPageState extends State<EditHistoriPenjualanPage> {
  late DatabaseReference dbRef;

  late TextEditingController idPenjualanController;
  late TextEditingController dateTimeController;
  late TextEditingController namaPembeliController;
  late TextEditingController hargaTotalController;
  late TextEditingController diskonController;
  late TextEditingController hargaAkhirController;
  late TextEditingController bayarController;
  late TextEditingController kembalianController;

  @override
  void initState() {
    super.initState();
    dbRef = FirebaseDatabase.instance.reference().child('transaksiPenjualan');
    idPenjualanController = TextEditingController();
    dateTimeController = TextEditingController();
    namaPembeliController = TextEditingController();
    hargaTotalController = TextEditingController();
    diskonController = TextEditingController();
    hargaAkhirController = TextEditingController();
    bayarController = TextEditingController();
    kembalianController = TextEditingController();
    getTransaksiPenjualan();
  }

  void getTransaksiPenjualan() async {
    DataSnapshot snapshot =
        (await dbRef.child(widget.idPenjualan).once()) as DataSnapshot;
    Map<dynamic, dynamic>? transaksiPenjualan =
        snapshot.value as Map<dynamic, dynamic>?;

    if (transaksiPenjualan != null) {
      setState(() {
        idPenjualanController.text = transaksiPenjualan['idPenjualan'];
        dateTimeController.text = transaksiPenjualan['dateTime'];
        namaPembeliController.text = transaksiPenjualan['namaPembeli'];
        hargaTotalController.text = transaksiPenjualan['hargaTotal'].toString();
        diskonController.text = transaksiPenjualan['diskon'].toString();
        hargaAkhirController.text = transaksiPenjualan['hargaAkhir'].toString();
        bayarController.text = transaksiPenjualan['bayar'].toString();
        kembalianController.text = transaksiPenjualan['kembalian'].toString();
      });
    }
  }

  @override
  void dispose() {
    idPenjualanController.dispose();
    dateTimeController.dispose();
    namaPembeliController.dispose();
    hargaTotalController.dispose();
    diskonController.dispose();
    hargaAkhirController.dispose();
    bayarController.dispose();
    kembalianController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Histori Penjualan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            TextField(
              controller: idPenjualanController,
              decoration: const InputDecoration(
                labelText: 'ID Penjualan',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: dateTimeController,
              decoration: const InputDecoration(
                labelText: 'DateTime',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: namaPembeliController,
              decoration: const InputDecoration(
                labelText: 'Nama Pembeli',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: hargaTotalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Harga Total',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: diskonController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Diskon',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: hargaAkhirController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Harga Akhir',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: bayarController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Bayar',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: kembalianController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Kembalian',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                var transaksiPenjualan = TransaksiPenjualan(
                  idPenjualan: idPenjualanController.text,
                  dateTime: dateTimeController.text,
                  namaPembeli: namaPembeliController.text,
                  hargaTotal: double.tryParse(hargaTotalController.text) ?? 0.0,
                  diskon: double.tryParse(diskonController.text) ?? 0.0,
                  hargaAkhir: double.tryParse(hargaAkhirController.text) ?? 0.0,
                  bayar: double.tryParse(bayarController.text) ?? 0.0,
                  kembalian: double.tryParse(kembalianController.text) ?? 0.0,
                );

                dbRef
                    .child(widget.idPenjualan)
                    .update(transaksiPenjualan.toJson())
                    .then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data berhasil diupdate')),
                  );
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal mengupdate data: $error'),
                    ),
                  );
                });
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

TransaksiPenjualan(
    {required String idPenjualan,
    required String dateTime,
    required String namaPembeli,
    required double hargaTotal,
    required double diskon,
    required double hargaAkhir,
    required double bayar,
    required double kembalian}) {}
