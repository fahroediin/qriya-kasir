import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_s/drawer/sparepart.dart';
import 'package:project_s/pages/home_page.dart';
import 'update_pelanggan.dart';

class Pelanggan extends StatefulWidget {
  const Pelanggan({Key? key}) : super(key: key);

  @override
  _PelangganState createState() => _PelangganState();
}

class _PelangganState extends State<Pelanggan> {
  Query dbRef = FirebaseDatabase.instance.reference().child('daftarPelanggan');
  int itemCount = 0;
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  bool hasData = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    Query query = dbRef;

    if (isSearching) {
      query = dbRef
          .orderByChild('nopol')
          .equalTo(searchController.text.toUpperCase());
    }

    DataSnapshot snapshot = await query.get();

    if (snapshot.exists) {
      setState(() {
        itemCount = snapshot.children.length;
        hasData = true;
      });
    } else {
      setState(() {
        itemCount = 0;
        hasData = false;
      });
    }
  }

  void searchList(String query) {
    setState(() {
      isSearching = query.isNotEmpty;
    });
    searchController.text = query.toUpperCase();
    fetchData();
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
              PageRouteBuilder(
                transitionDuration: Duration(milliseconds: 200),
                pageBuilder: (_, __, ___) => HomePage(),
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              ),
            );
          },
        ),
        title: Text(
          'Data Pelanggan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 219, 42, 15),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Total Pelanggan : $itemCount',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        searchList(value);
                        searchController.selection = TextSelection.fromPosition(
                          TextPosition(offset: searchController.text.length),
                        );
                      },
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: 'Cari Nomor Polisi',
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            searchList('');
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
            Expanded(
              child: hasData
                  ? FirebaseAnimatedList(
                      query: dbRef,
                      itemBuilder: (BuildContext context, DataSnapshot snapshot,
                          Animation<double> animation, int index) {
                        Map daftarPelanggan = snapshot.value as Map;
                        daftarPelanggan['key'] = snapshot.key;

                        if (isSearching &&
                            daftarPelanggan['nopol'] !=
                                searchController.text.toUpperCase()) {
                          return SizedBox(); // Skip this item if it doesn't match the search query
                        }

                        return Column(
                          children: [
                            buildListItem(
                              daftarPelanggan: daftarPelanggan,
                              nopol: daftarPelanggan['nopol'],
                              merkSpm: daftarPelanggan['merkSpm'],
                              tipeSpm: daftarPelanggan['tipeSpm'],
                              namaPelanggan: daftarPelanggan['namaPelanggan'],
                              alamat: daftarPelanggan['alamat'],
                              noHp: daftarPelanggan['noHp'],
                              snapshot: snapshot,
                            ),
                            SizedBox(height: 8),
                            Divider(color: Colors.grey[400]),
                          ],
                        );
                      },
                    )
                  : buildNoDataWidget(), // Show buildNoDataWidget when there is no data
            ),
          ],
        ),
      ),
    );
  }

  Widget buildListItem({
    required Map daftarPelanggan,
    required String nopol,
    required String merkSpm,
    required String tipeSpm,
    required String namaPelanggan,
    required String alamat,
    required String noHp,
    required DataSnapshot? snapshot,
  }) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      height: 210,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 232, 192, 145),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nomor Polisi: $nopol',
            style: GoogleFonts.lato(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Merk SPM: $merkSpm',
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Tipe SPM: $tipeSpm',
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Nama Pelanggan: $namaPelanggan',
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Alamat: $alamat',
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Nomor HP: $noHp',
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UpdatePelanggan(
                        pelangganKey: snapshot!.key!,
                      ),
                    ),
                  );
                },
                child: Icon(
                  Icons.edit,
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
              SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Konfirmasi'),
                        content: Text('Hapus data pelanggan?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Tutup dialog
                            },
                            child: Text('No'),
                          ),
                          TextButton(
                            onPressed: () {
                              // Hapus data
                              FirebaseDatabase.instance
                                  .reference()
                                  .child('daftarPelanggan')
                                  .child(snapshot!.key!)
                                  .remove();
                              Navigator.of(context).pop(); // Tutup dialog
                            },
                            child: Text('Yes'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Icon(
                  Icons.delete,
                  color: Colors.red[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget buildNoDataWidget() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Center(
        child: Text(
          'Data tidak ditemukan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      SizedBox(height: 5), // Jarak antara teks dan teks yang ditambahkan
      Text(
        'Pastikan ejaan dengan benar',
        style: TextStyle(
          fontSize: 14,
          color: Colors.black38,
        ),
      ),
    ],
  );
}
