import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class TileWidget extends StatelessWidget {
  final int value;

  const TileWidget({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: value == 0
            ? GameColors.emptyTile
            : GameColors.getTileColor(value),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: value == 0
            ? const SizedBox.shrink()
            : Text(
          "$value",
          style: TextStyle(
            fontSize: value > 100 ? 20 : 28,
            fontWeight: FontWeight.bold,
            color: GameColors.getTextColor(value),
          ),
        ),
      ),
    );
  }
}