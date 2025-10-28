import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const CalculatorApp());

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Calculator',
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String display = '0';
  double? firstNum;
  String? operation;

  @override
  void initState() {
    super.initState();
    _loadLastValue();
  }

  Future<void> _loadLastValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      display = prefs.getString('lastValue') ?? '0';
    });
  }

  Future<void> _saveLastValue() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('lastValue', display);
  }

  void _onPressed(String value) {
    setState(() {
      if (value == 'C') {
        display = '0';
        firstNum = null;
        operation = null;
      } else if (value == 'CE') {
        display = '0';
      } else if (['+', '-', '*', '/'].contains(value)) {
        firstNum = double.tryParse(display);
        operation = value;
        display = '0';
      } else if (value == '=') {
        if (firstNum != null && operation != null) {
          double secondNum = double.tryParse(display) ?? 0;
          double result = 0;

          try {
            switch (operation) {
              case '+':
                result = firstNum! + secondNum;
                break;
              case '-':
                result = firstNum! - secondNum;
                break;
              case '*':
                result = firstNum! * secondNum;
                break;
              case '/':
                result = secondNum == 0 ? double.nan : firstNum! / secondNum;
                break;
            }

            if (result.isNaN || result.isInfinite) {
              display = 'ERROR';
            } else if (result.abs() > 99999999) {
              display = 'OVERFLOW';
            } else {
              display = result.toStringAsFixed(2);
              _saveLastValue();
            }
          } catch (_) {
            display = 'ERROR';
          }

          firstNum = null;
          operation = null;
        }
      } else {
        if (display == '0' || display == 'ERROR' || display == 'OVERFLOW') {
          display = value;
        } else if (display.length < 8) {
          display += value;
        }
      }
    });
  }

@override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;
  final isWide = screenWidth > 700;

  final buttons = [
    ['CE', 'C', '/', '*'],
    ['7', '8', '9', '-'],
    ['4', '5', '6', '+'],
    ['1', '2', '3', '='],
    ['0']
  ];

  return Scaffold(
    backgroundColor: Colors.black,
    body: SafeArea(
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculator box width: adaptive
            final calcWidth = isWide
                ? constraints.maxWidth * 0.45
                : constraints.maxWidth * 0.9;

            // Slight padding for consistent spacing
            final horizontalPadding = isWide ? 20.0 : 10.0;
            final verticalPadding = isWide ? 20.0 : 10.0;

            // Calculate available height for buttons
            final displayHeight = isWide ? screenHeight * 0.25 : screenHeight * 0.2;
            final availableHeight = constraints.maxHeight - displayHeight;
            final buttonHeight = (availableHeight / 5).clamp(60.0, 120.0);

            // Font sizes
            final buttonFontSize = (buttonHeight * 0.4).clamp(18.0, 30.0);
            final displayFontSize =
                (screenWidth * 0.07).clamp(32.0, 70.0);

            return Container(
              width: calcWidth,
              margin: EdgeInsets.symmetric(
                  horizontal: horizontalPadding, vertical: verticalPadding),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Display
                    Container(
                      width: double.infinity,
                      color: Colors.grey[900],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 30),
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          display,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: displayFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),

                    // Buttons
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: buttons.map((row) {
                        return Row(
                          children: row.map((value) {
                            final isOperator =
                                ['+', '-', '*', '/', '='].contains(value);
                            final isClear = ['C', 'CE'].contains(value);
                            final isEqual = value == '=';
                            final flexValue =
                                (value == '0' || isEqual) ? 2 : 1;

                            return Expanded(
                              flex: flexValue,
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                height: buttonHeight,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isEqual
                                        ? Colors.lightBlue[600]
                                        : isOperator
                                            ? Colors.orange[700]
                                            : isClear
                                                ? Colors.red[700]
                                                : Colors.grey[850],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 3,
                                  ),
                                  onPressed: () => _onPressed(value),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                        fontSize: buttonFontSize,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}

}