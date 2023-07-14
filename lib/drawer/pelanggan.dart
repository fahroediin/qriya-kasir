import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_s/pages/home_page.dart';
import 'update_pelanggan.dart';

class Pelanggan extends StatefulWidget {
  const Pelanggan({Key? key}) : super(key: key);

  @override
  _PelangganState createState() => _PelangganState();
}

class _PelangganState extends State<Pelanggan> {
  TextEditingController searchController = TextEditingController();
  Query dbRef = FirebaseDatabase.instance
      .reference()
      .child('daftarPelanggan')
      .orderByChild('merkSpm');

  late List<Map> filteredList;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    filteredList = [];
  }

  void searchList(String query) {
    if (query.isNotEmpty) {
      setState(() {
        isSearching = true;
        filteredList = filteredList
            .where((daftarPelanggan) => daftarPelanggan['nopol']
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      });
    }
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
            fontFamily: 'Roboto',
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
              padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: searchController,
                onChanged: searchList,
                decoration: InputDecoration(
                  labelText: 'Cari Nomor Polisi',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
            Expanded(
              child: isSearching
                  ? SingleChildScrollView(
                      child: Column(
                        children: filteredList.map((daftarPelanggan) {
                          return Column(
                            children: [
                              listItem(
                                daftarPelanggan: daftarPelanggan,
                                nopol: daftarPelanggan['nopol'],
                                merkSpm: daftarPelanggan['merkSpm'],
                                tipeSpm: daftarPelanggan['tipeSpm'],
                                namaPelanggan: daftarPelanggan['namaPelanggan'],
                                alamat: daftarPelanggan['alamat'],
                                noHp: daftarPelanggan['noHp'],
                                snapshot:
                                    null, // Tidak digunakan pada pencarian
                              ),
                              SizedBox(height: 8),
                              Divider(color: Colors.grey[400]),
                            ],
                          );
                        }).toList(),
                      ),
                    )
                  : FirebaseAnimatedList(
                      query: dbRef,
                      itemBuilder: (BuildContext context, DataSnapshot snapshot,
                          Animation<double> animation, int index) {
                        Map daftarPelanggan = snapshot.value as Map;
                        daftarPelanggan['key'] = snapshot.key;

                        return Column(
                          children: [
                            listItem(
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
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget listItem({
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
                        title: Text('Confirm'),
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
