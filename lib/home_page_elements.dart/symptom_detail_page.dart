import 'package:flutter/material.dart';

class SymptomDetailPage extends StatelessWidget {
  final String category;

  const SymptomDetailPage({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: Center(
        child: Text(
          "This page contains details about $category symptoms.",
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
