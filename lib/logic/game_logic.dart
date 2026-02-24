class GameLogic {
  static List<int> moveAndMerge(List<int> row, Function(int) onMerge) {
    List<int> newRow = row.where((element) => element != 0).toList();
    for (int i = 0; i < newRow.length - 1; i++) {
      if (newRow[i] == newRow[i + 1]) {
        newRow[i] *= 2;
        onMerge(newRow[i]);
        newRow.removeAt(i + 1);
        newRow.add(0);
      }
    }

    while (newRow.length < 4) {
      newRow.add(0);
    }
    return newRow;
  }
  static List<int> transpose(List<int> grid) {
    List<int> temp = List.filled(16, 0);
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        temp[i * 4 + j] = grid[j * 4 + i];
      }
    }
    return temp;
  }

  static List<int> reverseRows(List<int> grid) {
    List<int> temp = [];
    for (int i = 0; i < 16; i += 4) {
      temp.addAll(grid.sublist(i, i + 4).reversed);
    }
    return temp;
  }

  static bool canMove(List<int> grid) {
    if (grid.contains(0)) return true;
    for (int i = 0; i < 16; i++) {
      if (i % 4 < 3 && grid[i] == grid[i + 1]) return true;
      if (i < 12 && grid[i] == grid[i + 4]) return true;
    }
    return false;
  }
}