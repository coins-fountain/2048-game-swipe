import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:swipe_n_merge/provider/game_provider.dart';
import 'package:swipe_n_merge/screen/game_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _hintController;
  late Animation<double> _logoScale;
  late Animation<Offset> _tileOffset;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _logoScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _tileOffset = TweenSequence<Offset>([
      // Move Right
      TweenSequenceItem(tween: Tween(begin: const Offset(0, 0), end: const Offset(1.1, 0)), weight: 25),
      // Move Down
      TweenSequenceItem(tween: Tween(begin: const Offset(1.1, 0), end: const Offset(1.1, 1.1)), weight: 25),
      // Move Left
      TweenSequenceItem(tween: Tween(begin: const Offset(1.1, 1.1), end: const Offset(0, 1.1)), weight: 25),
      // Move Up
      TweenSequenceItem(tween: Tween(begin: const Offset(0, 1.1), end: const Offset(0, 0)), weight: 25),
    ]).animate(CurvedAnimation(parent: _hintController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _logoController.dispose();
    _hintController.dispose();
    super.dispose();
  }

  void _startGame() {
    HapticFeedback.mediumImpact();
    context.read<GameProvider>().initGame();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const GameScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(animation),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8EF),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              ScaleTransition(
                scale: _logoScale,
                child: _buildLogo(),
              ),
              const Spacer(),
              _buildAnimatedHint(),
              const SizedBox(height: 25),
              const Text(
                "SWIPE ANY DIRECTION",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF776E65),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Merge tiles to reach 2048",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF776E65),
                  height: 1.4,
                ),
              ),
              const Spacer(flex: 2),
              _buildStartButton(),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildLogo() {
    return Image.asset(
      'assets/icon/logo_2048.png',
      width: 180,
      height: 180,
      fit: BoxFit.contain,
    );
  }
  Widget _buildAnimatedHint() {
    return Container(
      width: 140,
      height: 140,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFBBADA0),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          _buildHintGrid(),
          AnimatedBuilder(
            animation: _tileOffset,
            builder: (context, child) {
              return FractionalTranslation(
                translation: _tileOffset.value,
                child: _hintTile("2"),
              );
            },
          ),
        ],
      ),
    );
  }
  Widget _buildHintGrid() {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(4, (index) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFFCDC1B4).withOpacity(0.4),
          borderRadius: BorderRadius.circular(8),
        ),
      )),
    );
  }

  Widget _hintTile(String val) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xFFEEE4DA),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Center(
        child: Text(
          val,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF776E65)),
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return InkWell(
      onTap: _startGame,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF8F7A66),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8F7A66).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: const Text(
          "GET STARTED",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}