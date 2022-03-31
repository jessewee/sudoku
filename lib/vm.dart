import 'package:flutter/foundation.dart';
import 'package:test/model.dart';

/// 数据与逻辑
class MainVM extends ChangeNotifier {
  // 状态
  Status _status = Status.init;

  /// 状态
  Status get status => _status;

  // 数据
  List<List<Cell>> _data = List.empty();

  /// 数据
  List<List<Cell>> get data => _data;

  // 当前选中的格子
  CellIdx? _selectedCell;

  /// 当前选中的格子
  CellIdx? get selectedCell => _selectedCell;

  /// 更改状态
  void changeStatus(Status status) {
    _status = status;
    notifyListeners();
  }

  /// 生成数据
  Future<void> start(int digCnt) async {
    if (_status == Status.generating) return;
    _status = Status.generating;
    final tmp = await compute(createSudokudata, digCnt);
    if (tmp == null || tmp.isEmpty) {
      _status = Status.generateFail;
      notifyListeners();
      return;
    }
    _status = Status.generated;
    _data = tmp
        .map((list) => list
            .map((e) => Cell(number: e, canFill: e == emptyNumber))
            .toList())
        .toList();
    notifyListeners();
  }

  /// 选中格子
  void selectCell(int row, int column) {
    _selectedCell = CellIdx(row: row, column: column);
    notifyListeners();
  }

  /// 填充数据
  void fill(int number) {
    final cIdx = _selectedCell;
    if (cIdx == null) return;
    _data[cIdx.row][cIdx.column] =
        Cell(number: number, canFill: _data[cIdx.row][cIdx.column].canFill);
    notifyListeners();
  }

  /// 判断结果
  Future<void> checkResult() async {
    if (_data.isEmpty) return;
    _status = Status.resultChecking;
    final data =
        _data.map((list) => list.map((e) => e.number).toList()).toList();
    final result = await compute(checkIfDataValid, data);
    _status = result ? Status.resultSuccess : Status.resultFail;
    notifyListeners();
  }
}

/// 格子索引
class CellIdx {
  final int row, column;
  const CellIdx({required this.row, required this.column});
}

/// 格子数据
class Cell {
  final int number;
  final bool canFill;
  const Cell({required this.number, required this.canFill});
}

/// 状态
enum Status {
  /// 初始状态
  init,

  /// 生成中
  generating,

  /// 生成失败
  generateFail,

  /// 生成成功
  generated,

  /// 判断结果中
  resultChecking,

  /// 填写正确
  resultSuccess,

  /// 填写错误
  resultFail
}
