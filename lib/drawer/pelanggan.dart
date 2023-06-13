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
  Query dbRef = FirebaseDatabase.instance
      .reference()
      .child('daftarPelanggan')
      .orderByChild('merkSpm');

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          'Daftar Pelanggan',
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
        child: FirebaseAnimatedList(
          query: dbRef,
          itemBuilder: (BuildContext context, DataSnapshot snapshot,
              Animation<double> animation, int index) {
            Map daftarPelanggan = snapshot.value as Map;
            String nopol = daftarPelanggan['nopol'];
            String merkSpm = daftarPelanggan['merkSpm'];
            String tipeSpm = daftarPelanggan['tipeSpm'];
            String namaPelanggan = daftarPelanggan['namaPelanggan'];
            String alamat = daftarPelanggan['alamat'];
            String noHp = daftarPelanggan['noHp'];

            return listItem(
              daftarPelanggan: daftarPelanggan,
              nopol: nopol,
              merkSpm: merkSpm,
              tipeSpm: tipeSpm,
              namaPelanggan: namaPelanggan,
              alamat: alamat,
              noHp: noHp,
              snapshot: snapshot,
            );
          },
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
    required DataSnapshot snapshot,
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
            'Nama Pemilik: $namaPelanggan',
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
                        pelangganKey: snapshot.key!,
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
                                  .child(snapshot.key!)
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
