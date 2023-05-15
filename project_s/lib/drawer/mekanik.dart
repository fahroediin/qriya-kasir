import 'package:flutter/material.dart';
import 'package:project_s/pages/home_page.dart';

class MekanikPage extends StatefulWidget {
  const MekanikPage({Key? key}) : super(key: key);

  @override
  _MekanikPageState createState() => _MekanikPageState();
}

class _MekanikPageState extends State<MekanikPage> {
  TextEditingController _searchController = TextEditingController();

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
        title: Text('Halaman Mekanik'),
        backgroundColor: Color.fromARGB(255, 219, 42, 15),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Nama Mekanik:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              enabled: false,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Nama Mekanik',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Alamat:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              enabled: false,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Alamat Mekanik',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Nomor HP:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              enabled: false,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Nomor HP Mekanik',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: Text('Cari'),
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 219, 42, 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
