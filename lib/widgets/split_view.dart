import 'package:flutter/material.dart';

class SplitView extends StatefulWidget {
  const SplitView({
    super.key,
    this.constraints = const BoxConstraints(minWidth: 0, minHeight: 0),
    required this.children,
    this.initialDividerPositions = const [],
    required this.onDividerPositionsChanged,
    required this.onError,
  });

  final BoxConstraints constraints;
  final List<Widget> children;
  final List<double> initialDividerPositions;
  final ValueChanged<List<double>> onDividerPositionsChanged;
  final ValueChanged<Exception> onError;

  @override
  State<SplitView> createState() => _SplitViewState();
}

class _SplitViewState extends State<SplitView> {
  late List<double> dividerPositions;
  final GlobalKey _splitViewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initializeDividerPositions();
  }

  @override
  void didUpdateWidget(covariant SplitView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.children.length != oldWidget.children.length) {
      try {
        _checkMinWidthConstraint();
        _initializeDividerPositions();
      } catch (e) {
        widget.onError(e as Exception);
      }
    }
  }

  void _initializeDividerPositions() {
    int fixedPositionsCount = widget.initialDividerPositions.length;
    int totalDividers = widget.children.length - 1;
    int remainingDividers = totalDividers - fixedPositionsCount;

    if (remainingDividers < 0) {
      throw Exception('Too many initial divider positions for the number of children.');
    }

    List<double> remainingPositions = List.generate(
      remainingDividers,
      (index) => (index + 1) / (remainingDividers + 1),
    );

    dividerPositions = [...widget.initialDividerPositions, ...remainingPositions];
    widget.onDividerPositionsChanged(dividerPositions);
  }

  void _checkMinWidthConstraint() {
    double availableWidth =
        (_splitViewKey.currentContext?.findRenderObject() as RenderBox).size.width;

    final fixedWith =
        widget.initialDividerPositions.map((e) => e * availableWidth).reduce((a, b) => a + b);
    double totalMinWidth = widget.constraints.minWidth * widget.children.length;

    // 子要素の総幅が最小幅以下になる場合は例外を投げる
    if (availableWidth - fixedWith - totalMinWidth < widget.constraints.minWidth) {
      throw Exception(
          'Adding more children would result in widths less than the minimum width constraint.');
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
    widget.onDividerPositionsChanged(dividerPositions);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _splitViewKey,
      child: Row(
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
