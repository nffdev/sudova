import 'dart:math';
import '../../core/difficulty.dart';

class MagicSortModel {
  final List<List<int>> bottles;
  final int capacity;
  final int colorCount;
  final List<_Move> _history = [];

  MagicSortModel({
    required this.bottles,
    required this.capacity,
    required this.colorCount,
  });

  factory MagicSortModel.generate(Difficulty difficulty) {
    int colorCount;
    const int cap = 4;
    const int emptyBottles = 2;

    switch (difficulty) {
      case Difficulty.easy:
        colorCount = 3;
        break;
      case Difficulty.medium:
        colorCount = 5;
        break;
      case Difficulty.hard:
        colorCount = 7;
        break;
      case Difficulty.expert:
        colorCount = 9;
        break;
    }

    final allColors = <int>[];
    for (int c = 0; c < colorCount; c++) {
      for (int i = 0; i < cap; i++) {
        allColors.add(c);
      }
    }
    allColors.shuffle(Random());

    final bottles = <List<int>>[];
    for (int i = 0; i < colorCount; i++) {
      bottles.add(allColors.sublist(i * cap, (i + 1) * cap));
    }
    for (int i = 0; i < emptyBottles; i++) {
      bottles.add(<int>[]);
    }

    return MagicSortModel(
      bottles: bottles,
      capacity: cap,
      colorCount: colorCount,
    );
  }

  bool canPour(int from, int to) {
    if (from == to) return false;
    if (bottles[from].isEmpty) return false;
    if (bottles[to].length >= capacity) return false;
    if (bottles[to].isEmpty) return true;
    return bottles[to].last == bottles[from].last;
  }

  int pour(int from, int to) {
    if (!canPour(from, to)) return 0;
    final topColor = bottles[from].last;
    int moved = 0;
    while (bottles[from].isNotEmpty &&
        bottles[from].last == topColor &&
        bottles[to].length < capacity) {
      bottles[to].add(bottles[from].removeLast());
      moved++;
    }
    _history.add(_Move(from: from, to: to, count: moved));
    return moved;
  }

  bool get canUndo => _history.isNotEmpty;

  void undo() {
    if (_history.isEmpty) return;
    final m = _history.removeLast();
    for (int i = 0; i < m.count; i++) {
      bottles[m.from].add(bottles[m.to].removeLast());
    }
  }

  bool get isComplete {
    for (final bottle in bottles) {
      if (bottle.isEmpty) continue;
      if (bottle.length != capacity) return false;
      final first = bottle.first;
      if (bottle.any((c) => c != first)) return false;
    }
    return true;
  }

  int get moves => _history.length;
}

class _Move {
  final int from;
  final int to;
  final int count;
  _Move({required this.from, required this.to, required this.count});
}
