import 'package:flutter/material.dart';
import 'package:gtd_journal/widgets/split_view.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SplitViewDemo(),
    );
  }
}

class SplitViewDemo extends StatefulWidget {
  const SplitViewDemo({super.key});

  @override
  _SplitViewDemoState createState() => _SplitViewDemoState();
}

class _SplitViewDemoState extends State<SplitViewDemo> {
  List<Widget> children = [
    Container(
      color: Colors.blue[100],
      child: const Center(child: Text('View A')),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arc-style Split View Demo'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                children.add(Container(
                  color: Colors.purple[100],
                  child: const Center(child: Text('View D')),
                ));
              });
            },
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                children.removeLast();
              });
            },
            icon: const Icon(Icons.remove),
          ),
        ],
      ),
      body: SplitView(children: children),
    );
  }
}
