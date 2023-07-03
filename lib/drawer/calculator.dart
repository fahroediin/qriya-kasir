import 'package:flutter/material.dart';
import 'package:project_s/pages/home_page.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 219, 42, 15),
      ),
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _output = "0";
  String _operand1 = "";
  String _operand2 = "";
  String _operator = "";

  void buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        _output = "0";
        _operand1 = "";
        _operand2 = "";
        _operator = "";
      } else if (buttonText == "+" ||
          buttonText == "-" ||
          buttonText == "x" ||
          buttonText == "/") {
        if (_operand1.isNotEmpty && _operand2.isNotEmpty) {
          performOperation();
          _operand1 = _output;
        } else {
          _operand1 = _output;
        }
        _operator = buttonText;
        _output = "0";
      } else if (buttonText == ".") {
        if (!_output.contains(".")) {
          _output += buttonText;
        }
      } else if (buttonText == "=") {
        if (_operand1.isEmpty || _output.isEmpty) {
          _output = '';
        } else {
          _operand2 = _output;
          performOperation();
          _operand1 = "";
          _operand2 = "";
          _operator = "";
        }
      } else if (buttonText == "Del") {
        if (_output.length > 1) {
          _output = _output.substring(0, _output.length - 1);
        } else {
          _output = "0";
        }
      } else {
        if (_output == "0") {
          _output = buttonText;
        } else {
          _output += buttonText;
        }
      }
    });
  }

  void performOperation() {
    double op1 = double.parse(_operand1);
    double op2 = double.parse(_operand2);

    if (_operator == "+") {
      _output = (op1 + op2).toStringAsFixed(0);
    } else if (_operator == "-") {
      _output = (op1 - op2).toStringAsFixed(0);
    } else if (_operator == "x") {
      _output = (op1 * op2).toStringAsFixed(0);
    } else if (_operator == "/") {
      _output = (op1 / op2).toStringAsFixed(0);
    }
  }

  Widget buildButton(String buttonText,
      {Color color = Colors.white, int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!, width: 0.5),
        ),
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.all(16.0),
          ),
          onPressed: () => buttonPressed(buttonText),
          child: Text(
            buttonText,
            style: TextStyle(fontSize: 32),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 219, 42, 15),
        title: Text(
          "KALKULATOR",
          style: TextStyle(
            fontSize: 28,
          ),
        ),
        centerTitle: true,
        elevation: 0.0,
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
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: EdgeInsets.all(16.0),
              child: Text(
                _output,
                style: TextStyle(fontSize: 64),
              ),
            ),
          ),
          Row(
            children: [
              buildButton("C",
                  flex: 2, color: Color.fromARGB(255, 219, 42, 15)),
              buildButton("Del", color: Color.fromARGB(255, 244, 143, 177)),
              buildButton("/", color: Color.fromARGB(255, 244, 143, 177)),
            ],
          ),
          Row(
            children: [
              buildButton("7"),
              buildButton("8"),
              buildButton("9"),
              buildButton("x", color: Color.fromARGB(255, 244, 143, 177)),
            ],
          ),
          Row(
            children: [
              buildButton("4"),
              buildButton("5"),
              buildButton("6"),
              buildButton("-", color: Color.fromARGB(255, 244, 143, 177)),
            ],
          ),
          Row(
            children: [
              buildButton("1"),
              buildButton("2"),
              buildButton("3"),
              buildButton("+", color: Color.fromARGB(255, 244, 143, 177)),
            ],
          ),
          Row(
            children: [
              buildButton(".", flex: 2),
              buildButton("0"),
              buildButton("=", color: Color.fromARGB(255, 244, 143, 177)),
            ],
          ),
        ],
      ),
    );
  }
}
