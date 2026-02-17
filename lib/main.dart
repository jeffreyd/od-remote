import 'package:flutter/material.dart';
import 'screens/radio_list_screen.dart';

void main() {
  runApp(const OdRemoteApp());
}

class OdRemoteApp extends StatelessWidget {
  const OdRemoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OD Remote',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const RadioListScreen(),
    );
  }
}
