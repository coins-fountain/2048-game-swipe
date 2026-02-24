import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:swipe_n_merge/provider/ads_service.dart';
import 'package:swipe_n_merge/provider/game_provider.dart';
import 'package:swipe_n_merge/screen/widget/bottom_banner_ads.dart';
import 'package:swipe_n_merge/utils/colors.dart';

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

    if (game.isGameOver) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showGameOverDialog(context);
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8EF),
      bottomNavigationBar: SafeArea(
        child: const BottomBannerAd(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildHeader(game),
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

                        final dx =
                            details.localPosition.dx - dragStartX;
                        final dy =
                            details.localPosition.dy - dragStartY;

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
                      child: _buildGrid(game),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 15),
                ),
                child: const Text(
                  "New Game",
                  style: TextStyle(color: Colors.white),
                ),
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
  Widget _buildHeader(GameProvider game) {
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
              _scoreBox("SCORE", game.score),
              const SizedBox(width: 8),
              _scoreBox("BEST", game.highScore),
            ],
          ),
        ],
      ),
    );
  }

  Widget _scoreBox(String label, int val) {
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
            "$val",
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

  Widget _buildGrid(GameProvider game) {
    return AnimatedScale(
      scale: game.isGameOver ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 250),
      child: Container(
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
              _buildTile(game.grid[i], i),
        ),
      ),
    );
  }

  Widget _buildTile(int val, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.85, end: 1.0),
      duration: const Duration(milliseconds: 120),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: val == 0
              ? GameColors.emptyTile
              : GameColors.getTileColor(val),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: val == 0
              ? const SizedBox.shrink()
              : AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder:
                (child, animation) => ScaleTransition(
              scale: animation,
              child: child,
            ),
            child: Text(
              "$val",
              key: ValueKey("$val-$index"),
              style: TextStyle(
                fontSize: val > 100 ? 20 : 28,
                fontWeight: FontWeight.bold,
                color:
                GameColors.getTextColor(val),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showGameOverDialog(BuildContext context) {
    final game = context.read<GameProvider>();
    final ads = context.read<AdService>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Game Over"),
        content: Text("Score: ${game.score}"),
        actions: [
          if (!game.isReviveUsed && game.score > 0)
            TextButton(
              onPressed: () {
                ads.showRewardedAd(
                  onRewardEarned: () {
                    game.revive();
                    Navigator.pop(context);
                  },
                  onAdDismissed: () {},
                  onAdFailed: () {},
                );
              },
              child: const Text("Revive"),
            ),
          TextButton(
            onPressed: () {
              game.initGame();
              Navigator.pop(context);
            },
            child: const Text("New Game"),
          ),
        ],
      ),
    );
  }
}