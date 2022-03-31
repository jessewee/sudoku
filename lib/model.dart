// 防止创建时进入死循环
import 'dart:math';

const _maxRetryCnt = 200;
const _selections = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9];

/// 空格子
const emptyNumber = -1;

/// 创建数据，9*9
/// digCount 挖孔数量
List<List<int>>? createSudokudata(int digCount) {
  final data = create(0);
  data?.dig(digCount);
  return data;
}

/// 检查数据是否正确
bool checkIfDataValid(List<List<int>> data) {
  for (var r = 0; r < data.length; r++) {
    for (var c = 0; c < data[r].length; c++) {
      if (!data.checkIfNumValid(r, c, data[r][c])) return false;
    }
  }
  return true;
}

// 创建数据
List<List<int>>? create(int lastRetryCnt) {
  if (lastRetryCnt > _maxRetryCnt) return null;
  var retryCnt = lastRetryCnt;
  // 记录步骤，当前步骤无解时返回到上一步
  final steps = <_Step>[];
  // 第一行直接生成
  final firstData = List.generate(9, _generateFirst);
  steps.add(
    _Step(
      row: 1,
      column: 0,
      data: firstData,
      leftSelections: _selections
          .where((e) => firstData.checkIfCreateValid(1, 0, e))
          .toList(),
    ),
  );
  // 开始生成
  List<List<int>> result;
  while (true) {
    final step = steps.isEmpty ? null : steps.last;
    if (step == null) return create(retryCnt);
    // 当前步骤无解，返回上一步
    if (step.leftSelections.isEmpty) {
      steps.removeLast();
      retryCnt++;
      if (retryCnt > _maxRetryCnt) return null;
      continue;
    }
    // 在候选项里随机选择一个
    final tmp = step.leftSelections
        .removeAt(Random().nextInt(step.leftSelections.length));
    final data = step.data.copy();
    data[step.row][step.column] = tmp;
    final int nextRow, nextColumn;
    if (step.column < 8) {
      nextColumn = step.column + 1;
      nextRow = step.row;
    } else if (step.row < 8) {
      nextColumn = 0;
      nextRow = step.row + 1;
    } else {
      result = data;
      break;
    }
    final nextLeftSelections = _selections
        .where((e) => data.checkIfCreateValid(nextRow, nextColumn, e))
        .toList();
    if (nextLeftSelections.isEmpty) {
      steps.removeLast();
      retryCnt++;
      if (retryCnt > _maxRetryCnt) return null;
      continue;
    }
    steps.add(
      _Step(
        row: nextRow,
        column: nextColumn,
        data: data,
        leftSelections: nextLeftSelections,
      ),
    );
  }
  // 检查数据是否正确
  if (!checkIfDataValid(result)) return create(retryCnt);
  // 返回结果
  return result;
}

List<int> _generateFirst(int line) {
  if (line != 0) return List.generate(9, (index) => emptyNumber);
  final tmp = _selections.toList();
  tmp.shuffle();
  return tmp;
}

extension _DataExtension on List<List<int>> {
  // 检查格子是否可填当前数值，因为是按照顺序填数字，所以只判断之前的数据就可以
  bool checkIfCreateValid(int r, int c, int n) {
    // 已经有数据的情况
    if (this[r][c] != emptyNumber) return false;
    // 同一行有相同的情况
    for (var i = 0; i < c; i++) {
      if (this[r][i] == n) return false;
    }
    // 同一列有相同的情况
    for (var i = 0; i < r; i++) {
      if (this[i][c] == n) return false;
    }
    // 同一九宫格有相同的情况
    final rs = (r - r % 3).abs();
    final cs = (c - c % 3).abs();
    for (var i = rs; i < r; i++) {
      for (var j = cs; j < cs + 3; j++) {
        if (j != c && this[i][j] == n) return false;
      }
    }
    // 可用
    return true;
  }

  // 检查数字在单元格是否可用
  bool checkIfNumValid(int r, int c, int n) {
    // 数据错误的情况
    if (!_selections.contains(this[r][c])) return false;
    // 同一行有相同的情况
    for (var i = 0; i < 8; i++) {
      if (i != c && this[r][i] == n) return false;
    }
    // 同一列有相同的情况
    for (var i = 0; i < i; i++) {
      if (i != r && this[i][c] == n) return false;
    }
    // 同一九宫格有相同的情况
    final rs = (r - r % 3).abs();
    final cs = (c - c % 3).abs();
    for (var i = rs; i < rs + 3; i++) {
      for (var j = cs; j < cs + 3; j++) {
        if (i != r && j != c && this[i][j] == n) return false;
      }
    }
    // 可用
    return true;
  }

  // 挖孔
  void dig(int count) {
    final gridIndexes = <int>[0, 1, 2, 3, 4, 5, 6, 7, 8];
    final g = (count / 9).floor();
    for (var i = 0; i < g; i++) {
      for (var j in gridIndexes) {
        digInGrid(j);
      }
    }
    final left = count % 9;
    if (left == 0) return;
    gridIndexes.shuffle();
    for (var i in gridIndexes.take(left)) {
      digInGrid(i);
    }
  }

  // 在某个九宫格内挖孔
  void digInGrid(int gridIdx) {
    final int rs = (gridIdx / 3).floor() * 3;
    final int cs = (gridIdx % 3).floor() * 3;
    final selections = <_S>[];
    for (var r = rs; r < rs + 3; r++) {
      for (var c = cs; c < cs + 3; c++) {
        if (this[r][c] != emptyNumber) selections.add(_S(r, c));
      }
    }
    if (selections.isEmpty) return;
    final random = selections[Random().nextInt(selections.length)];
    this[random.r][random.c] = emptyNumber;
  }

  // 复制
  List<List<int>> copy() {
    final result = <List<int>>[];
    for (var l in this) {
      final line = <int>[];
      for (var d in l) {
        line.add(d);
      }
      result.add(line);
    }
    return result;
  }
}

// 行列
class _S {
  final int r;
  final int c;

  const _S(this.r, this.c);
}

// 记录步骤，当前步骤无解时返回到上一步
class _Step {
  final int row, column;
  final List<List<int>> data;
  final List<int> leftSelections;

  const _Step({
    required this.row,
    required this.column,
    required this.data,
    required this.leftSelections,
  });
}
