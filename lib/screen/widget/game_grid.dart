import 'package:flutter/material.dart';
import '../../provider/game_provider.dart';
import 'tile_widget.dart';

class GameGrid extends StatelessWidget {
  final GameProvider game;

  const GameGrid({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFBBADA0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 16,
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, i) =>
            TileWidget(value: game.grid[i]),
      ),
    );
  }
}