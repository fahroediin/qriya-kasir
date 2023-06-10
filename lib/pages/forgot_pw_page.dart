import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    final String email = _emailController.text.trim();

    // regex untuk validasi format email
    final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');

    if (email.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Masukkan email anda terlebih dahulu'),
          );
        },
      );
    } else if (!emailRegex.hasMatch(email)) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Format email tidak valid'),
          );
        },
      );
    } else {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content:
                  Text('Link reset password telah dikirim, cek email anda'),
            );
          },
        );
      } on FirebaseAuthException catch (e) {
        print(e);
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message.toString()),
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          'Lupa kata sandi',
          style: TextStyle(fontSize: 25),
        ),
        backgroundColor: Color.fromARGB(255, 219, 42, 15),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.all(16.0),
            child: Image.asset(
              'assets/forgot.png',
              height: 200,
              width: 200,
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: Text(
              'Mohon masukkan email anda:',
              style: GoogleFonts.lato(
                fontSize: 20,
                wordSpacing: 2,
                color: Color.fromARGB(255, 10, 10, 10),
              ),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: SizedBox(
              width: double.infinity,
              child: TextField(
                controller: _emailController,
                style: GoogleFonts.robotoSlab(
                  fontSize: 20,
                  color: Color.fromARGB(255, 10, 10, 10),
                ),
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(0, 34, 50, 225)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 202, 14, 83)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  hintText: 'Email',
                  hintStyle: TextStyle(fontSize: 20),
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: passwordReset,
                child: Text(
                  'Kirim Link',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Color.fromARGB(255, 220, 53, 3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
