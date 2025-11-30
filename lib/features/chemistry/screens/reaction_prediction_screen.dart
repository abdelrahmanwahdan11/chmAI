import 'package:flutter/material.dart';

class ReactionPredictionScreen extends StatelessWidget {
  const ReactionPredictionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reaction Prediction')),
      body: const Center(
        child: Text(
          'Reaction Prediction Feature\nComing Soon',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, color: Colors.grey),
        ),
      ),
    );
  }
}
