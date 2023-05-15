import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({
    Key? key,
    required this.showLoginPage,
  }) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmpasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmpasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  FirebaseAuth _auth = FirebaseAuth.instance;

  Future signUp() async {
    if (passwordConfirmed()) {
      //create user
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        //add user details
        addUserDetails(
          _firstNameController.text.trim(),
          _lastNameController.text.trim(),
          _emailController.text.trim(),
        );
      } on FirebaseAuthException catch (e) {
        print('failed with error code: ${e.code}');
        print(e.message);
      }
    }
  }

  Future addUserDetails(String firstName, String lastName, String email) async {
    await FirebaseFirestore.instance.collection('users').add({
      'first name': firstName,
      'last name': lastName,
      'email': email,
    });
  }

  bool passwordConfirmed() {
    if (_passwordController.text.trim() ==
        _confirmpasswordController.text.trim()) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Registrasi',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 55,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Daftarkan diri anda',
                  style: GoogleFonts.amarante(
                    color: Colors.lightBlueAccent,
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 20),
                //first name textfield
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Nama Depan',
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                //last name textfield
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Nama Belakang',
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                //email textfield
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Email',
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),

                //password textfield
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Password',
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),
                //confirm password textfield
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: TextField(
                    controller: _confirmpasswordController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'Confirm Password',
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                //sign in button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: GestureDetector(
                    onTap: signUp,
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.deepPurpleAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'SIGN UP',
                          style: TextStyle(
                            color: Color.fromARGB(198, 249, 248, 248),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'already have an account?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.showLoginPage,
                      child: Text(
                        ' Sign In',
                        style: TextStyle(
                          color: Colors.lightBlueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
