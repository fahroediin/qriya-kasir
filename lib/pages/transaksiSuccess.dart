import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/services.dart';
import 'transaksi.dart';

class TransaksiSuccessPage extends StatefulWidget {
  final String idPenjualan;
  final String formattedDateTime;
  final String namaPembeli;
  final double totalHarga;
  final double bayar;
  final double kembalian;
  final List<Map<String, dynamic>> items;

  TransaksiSuccessPage({
    required this.idPenjualan,
    required this.formattedDateTime,
    required this.namaPembeli,
    required this.totalHarga,
    required this.bayar,
    required this.kembalian,
    required this.items,
  });

  @override
  _TransaksiSuccessPageState createState() => _TransaksiSuccessPageState();
}

class _TransaksiSuccessPageState extends State<TransaksiSuccessPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  String? _idPenjualan;
  String _formattedDateTime = '';
  String? _namaPembeli;
  double _totalHarga = 0;
  double _bayar = 0;
  double _kembalian = 0;
  final List<Map<String, dynamic>> _items = [];
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
        // Size
        // 0: Normal, 1: Normal - Bold, 2: Medium - Bold, 3: Large - Bold
        // Align
        // 0: left, 1: center, 2: right
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
            'Jatinegara, Padangjaya',
            0,
            1,
          );
          printer.printCustom(
            'Majenang 53257 Cilacap',
            0,
            1,
          );
          printer.printCustom(
            'HP 0818-0280-7674',
            1,
            1,
          );
          printer.printNewLine();
          printer.printCustom('ID Penjualan: $_idPenjualan', 1, 0);
          printer.printCustom('Date/Time: $_formattedDateTime', 1, 0);
          printer.printNewLine();
          printer.printCustom('Nama Pembeli: $_namaPembeli', 1, 0);
          printer.printNewLine();
          printer.printCustom('--------------------------------', 0, 0);
          printer.printCustom('Items               Qty   Price', 0, 0);

          for (var item in _items) {
            String itemName = item['namaSparepart'];
            int quantity = item['jumlahSparepart'];
            double price = item['hargaSparepart'];

            // Pad the strings to align the columns
            String paddedItemName = itemName.padRight(18);
            String paddedQuantity = quantity.toString().padLeft(5);
            String paddedPrice = price.toStringAsFixed(0).padLeft(8);

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
              'Total: Rp ${_totalHarga.toStringAsFixed(0)}', 1, 0);
          printer.printCustom('Bayar: Rp ${_bayar.toStringAsFixed(0)}', 1, 0);
          printer.printCustom(
              'Kembalian: Rp ${widget.kembalian.toStringAsFixed(0)}', 1, 0);
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
                title: Text('Transaksi Berhasil'),
                content: Text('Transaksi berhasil dicetak.'),
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
      appBar: AppBar(
        title: Text('Transaksi Success'),
        backgroundColor: Color.fromARGB(255, 219, 42, 15),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/success.png',
              width: 200,
            ),
            SizedBox(height: 30),
            Text(
              'Transaksi Berhasil!',
              style: TextStyle(
                fontSize: 24,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Kembalian: ${widget.kembalian.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 30),
            Card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.print),
                      SizedBox(width: 5),
                      Text('Cetak'),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _selectPrinter,
                    icon: Icon(Icons.settings),
                    label: Text('Pilih Printer'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransaksiPenjualanPage(),
                  ),
                );
              },
              child: Text('Transaksi Baru'),
            ),
          ],
        ),
      ),
    );
  }
}
