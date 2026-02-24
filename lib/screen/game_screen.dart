import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:swipe_n_merge/provider/game_provider.dart';
import 'package:swipe_n_merge/screen/widget/bottom_banner_ads.dart';
import 'package:swipe_n_merge/screen/widget/game_grid.dart';
import 'package:swipe_n_merge/screen/widget/game_header.dart';
import 'package:swipe_n_merge/screen/widget/game_over_dialog.dart';
import 'package:swipe_n_merge/screen/widget/win_dialog.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  double dragStartX = 0;
  double dragStartY = 0;
  bool hasMoved = false;

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    if (game.isWin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(context: context, builder: (_) => const WinDialog());
      });
    } else if (game.isGameOver) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(context: context, builder: (_) => const GameOverDialog());
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8EF),
      bottomNavigationBar: SafeArea(child: const BottomBannerAd()),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            GameHeader(game: game),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GestureDetector(
                      onPanStart: (details) {
                        dragStartX = details.localPosition.dx;
                        dragStartY = details.localPosition.dy;
                        hasMoved = false;
                      },
                      onPanUpdate: (details) {
                        if (hasMoved) return;

                        final dx = details.localPosition.dx - dragStartX;
                        final dy = details.localPosition.dy - dragStartY;

                        const threshold = 30;

                        if (dx.abs() > dy.abs()) {
                          if (dx > threshold) {
                            _move(game, 'right');
                          } else if (dx < -threshold) {
                            _move(game, 'left');
                          }
                        } else {
                          if (dy > threshold) {
                            _move(game, 'down');
                          } else if (dy < -threshold) {
                            _move(game, 'up');
                          }
                        }
                      },
                      child: GameGrid(game: game),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton(
                onPressed: game.initGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8F7A66),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text("New Game", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _move(GameProvider game, String direction) {
    HapticFeedback.lightImpact();
    game.move(direction);
    hasMoved = true;
  }
}
