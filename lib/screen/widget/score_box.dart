import 'package:flutter/material.dart';

class ScoreBox extends StatelessWidget {
  final String label;
  final int value;

  const ScoreBox({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFBBADA0),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFEEE4DA),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "$value",
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}