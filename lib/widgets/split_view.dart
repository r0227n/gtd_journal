import 'package:flutter/material.dart';

/// A typedef for a callback function that is triggered when the position of a divider changes.
///
/// The callback provides an object containing:
/// - `index`: An optional integer representing the index of the divider.
/// - `dividerPositions`: A list of doubles representing the new positions of the dividers.
typedef DividerPositionChangedCallback
    = ValueChanged<({int? index, List<double> dividerPositions})>;

/// A type definition for an exception that indicates an overflow condition.
typedef OverflowException = Exception;

/// A callback type definition that is triggered when an overflow exception occurs.
///
/// The callback receives an [Exception] as a parameter.
typedef OverflowExceptionCallback = ValueChanged<OverflowException>;

class SplitView extends StatefulWidget {
  const SplitView({
    super.key,
    this.constraints = const BoxConstraints(minWidth: 0, minHeight: 0),
    required this.children,
    this.initialDividerPositions = const [],
    required this.onDividerPositionsChanged,
    required this.onError,
  });

  /// The constraints for the split view.
  final BoxConstraints constraints;

  /// The children to display in the split view.
  final List<Widget> children;

  /// The initial positions of the dividers.
  final List<double> initialDividerPositions;

  /// A callback function that is triggered when the position of a divider changes.
  final DividerPositionChangedCallback onDividerPositionsChanged;

  /// A callback function that is triggered when an overflow exception occurs.
  final OverflowExceptionCallback onError;

  @override
  State<SplitView> createState() => _SplitViewState();
}

class _SplitViewState extends State<SplitView> {
  late List<double> dividerPositions;
  final GlobalKey _splitViewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    dividerPositions = widget.initialDividerPositions;
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
        widget.onError(e as OverflowException);
      }
    }
  }

  /// 指定された割合で区切り線を配置する
  List<double> calculateDivisions(double x, int n) {
    // 残りの割合を計算
    double remaining = 1 - x;

    // 分割する各部分の割合
    double segmentSize = remaining / n;

    // 区切り線の位置をリストに格納
    List<double> divisionPoints = [];
    for (int i = 1; i < n; i++) {
      divisionPoints.add(x + i * segmentSize);
    }

    return divisionPoints;
  }

  /// 区切り線の位置を初期化する
  void _initializeDividerPositions() {
    int fixedPositionsCount = widget.initialDividerPositions.length;
    int totalDividers = widget.children.length - 1;
    int remainingDividers = totalDividers - fixedPositionsCount;

    if (remainingDividers < 0) {
      throw OverflowException('Too many initial divider positions for the number of children.');
    }

    final total = widget.initialDividerPositions.reduce((a, b) => a + b);

    List<double> remainingPositions = calculateDivisions(total, widget.children.length - 1);

    dividerPositions = [...widget.initialDividerPositions, ...remainingPositions];

    widget.onDividerPositionsChanged((index: null, dividerPositions: dividerPositions));
  }

  /// 最小幅制約をチェックする
  void _checkMinWidthConstraint() {
    double availableWidth =
        (_splitViewKey.currentContext?.findRenderObject() as RenderBox).size.width;

    final fixedWith =
        widget.initialDividerPositions.map((e) => e * availableWidth).reduce((a, b) => a + b);
    double totalMinWidth = widget.constraints.minWidth * widget.children.length;

    // 子要素の総幅が最小幅以下になる場合は例外を投げる
    if (availableWidth - fixedWith - totalMinWidth < widget.constraints.minWidth) {
      throw OverflowException(
          'Adding more children would result in widths less than the minimum width constraint.');
    }
  }

  /// 区切り線の位置を更新する
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
    widget.onDividerPositionsChanged((index: index, dividerPositions: dividerPositions));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      key: _splitViewKey,
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
