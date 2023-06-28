import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../pages/login_page.dart';
import '../pages/register_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class Auth with ChangeNotifier {
  Future<void> signIn(String email, String password) async {
    try {
      Uri url = Uri.parse(
          "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=YOUR_API_KEY");
      var response = await http.post(
        url,
        body: json.encode({
          "email": email,
          "password": password,
          "returnSecureToken": true,
        }),
      );

      if (response.statusCode == 200) {
        // Authentication successful
        print(json.decode(response.body));
      } else {
        // Authentication failed
        print('Authentication failed: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error during authentication: $error');
    }
  }
}

class _AuthPageState extends State<AuthPage> {
  // Initialize login page
  bool showLoginPage = true;

  void toggleScreens() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(showRegisterPage: toggleScreens);
    } else {
      return RegisterPage(showLoginPage: toggleScreens);
    }
  }
}
