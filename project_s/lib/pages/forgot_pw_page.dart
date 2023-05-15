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
          'Reset Password',
          style: TextStyle(fontSize: 25),
        ),
        backgroundColor: Color.fromARGB(255, 219, 42, 15),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.values[2],
        children: [
          Image.asset(
            'assets/forgot.png',
            height: 200,
            width: 200,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Text(
              'Masukkan email anda untuk mengirimkan link reset password!',
              style: GoogleFonts.robotoSlab(
                fontSize: 20,
                wordSpacing: 2,
                color: Color.fromARGB(255, 10, 10, 10),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          //email textfield
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: TextField(
              controller: _emailController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromARGB(0, 34, 50, 225)),
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
          SizedBox(
            height: 20,
          ),
          Container(
            child: MaterialButton(
              onPressed: passwordReset,
              elevation: 4,
              child: Text('Kirim Link'),
              color: Color.fromARGB(255, 202, 14, 83),
            ),
          ),
        ],
      ),
    );
  }
}
