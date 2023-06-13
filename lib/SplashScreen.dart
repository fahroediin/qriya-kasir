import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_s/auth/main_page.dart';
import 'dart:async';
import 'package:project_s/pages/login_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    Timer(
        Duration(seconds: 3),
        () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => LoginPage(
                        showRegisterPage: () {},
                      )),
            ));
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/qriya-logo.png',
                  width: 200.0,
                  height: 200.0,
                ),
                CircularProgressIndicator(
                  backgroundColor: Colors.grey,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 10.0,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Text(
                'Versi 0.5.0',
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
