import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:project_s/pages/home_page.dart';
import 'update_data_mekanik.dart';

class MekanikPage extends StatefulWidget {
  const MekanikPage({Key? key}) : super(key: key);

  @override
  State<MekanikPage> createState() => _MekanikPageState();
}

class _MekanikPageState extends State<MekanikPage> {
  Query dbRef = FirebaseDatabase.instance.ref().child('mekanik');
  DatabaseReference reference =
      FirebaseDatabase.instance.ref().child('mekanik');

  Widget listItem({required Map mekanik}) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(5),
      height: 110,
      color: Color.fromARGB(255, 211, 176, 900),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ID: ${mekanik['idMekanik']}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            'Nama: ${mekanik['namaMekanik']}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            'Alamat: ${mekanik['alamat']}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            'Nomor HP: ${mekanik['noHp']}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  // Implementasi navigasi ke halaman UpdateRecord dengan membawa data mekanik
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            UpdateRecord(mekanikKey: mekanik['key'])),
                  );
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.edit,
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 6,
              ),
              GestureDetector(
                onTap: () {
                  reference.child(mekanik['key']).remove();
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.delete,
                      color: Colors.red[700],
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
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
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
        title: Text('Data Mekanik'),
        backgroundColor: Color.fromARGB(255, 219, 42, 15),
      ),
      body: Container(
        height: double.infinity,
        child: FirebaseAnimatedList(
          query: dbRef,
          itemBuilder: (BuildContext context, DataSnapshot snapshot,
              Animation<double> animation, int index) {
            Map mekanik = snapshot.value as Map;
            mekanik['key'] = snapshot.key;

            return listItem(mekanik: mekanik);
          },
        ),
      ),
    );
  }
}
