import 'package:flutter/material.dart';

class DragListItem {
  const DragListItem({
    required this.id,
    this.draggingChild,
    required this.child,
  });

  /// The unique identifier for the drag list item
  final int id;

  /// The widget to display when the item is being dragged
  final Widget? draggingChild;

  /// The main widget to display for the item
  final Widget child;
}

/// A widget that displays a list of draggable items.
class DragListView extends StatelessWidget {
  const DragListView({
    super.key,
    required this.children,
    this.feedback = const SizedBox.square(
      dimension: 100,
      child: ColoredBox(
        color: Colors.redAccent,
        child: Icon(
          Icons.directions_run,
          size: 40.0,
        ),
      ),
    ),
    this.draggingChild,
    required this.onAcceptWithDetails,
  });

  /// The list of draggable items to display.
  final List<DragListItem> children;

  /// The widget to display as feedback when an item is being dragged.
  final Widget feedback;

  /// The widget to display as the dragged item.
  final Widget? draggingChild;

  /// Callback function that is called when an item is accepted by a [DragTarget].
  final DragTargetAcceptWithDetails<int> onAcceptWithDetails;

  @override
  Widget build(BuildContext context) {
    return DragTarget<int>(
      builder: (
        BuildContext context,
        List<dynamic> accepted,
        List<dynamic> rejected,
      ) {
        return ListView.builder(
          itemCount: children.length,
          itemBuilder: (context, index) {
            return Draggable<int>(
              data: children[index].id,
              feedback: feedback,
              childWhenDragging: children[index].draggingChild ??
                  draggingChild ??
                  Opacity(
                    opacity: 0.5,
                    child: children[index].child,
                  ),
              child: children[index].child,
            );
          },
        );
      },
      onAcceptWithDetails: onAcceptWithDetails,
    );
  }
}
