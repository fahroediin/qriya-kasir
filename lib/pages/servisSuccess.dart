import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:project_s/pages/ReceiptService.dart';
import 'package:project_s/pages/servis.dart';

class ServisSuccessPage extends StatefulWidget {
  final String idServis;
  final String dateTime;
  final String idMekanik;
  final String namaMekanik;
  final String nopol;
  final String namaPelanggan;
  final String merkSpm;
  final String tipeSpm;
  final String kerusakan;
  final List<Map<String, dynamic>> items;
  final double diskon;
  final double bayar;
  final double totalBiaya;
  final double kembalian;

  ServisSuccessPage({
    required this.idServis,
    required this.dateTime,
    required this.idMekanik,
    required this.namaMekanik,
    required this.nopol,
    required this.namaPelanggan,
    required this.merkSpm,
    required this.tipeSpm,
    required this.kerusakan,
    required this.items,
    required this.diskon,
    required this.bayar,
    required this.totalBiaya,
    required this.kembalian,
  });

  @override
  _ServisSuccessPageState createState() => _ServisSuccessPageState();
}

class _ServisSuccessPageState extends State<ServisSuccessPage> {
  final _formKey = GlobalKey<FormState>();
  String? _idServis;
  String? _tanggalTransaksi;
  String? _namaPembeli;
  double _bayar = 0;
  double _kembalian = 0;
  List<BluetoothDevice> devices = [];
  BluetoothDevice? selectedDevice;
  BlueThermalPrinter printer = BlueThermalPrinter.instance;

  @override
  void initState() {
    super.initState();
    getDevices();
  }

  void getDevices() async {
    devices = await printer.getBondedDevices();
    setState(() {});
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
            'Padangjaya, Majenang ',
            0,
            1,
          );
          printer.printCustom(
            '53257 Cilacap',
            0,
            1,
          );
          printer.printCustom(
            'HP 0818-0280-7674',
            1,
            1,
          );
          printer.printNewLine();
          printer.printCustom('ID Servis: ${widget.idServis}', 1, 0);
          printer.printCustom('Date/Time: ${widget.dateTime}', 1, 0);
          printer.printCustom('ID Mekanik: ${widget.idMekanik}', 1, 0);
          printer.printCustom('Nama Mekanik: ${widget.namaMekanik}', 1, 0);
          printer.printCustom('Nopol: ${widget.nopol}', 1, 0);
          printer.printCustom('Nama Pelanggan: ${widget.namaPelanggan}', 1, 0);
          printer.printCustom('Merk SPM: ${widget.merkSpm}', 1, 0);
          printer.printCustom('Tipe SPM: ${widget.tipeSpm}', 1, 0);
          printer.printCustom('Kerusakan: ${widget.kerusakan}', 1, 0);
          printer.printNewLine();
          printer.printCustom('--------------------------------', 0, 0);
          printer.printCustom('Items Qty Price', 0, 0);
          for (var item in widget.items) {
            String itemName = item['namaSparepart'];
            int quantity = item['jumlahItem'];
            int price = item['hargaSparepart'];

            // Pad the strings to align the columns
            String paddedItemName = itemName.padRight(18);
            String paddedQuantity = quantity.toString().padLeft(4);
            String paddedPrice = price.toString().padLeft(9);

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
              'Harga: Rp ${widget.totalBiaya.toStringAsFixed(0)} (*disc ${widget.diskon.toStringAsFixed(0)}%)',
              1,
              0);
          printer.printCustom(
              'Total: Rp ${widget.totalBiaya.toStringAsFixed(0)}', 1, 0);
          printer.printCustom('Bayar: Rp ${_bayar.toStringAsFixed(0)}', 1, 0);
          printer.printCustom(
              'Kembalian: Rp ${_kembalian.toStringAsFixed(0)}', 1, 0);
          printer.printNewLine();
          printer.printCustom('Terima Kasih', 2, 1);
          printer.printCustom('Semoga Hari Anda Menyenangkan!', 1, 1);
          printer.printNewLine();
          printer.paperCut();
          printer.disconnect();
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Cetak Kuitansi'),
                content: Text('Berhasil mencetak kuitansi'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/success.png',
              width: 200,
            ),
            SizedBox(height: 20),
            Text(
              'Selamat!',
              style: TextStyle(
                fontSize: 30,
                color: Color.fromARGB(255, 102, 103, 102),
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Transaksi Berhasil!',
              style: TextStyle(
                fontSize: 24,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kembalian',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Rp ${widget.kembalian.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 22),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServisPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 219, 42, 15),
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Transaksi Baru',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: ElevatedButton(
                onPressed: _selectPrinter,
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  onPrimary: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: BorderSide(color: Colors.grey),
                ),
                child: Row(
                  children: [
                    Icon(Icons.print),
                    SizedBox(width: 5),
                    Text(
                      'Print Receipt',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReceiptServisPage(),
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    child: Center(
                      child: Text(
                        'Lihat Kuitansi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
