import 'package:flutter/material.dart';

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
  bool isSplit = false;
  double dividerPosition = 0.5;

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      dividerPosition += details.delta.dx / context.size!.width;
      dividerPosition = dividerPosition.clamp(0.1, 0.9);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arc-style Split View Demo'),
        actions: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                isSplit = !isSplit;
              });
            },
            child: Text(isSplit ? 'Remove Split' : 'Add Right Split'),
          ),
        ],
      ),
      body: isSplit
          ? Row(
              children: [
                Expanded(
                  flex: (dividerPosition * 100).round(),
                  child: Container(
                    color: Colors.blue[100],
                    child: const Center(child: Text('View A')),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragUpdate: _handleDragUpdate,
                  child: CustomPaint(
                    size: const Size(10, double.infinity),
                    painter: DividerPainter(),
                  ),
                ),
                Expanded(
                  flex: ((1 - dividerPosition) * 100).round(),
                  child: Container(
                    color: Colors.green[100],
                    child: const Center(child: Text('View B')),
                  ),
                ),
              ],
            )
          : Container(
              color: Colors.blue[100],
              child: const Center(child: Text('View A')),
            ),
    );
  }
}

class DividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
