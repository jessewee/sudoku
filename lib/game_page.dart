import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:test/vm.dart';

import 'main.dart';

class GamePage extends StatefulWidget {
  final int digCnt;

  const GamePage({Key? key, required this.digCnt}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  void initState() {
    logger.d("====GamePage--initState");
    context.read<MainVM>().start(widget.digCnt);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    logger.d("====GamePage--build");
    return Scaffold(
      appBar: AppBar(
        title: const Text('数独'),
        actions: [
          IconButton(
            onPressed: () => context.read<MainVM>().checkResult(),
            icon: const Icon(Icons.done),
          )
        ],
      ),
      body: buildBody(context.select((MainVM vm) => vm.status)),
    );
  }

  Widget buildBody(Status status) {
    logger.d("====GamePage--buildBody");
    switch (status) {
      case Status.generating:
        return Container(
          alignment: Alignment.center,
          child: const Text('数据生成中...'),
        );
      case Status.generateFail:
        return Container(
          alignment: Alignment.center,
          child: const Text('数据生成失败'),
        );
      case Status.generated:
        return const GamePad();
      case Status.resultChecking:
        return Container(
          alignment: Alignment.center,
          child: const Text('结果处理中...'),
        );
      case Status.resultFail:
        return Container(
          alignment: Alignment.center,
          child: const Text('结果错误'),
        );
      case Status.resultSuccess:
        return Container(
          alignment: Alignment.center,
          child: const Text('结果正确'),
        );
      default:
        return Container(
          alignment: Alignment.center,
          child: const Text('未知错误'),
        );
    }
  }
}

class GamePad extends StatelessWidget {
  const GamePad({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    logger.d("====GamePad--build");
    return Column(
      children: const [
        // 选项
        Selections(),
        // 分割线
        Divider(),
        // 格子
        GridFrame(),
      ],
    );
  }
}

/// 选项
class Selections extends StatelessWidget {
  const Selections({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    logger.d("====Selections--build");
    final vm = context.read<MainVM>();
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < 9; i++)
          Flexible(
            child: OutlinedButton(
              onPressed: () => vm.fill(i + 1),
              child: Text('${i + 1}'),
            ),
          )
      ],
    );
  }
}

/// 格子框
class GridFrame extends StatefulWidget {
  const GridFrame({Key? key}) : super(key: key);

  @override
  State<GridFrame> createState() => _GridFrameState();
}

class _GridFrameState extends State<GridFrame> {
  @override
  Widget build(BuildContext context) {
    logger.d("====GridFrame--build");
    final rowCnt = context.select((MainVM vm) => vm.data.length);
    return Container(
      decoration: BoxDecoration(border: Border.all(width: 2)),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [for (var r = 0; r < rowCnt; r++) GridRow(rowIdx: r)]),
    );
  }
}

/// 格子行
class GridRow extends StatefulWidget {
  final int rowIdx;
  const GridRow({Key? key, required this.rowIdx}) : super(key: key);

  @override
  State<GridRow> createState() => _GridRowState();
}

class _GridRowState extends State<GridRow> {
  @override
  Widget build(BuildContext context) {
    logger.d("====GridRow--build--rowIdx:${widget.rowIdx}");
    final columnCnt =
        context.select((MainVM vm) => vm.data[widget.rowIdx].length);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var c = 0; c < columnCnt; c++)
          GridCell(row: widget.rowIdx, column: c)
      ],
    );
  }
}

/// 单个格子
class GridCell extends StatefulWidget {
  final int row, column;
  const GridCell({Key? key, required this.row, required this.column})
      : super(key: key);

  @override
  State<GridCell> createState() => _GridCellState();
}

class _GridCellState extends State<GridCell> {
  @override
  Widget build(BuildContext context) {
    logger.d("====GridCell--build--row:${widget.row}--column:${widget.column}");
    final vm = context.read<MainVM>();
    final cellData =
        context.select((MainVM vm) => vm.data[widget.row][widget.column]);
    final matched = context.select((MainVM vm) {
      return widget.row == vm.selectedCell?.row ||
          widget.column == vm.selectedCell?.column;
    });
    Widget cell = Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(width: 0.5),
        color: matched ? Colors.black45 : Colors.transparent,
      ),
      child: Text(cellData.number.toString()),
    );
    if (cellData.canFill) {
      cell = GestureDetector(
        onTap: () => vm.selectCell(widget.row, widget.column),
        child: cell,
      );
    }
    cell = Flexible(
      child: AspectRatio(
        aspectRatio: 1,
        child: cell,
      ),
    );
    return cell;
  }
}
