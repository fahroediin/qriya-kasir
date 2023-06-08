import 'package:flutter/material.dart';

class SparepartPage extends StatefulWidget {
  const SparepartPage({Key? key}) : super(key: key);

  @override
  _SparepartPageState createState() => _SparepartPageState();
}

class _SparepartPageState extends State<SparepartPage> {
  TextEditingController _searchController = TextEditingController();

  // Dummy data
  List<Map<String, dynamic>> _dataBarang = [
    {
      "kode_barang": "BRG001",
      "nama_barang": "Ban dalam",
      "merk_barang": "Swallow",
      "tipe_barang": "Tube type",
      "harga_barang": 60000,
      "jumlah_barang": 100,
    },
    {
      "kode_barang": "BRG002",
      "nama_barang": "Oli mesin",
      "merk_barang": "Federal Oil",
      "tipe_barang": "4T",
      "harga_barang": 50000,
      "jumlah_barang": 50,
    },
    {
      "kode_barang": "BRG003",
      "nama_barang": "Busi",
      "merk_barang": "NGK",
      "tipe_barang": "CR7HSA",
      "harga_barang": 20000,
      "jumlah_barang": 150,
    },
    {
      "kode_barang": "BRG004",
      "nama_barang": "Kampas rem",
      "merk_barang": "Brembo",
      "tipe_barang": "SC",
      "harga_barang": 120000,
      "jumlah_barang": 20,
    },
    {
      "kode_barang": "BRG005",
      "nama_barang": "Aki",
      "merk_barang": "GS",
      "tipe_barang": "MF",
      "harga_barang": 300000,
      "jumlah_barang": 30,
    },
    {
      "kode_barang": "BRG006",
      "nama_barang": "Kopling",
      "merk_barang": "FCC",
      "tipe_barang": "Standard",
      "harga_barang": 150000,
      "jumlah_barang": 25,
    },
    {
      "kode_barang": "BRG007",
      "nama_barang": "Kabel kopling",
      "merk_barang": "Kitaco",
      "tipe_barang": "Universal",
      "harga_barang": 25000,
      "jumlah_barang": 75,
    },
    {
      "kode_barang": "BRG008",
      "nama_barang": "Kabel gas",
      "merk_barang": "Motion Pro",
      "tipe_barang": "Universal",
      "harga_barang": 50000,
      "jumlah_barang": 50,
    },
    {
      "kode_barang": "BRG009",
      "nama_barang": "Stang seher",
      "merk_barang": "Aspira",
      "tipe_barang": "High performance",
      "harga_barang": 100000,
      "jumlah_barang": 15,
    },
    {
      "kode_barang": "BRG010",
      "nama_barang": "Kampas kopling",
      "merk_barang": "Mizumoto",
      "tipe_barang": "Standard",
      "harga_barang": 75000,
      "jumlah_barang": 40,
    },
    {
      "kode_barang": "BRG011",
      "nama_barang": "Lampu depan",
      "merk_barang": "Philips",
      "tipe_barang": "Halogen",
      "harga_barang": 35000,
      "jumlah_barang": 90,
    },
    {
      "kode_barang": "BRG012",
      "nama_barang": "Lampu belakang",
      "merk_barang": "Hella",
      "tipe_barang": "LED",
      "harga_barang": 50000,
      "jumlah_barang": 70,
    },
    {
      "kode_barang": "BRG013",
      "nama_barang": "Kabel busi",
      "merk_barang": "Nology",
      "tipe_barang": "Hotwires",
      "harga_barang": 125000,
      "jumlah_barang": 35,
    },
    {
      "kode_barang": "BRG014",
      "nama_barang": "Filter udara",
      "merk_barang": "K&N",
      "tipe_barang": "High flow",
      "harga_barang": 200000,
      "jumlah_barang": 25,
    },
    {
      "kode_barang": "BRG015",
      "nama_barang": "Rantai",
      "merk_barang": "RK",
      "tipe_barang": "Standard",
      "harga_barang": 175000,
      "jumlah_barang": 30,
    },
    {
      "kode_barang": "BRG016",
      "nama_barang": "Spakbor depan",
      "merk_barang": "ACERBIS",
      "tipe_barang": "MX",
      "harga_barang": 80000,
      "jumlah_barang": 45,
    },
    {
      "kode_barang": "BRG017",
      "nama_barang": "Spakbor belakang",
      "merk_barang": "Polisport",
      "tipe_barang": "Supermoto",
      "harga_barang": 100000,
      "jumlah_barang": 20,
    },
    {
      "kode_barang": "BRG018",
      "nama_barang": "Radiator",
      "merk_barang": "Mishimoto",
      "tipe_barang": "Performance",
      "harga_barang": 500000,
      "jumlah_barang": 10,
    },
    {
      "kode_barang": "BRG019",
      "nama_barang": "Bearing roda",
      "merk_barang": "NTN",
      "tipe_barang": "6203",
      "harga_barang": 35000,
      "jumlah_barang": 80,
    },
    {
      "kode_barang": "BRG020",
      "nama_barang": "Kampas rem belakang",
      "merk_barang": "Ferodo",
      "tipe_barang": "Platinum",
      "harga_barang": 150000,
      "jumlah_barang": 15,
    },
  ];

  // Filtered data based on search text
  List<Map<String, dynamic>> _filteredDataBarang = [];

  @override
  void initState() {
    super.initState();
    _filteredDataBarang = List.from(_dataBarang);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 219, 42, 15),
        title: Text('Data Barang'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _filteredDataBarang = _dataBarang
                      .where((barang) =>
                          barang['nama_barang']
                              .toLowerCase()
                              .contains(value.toLowerCase()) ||
                          barang['kode_barang']
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                      .toList();
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari barang...',
                suffixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredDataBarang.length,
                itemBuilder: (context, index) {
                  final barang = _filteredDataBarang[index];
                  return Card(
                    child: ListTile(
                      title: Text(
                        '${barang['nama_barang']} (${barang['merk_barang']} - ${barang['tipe_barang']})',
                      ),
                      subtitle: Text(
                        'Kode Barang: ${barang['kode_barang']}\nHarga: Rp. ${barang['harga_barang']}\nJumlah: ${barang['jumlah_barang']}',
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _dataBarang.remove(barang);
                            _filteredDataBarang.remove(barang);
                          });
                        },
                      ),
                      onTap: () {
// Open edit page
                      },
                    ),
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
