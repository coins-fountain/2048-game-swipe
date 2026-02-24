import 'package:flutter/material.dart';
import 'score_box.dart';
import '../../provider/game_provider.dart';

class GameHeader extends StatelessWidget {
  final GameProvider game;

  const GameHeader({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "2048",
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Color(0xFF776E65),
            ),
          ),
          Row(
            children: [
              ScoreBox(label: "SCORE", value: game.score),
              const SizedBox(width: 8),
              ScoreBox(label: "BEST", value: game.highScore),
            ],
          ),
        ],
      ),
    );
  }
}