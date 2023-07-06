import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class EditHistoriServisPage extends StatefulWidget {
  final String idServis;

  const EditHistoriServisPage({Key? key, required this.idServis})
      : super(key: key);

  @override
  _EditHistoriServisPageState createState() => _EditHistoriServisPageState();
}

class _EditHistoriServisPageState extends State<EditHistoriServisPage> {
  late DatabaseReference dbRef;
  late TextEditingController idServisController;
  late TextEditingController dateTimeController;
  late TextEditingController idMekanikController;
  late TextEditingController namaMekanikController;
  late TextEditingController nopolController;
  late TextEditingController namaPelangganController;
  late TextEditingController merkSpmController;
  late TextEditingController tipeSpmController;
  late TextEditingController keluhanController;
  late TextEditingController biayaServisController;

  @override
  void initState() {
    super.initState();
    dbRef = FirebaseDatabase.instance.reference().child('historiServis');
    idServisController = TextEditingController();
    dateTimeController = TextEditingController();
    idMekanikController = TextEditingController();
    namaMekanikController = TextEditingController();
    nopolController = TextEditingController();
    namaPelangganController = TextEditingController();
    merkSpmController = TextEditingController();
    tipeSpmController = TextEditingController();
    keluhanController = TextEditingController();
    biayaServisController = TextEditingController();
    getHistoriServis();
  }

  @override
  void dispose() {
    idServisController.dispose();
    dateTimeController.dispose();
    idMekanikController.dispose();
    namaMekanikController.dispose();
    nopolController.dispose();
    namaPelangganController.dispose();
    merkSpmController.dispose();
    tipeSpmController.dispose();
    keluhanController.dispose();
    biayaServisController.dispose();
    super.dispose();
  }

  void getHistoriServis() async {
    DataSnapshot snapshot =
        (await dbRef.child(widget.idServis).once()) as DataSnapshot;
    Map<dynamic, dynamic>? historiServis =
        snapshot.value as Map<dynamic, dynamic>?;

    if (historiServis != null) {
      setState(() {
        idServisController.text = historiServis['idServis'];
        dateTimeController.text = historiServis['dateTime'];
        idMekanikController.text = historiServis['idMekanik'];
        namaMekanikController.text = historiServis['namaMekanik'];
        nopolController.text = historiServis['nopol'];
        namaPelangganController.text = historiServis['namaPelanggan'];
        merkSpmController.text = historiServis['merkSpm'];
        tipeSpmController.text = historiServis['tipeSpm'];
        keluhanController.text = historiServis['keluhan'];
        biayaServisController.text = historiServis['biayaServis'].toString();
      });
    }
  }

  void updateHistoriServis() {
    var historiServis = HistoriServis(
      idServis: idServisController.text,
      dateTime: dateTimeController.text,
      idMekanik: idMekanikController.text,
      namaMekanik: namaMekanikController.text,
      nopol: nopolController.text,
      namaPelanggan: namaPelangganController.text,
      merkSpm: merkSpmController.text,
      tipeSpm: tipeSpmController.text,
      keluhan: keluhanController.text,
      biayaServis: double.tryParse(biayaServisController.text) ?? 0.0,
    );

    dbRef.child(widget.idServis).update(historiServis.toJson()).then((_) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Histori Servis'),
        backgroundColor: Color.fromARGB(255, 219, 42, 15),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            TextField(
              controller: idServisController,
              decoration: const InputDecoration(
                labelText: 'ID Servis',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: dateTimeController,
              decoration: const InputDecoration(
                labelText: 'Tanggal dan Waktu',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: idMekanikController,
              decoration: const InputDecoration(
                labelText: 'ID Mekanik',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: namaMekanikController,
              decoration: const InputDecoration(
                labelText: 'Nama Mekanik',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nopolController,
              decoration: const InputDecoration(
                labelText: 'Nomor Polisi',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: namaPelangganController,
              decoration: const InputDecoration(
                labelText: 'Nama Pelanggan',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: merkSpmController,
              decoration: const InputDecoration(
                labelText: 'Merk SPM',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: tipeSpmController,
              decoration: const InputDecoration(
                labelText: 'Tipe SPM',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: keluhanController,
              decoration: const InputDecoration(
                labelText: 'Keluhan',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: biayaServisController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Biaya Servis',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: updateHistoriServis,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  HistoriServis(
      {required String idServis,
      required String dateTime,
      required String idMekanik,
      required String namaMekanik,
      required String nopol,
      required String namaPelanggan,
      required String merkSpm,
      required String tipeSpm,
      required String keluhan,
      required double biayaServis}) {}
}
