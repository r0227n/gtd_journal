import 'package:flutter/material.dart';

/// A typedef representing the signature of a callback function that is called when a drag target accepts a draggable item with additional details.
///
/// The [fromListId] parameter represents the ID of the list from which the item is being dragged.
/// The [toListId] parameter represents the ID of the list to which the item is being dragged.
/// The [itemId] parameter represents the ID of the item being dragged.
typedef DragTargetAcceptWithDetailsValue = ({
  int? fromListId,
  int? toListId,
  int itemId,
});

class DragListItem {
  const DragListItem({
    this.listId,
    required this.itemId,
    this.draggingChild,
    required this.child,
  });

  /// The unique identifier for the drag list
  final int? listId;

  /// The unique identifier for the drag list item
  final int itemId;

  /// The widget to display when the item is being dragged
  final Widget? draggingChild;

  /// The main widget to display for the item
  final Widget child;

  DragListItem copyWith({
    int? listId,
    int? itemId,
    Widget? draggingChild,
    Widget? child,
  }) {
    return DragListItem(
      listId: listId ?? this.listId,
      itemId: itemId ?? this.itemId,
      draggingChild: draggingChild ?? this.draggingChild,
      child: child ?? this.child,
    );
  }
}

/// A widget that displays a list of draggable items.
class DragListView extends StatelessWidget {
  DragListView({
    super.key,
    this.id,
    required List<DragListItem> items,
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
  }) : children = items.map((e) => e.copyWith(listId: id)).toList();

  /// The unique identifier for the drag list
  final int? id;

  /// The list of draggable items to display.
  final List<DragListItem> children;

  /// The widget to display as feedback when an item is being dragged.
  final Widget feedback;

  /// The widget to display as the dragged item.
  final Widget? draggingChild;

  /// Callback function that is called when an item is accepted by a [DragTarget].
  final void Function(DragTargetAcceptWithDetailsValue) onAcceptWithDetails;

  @override
  Widget build(BuildContext context) {
    return DragTarget<DragListItem>(
      builder: (
        BuildContext context,
        List<dynamic> accepted,
        List<dynamic> rejected,
      ) {
        return ListView.builder(
          itemCount: children.length,
          itemBuilder: (context, index) {
            return Draggable<DragListItem>(
              data: children[index],
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
      onAcceptWithDetails: (details) {
        // If the item is being dragged to the same list, do nothing
        if (details.data.listId == id) {
          return;
        }

        onAcceptWithDetails((
          fromListId: details.data.listId,
          toListId: id,
          itemId: details.data.itemId,
        ));
      },
    );
  }

  DragListView copyWith({
    int? id,
    List<DragListItem>? children,
    Widget? feedback,
    Widget? draggingChild,
    void Function(DragTargetAcceptWithDetailsValue)? onAcceptWithDetails,
  }) {
    return DragListView(
      id: id ?? this.id,
      items: children ?? this.children,
      feedback: feedback ?? this.feedback,
      draggingChild: draggingChild ?? this.draggingChild,
      onAcceptWithDetails: onAcceptWithDetails ?? this.onAcceptWithDetails,
    );
  }
}
