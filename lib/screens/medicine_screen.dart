import 'package:flutter/material.dart';

class MedicineScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medications'),
      ),
      body: Center(
        child: Text(
          'Medicine Screen - Hearing Accessible',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}