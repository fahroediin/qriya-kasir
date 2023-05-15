import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'forgot_pw_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LoginPage({Key? key, required this.showRegisterPage}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text controller
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  String errorMessage = '';

  Future signIn() async {
    if (_key.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // Navigasi ke halaman utama jika sign in berhasil
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage()),
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          print('Email tidak terdaftar');
        } else if (e.code == 'wrong-password') {
          print('Password salah');
        }
      }
      return null;
    }
  }

  String? _emailValidator(String? formEmail) {
    if (formEmail == null || formEmail.isEmpty) {
      return 'Email tidak boleh kosong';
    }

    String pattern = r'\w+@\w+\.\w+';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(formEmail)) return 'Invalid E-mail Address format.';

    return null;
  }

  String? _passwordValidator(String? formPassword) {
    if (formPassword == null || formPassword.isEmpty)
      return 'Password tidak boleh kosong.';

    String? _passwordValidator(String? formPassword) {
      if (formPassword == null || formPassword.isEmpty) {
        return 'Password tidak boleh kosong.';
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _key,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/login.png',
                    width: 250,
                    height: 250,
                  ),
                  Text(
                    'LOGIN',
                    style: GoogleFonts.gugi(
                      fontSize: 100,
                      color: Color.fromARGB(255, 219, 42, 15),
                    ),
                  ),

                  //email textfield
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextFormField(
                      controller: _emailController,
                      validator: _emailValidator,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueAccent),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        hintText: 'Email',
                        fillColor: Color.fromARGB(255, 247, 243, 244),
                        filled: true,
                      ),
                    ),
                  ),

                  SizedBox(height: 10.0),
                  //password textfield
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25.0, vertical: 10),
                    child: TextFormField(
                      controller: _passwordController,
                      validator: _passwordValidator,
                      obscureText: true,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueAccent),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        hintText: 'Password',
                        fillColor: Color.fromARGB(255, 247, 243, 244),
                        filled: true,
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  //login button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: signIn,
                        child: Text(
                          'LOGIN',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              Color.fromARGB(255, 219, 42, 15)),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Lupa Password?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                        secondaryAnimation) {
                                      return ForgotPasswordPage();
                                    },
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              },
                              child: Text(
                                'Reset Password',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 220, 53, 3),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
