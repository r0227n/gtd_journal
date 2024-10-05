import 'package:flutter/material.dart';

class SplitView extends StatefulWidget {
  const SplitView({
    super.key,
    this.constraints = const BoxConstraints(minWidth: 0, minHeight: 0),
    required this.children,
  });

  final BoxConstraints constraints;
  final List<Widget> children;

  @override
  State<SplitView> createState() => _SplitViewState();
}

class _SplitViewState extends State<SplitView> {
  List<double> dividerPositions = [];

  @override
  void initState() {
    super.initState();
    dividerPositions = List.generate(
      widget.children.length - 1,
      (index) => (index + 1) / (widget.children.length + 1),
    );
  }

  @override
  void didUpdateWidget(covariant SplitView oldWidget) {
    dividerPositions = List.generate(
      widget.children.length - 1,
      (index) => (index + 1) / (widget.children.length + 1),
    );
    super.didUpdateWidget(oldWidget);
  }

  void addSplit() {
    if (dividerPositions.isEmpty) {
      dividerPositions.add(0.5);
    } else {
      double lastPosition = dividerPositions.last;
      dividerPositions.add(lastPosition + (1 - lastPosition) / 2);
    }
    setState(() {});
  }

  void removeSplit() {
    if (dividerPositions.isNotEmpty) {
      dividerPositions.removeLast();
      setState(() {});
    }
  }

  void _handleDragUpdate(int index, DragUpdateDetails details) {
    setState(() {
      final minDividerPosition = widget.constraints.minWidth / context.size!.width;

      dividerPositions[index] += details.delta.dx / context.size!.width;

      dividerPositions[index] = dividerPositions[index].clamp(
        index == 0 ? minDividerPosition : dividerPositions[index - 1] + minDividerPosition,
        index == dividerPositions.length - 1
            ? 1.0 - minDividerPosition
            : dividerPositions[index + 1] - minDividerPosition,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i <= dividerPositions.length; i++) ...[
          Expanded(
            flex: i == 0
                ? (dividerPositions.isEmpty ? 100 : (dividerPositions[0] * 100).round())
                : i == dividerPositions.length
                    ? ((1 - dividerPositions.last) * 100).round()
                    : ((dividerPositions[i] - dividerPositions[i - 1]) * 100).round(),
            child: widget.children[i],
          ),
          if (i < dividerPositions.length)
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: (details) => _handleDragUpdate(i, details),
              child: CustomPaint(
                size: const Size(10, double.infinity),
                painter: DividerPainter(),
              ),
            ),
        ],
      ],
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
