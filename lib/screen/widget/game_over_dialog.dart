import 'package:flutter/material.dart';
import 'package:swipe_n_merge/provider/ads_service.dart';
import '../../provider/game_provider.dart';
import 'package:provider/provider.dart';

class GameOverDialog extends StatelessWidget {
  const GameOverDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.read<GameProvider>();
    final ads = context.read<AdService>();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xFF2C3333),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events_rounded,
                color: Colors.orange, size: 48),
            const SizedBox(height: 20),
            const Text(
              "GAME OVER",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Text("Score: ${game.score}",
                style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 30),
            if (!game.isReviveUsed && game.score > 0)
              ElevatedButton.icon(
                onPressed: () {
                  ads.showRewardedAd(
                      onRewardEarned: () {
                        game.revive();
                        Navigator.pop(context);
                      },
                      onAdDismissed: () {},
                      onAdFailed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Ad failed to load. Please try again."))
                        );
                      }
                  );
                },
                icon: const Icon(Icons.history_rounded),
                label: const Text("REVIVE"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
                ),
              ),
            TextButton(
              onPressed: () {
                game.initGame();
                Navigator.pop(context);
              },
              child: const Text(
                  "START NEW GAME",
                  style: TextStyle(color: Colors.redAccent, fontSize: 12)
              ),
            ),
          ],
        ),
      ),
    );
  }
}