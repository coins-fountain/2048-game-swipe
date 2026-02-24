import 'package:flutter/material.dart';
import '../../provider/game_provider.dart';
import 'package:provider/provider.dart';

class WinDialog extends StatelessWidget {
  const WinDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.read<GameProvider>();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFC107), Color(0xFFFF9800)],
          ),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events_rounded,
                color: Colors.white, size: 60),
            const SizedBox(height: 20),
            const Text(
              "YOU WIN!",
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                game.isWin = false;
                Navigator.pop(context);
              },
              child: const Text("CONTINUE"),
            ),
          ],
        ),
      ),
    );
  }
}