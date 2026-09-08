import 'package:flutter/material.dart';

class ApptsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments'),
      ),
      body: Center(
        child: Text(
          'Appointments Screen - Hearing Accessible',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}