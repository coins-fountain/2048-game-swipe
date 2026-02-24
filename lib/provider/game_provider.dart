import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../logic/game_logic.dart';
import '../data/storage_service.dart';
import 'package:url_launcher/url_launcher.dart';

class GameProvider extends ChangeNotifier {
  List<int> grid = List.filled(16, 0);
  List<List<int>> _gridHistory = [];
  List<int> _scoreHistory = [];
  int previousScore = 0;
  int score = 0;
  int highScore = 0;
  bool isGameOver = false;
  bool isReviveUsed = false;
  bool isWin = false;

  void loadSavedGame() async {
    final data = await StorageService.loadGameState();
    highScore = data['highScore'];
    if (data['grid'] != null) {
      grid = data['grid'];
      score = data['score'];
    } else {
      initGame();
    }
    notifyListeners();
  }

  void initGame() {
    isWin = false;
    grid = List.filled(16, 0);
    _gridHistory = [];
    _scoreHistory = [];
    isGameOver = false;
    isReviveUsed = false;
    score = 0;
    addNewTile();
    addNewTile();
    notifyListeners();
  }

  void addNewTile() {
    List<int> emptyIndices = [];
    for (int i = 0; i < grid.length; i++) {
      if (grid[i] == 0) emptyIndices.add(i);
    }
    if (emptyIndices.isNotEmpty) {
      grid[emptyIndices[Random().nextInt(emptyIndices.length)]] = Random().nextInt(10) == 0 ? 4 : 2;
    }
  }

  void move(String direction) {
    if (isGameOver) return;
    _gridHistory.add(List.from(grid));
    _scoreHistory.add(score);
    if (_gridHistory.length > 3) {
      _gridHistory.removeAt(0);
      _scoreHistory.removeAt(0);
    }
    previousScore = score;

    List<int> oldGrid = List.from(grid);
    List<int> workGrid = List.from(grid);

    if (direction == 'right') workGrid = GameLogic.reverseRows(workGrid);
    else if (direction == 'up') workGrid = GameLogic.transpose(workGrid);
    else if (direction == 'down') {
      workGrid = GameLogic.transpose(workGrid);
      workGrid = GameLogic.reverseRows(workGrid);
    }

    List<int> processed = [];
    for (int i = 0; i < 16; i += 4) {
      processed.addAll(GameLogic.moveAndMerge(workGrid.sublist(i, i + 4), (s) => score += s));
    }

    if (direction == 'right') processed = GameLogic.reverseRows(processed);
    else if (direction == 'up') processed = GameLogic.transpose(processed);
    else if (direction == 'down') {
      processed = GameLogic.reverseRows(processed);
      processed = GameLogic.transpose(processed);
    }
    if (oldGrid.toString() != processed.toString()) {
      grid = processed;
      addNewTile();
      if (score > highScore) highScore = score;
      HapticFeedback.lightImpact();
      StorageService.saveGameState(grid, score, highScore);
      if (grid.contains(2048) && !isWin) {
        isWin = true;
      }

      if (!GameLogic.canMove(grid)) {
        isGameOver = true;
      }
      notifyListeners();
    }
  }
  Future<void> openPrivacyPolicy() async {
    final Uri url = Uri.parse( 'https://coins-fountain.github.io/privacy-policy-games/'); // Ganti dengan link kamu
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint("Could not launch $url");
      }
    } catch (e) {
      debugPrint("Error launching URL: $e");
    }
  }
  void revive() {
    if (_gridHistory.isNotEmpty) {
      if (_gridHistory.length >= 2) {
        int targetIndex = _gridHistory.length - 2;
        grid = List.from(_gridHistory[targetIndex]);
        score = _scoreHistory[targetIndex];
      } else {
        grid = List.from(_gridHistory.last);
        score = _scoreHistory.last;
      }
      _gridHistory.clear();
      _scoreHistory.clear();

      isGameOver = false;
      isWin =false;
      isReviveUsed = true;
      notifyListeners();
    }
  }
}