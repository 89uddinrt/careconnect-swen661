import 'package:flutter/material.dart';

class MemoriesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Memories'),
      ),
      body: Center(
        child: Text(
          'Memories Screen - Hearing Accessible',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}