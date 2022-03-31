import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const TestApp());
}

final logger = Logger();

class TestApp extends StatelessWidget {
  const TestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    logger.e("=========================TestApp----build");
    return ChangeNotifierProvider(
      create: (_) => TestVM(),
      child: const MaterialApp(home: TestWidget()),
    );
  }
}

class TestWidget extends StatefulWidget {
  const TestWidget({Key? key}) : super(key: key);

  @override
  State<TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> {
  @override
  void initState() {
    logger.e("=========================_TestWidgetState----initState");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    logger.e("=========================_TestWidgetState----build");
    return Scaffold(
      appBar: AppBar(title: const Text("测试")),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    logger.e("=========================_TestWidgetState----_buildContent");
    return Column(
      children: const [
        AWidget(),
        BWidget(),
      ],
    );
  }
}

class AWidget extends StatefulWidget {
  const AWidget({Key? key}) : super(key: key);

  @override
  State<AWidget> createState() => _AWidgetState();
}

class _AWidgetState extends State<AWidget> {
  @override
  Widget build(BuildContext context) {
    logger.e("=========================_AWidgetState----build");
    final vm = context.read<TestVM>();
    return Column(
      children: [
        Text('${context.select((TestVM vm) => vm.a)}'),
        IconButton(onPressed: () => vm.increA(), icon: const Icon(Icons.add))
      ],
    );
  }
}

class BWidget extends StatefulWidget {
  const BWidget({Key? key}) : super(key: key);

  @override
  State<BWidget> createState() => _BWidgetState();
}

class _BWidgetState extends State<BWidget> {
  @override
  Widget build(BuildContext context) {
    logger.e("=========================_BWidgetState----build");
    final vm = context.read<TestVM>();
    return Column(
      children: [
        Text('${context.select((TestVM vm) => vm.b)}'),
        IconButton(onPressed: () => vm.decreB(), icon: const Icon(Icons.remove))
      ],
    );
  }
}

class TestVM extends ChangeNotifier {
  int _a = 0;
  int _b = -1;
  int get a => _a;
  int get b => _b;

  void increA() {
    _a++;
    notifyListeners();
  }

  void decreB() {
    _b--;
    notifyListeners();
  }
}
