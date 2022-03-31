import 'package:flutter/material.dart';
import 'package:test/game_page.dart';

class EntrancePage extends StatefulWidget {
  const EntrancePage({Key? key}) : super(key: key);

  @override
  State<EntrancePage> createState() => _EntrancePageState();
}

class _EntrancePageState extends State<EntrancePage> {
  double _digCnt = 18;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('数独')),
      body: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Column(
          children: [
            // 挖孔数量提示文字
            Text("空白格子数量${_digCnt.toInt()}"),
            // 挖孔数量调整
            Slider(
              max: 50,
              min: 1,
              value: _digCnt,
              onChanged: (nv) => setState(() => {_digCnt = nv}),
            ),
            // 开始按钮
            TextButton(
              onPressed: () {
                final route = MaterialPageRoute(
                    builder: (context) => GamePage(digCnt: _digCnt.toInt()));
                Navigator.push(context, route);
              },
              child: const Text("开始"),
            )
          ],
        ),
      ),
    );
  }
}
