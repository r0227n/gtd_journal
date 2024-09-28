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

class DragListView extends StatefulWidget {
  const DragListView({
    super.key,
    this.id,
    required this.children,
    this.leading,
    this.title,
    this.actions = const <Widget>[],
    this.draggingChild,
    required this.onAcceptWithDetails,
  });

  /// The unique identifier for the drag list
  final int? id;

  /// The list of draggable items to display.
  final List<DragListItem> children;

  /// The leading widget to display at the top of the list.
  final Widget? leading;

  /// The title to display at the top of the list.
  final Widget? title;

  /// The list of actions to display at the top of the list.
  final List<Widget> actions;

  /// The widget to display as the dragged item.
  final Widget? draggingChild;

  /// Callback function that is called when an item is accepted by a [DragTarget].
  final void Function(DragTargetAcceptWithDetailsValue) onAcceptWithDetails;

  @override
  State<DragListView> createState() => _DragListViewState();

  DragListView copyWith({
    int? id,
    List<DragListItem>? children,
    Widget? feedback,
    Widget? draggingChild,
    void Function(DragTargetAcceptWithDetailsValue)? onAcceptWithDetails,
  }) {
    return DragListView(
      id: id ?? this.id,
      children: children ?? this.children,
      draggingChild: draggingChild ?? this.draggingChild,
      onAcceptWithDetails: onAcceptWithDetails ?? this.onAcceptWithDetails,
    );
  }
}

class _DragListViewState extends State<DragListView> {
  List<DragListItem> children = [];
  @override
  void initState() {
    super.initState();
    children = widget.children.map((e) => e.copyWith(listId: e.listId ?? widget.id)).toList();
  }

  @override
  void didUpdateWidget(covariant DragListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    children = widget.children.map((e) => e.copyWith(listId: e.listId ?? widget.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<DragListItem>(
      builder: (
        BuildContext context,
        List<dynamic> accepted,
        List<dynamic> rejected,
      ) {
        return ReorderableListView(
          header: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.leading != null || widget.title != null || widget.actions.isNotEmpty
                ? [
                    Row(
                      children: [
                        if (widget.leading != null) widget.leading!,
                        if (widget.title != null) widget.title!,
                        const Spacer(),
                        for (var index = 0; index < widget.actions.length; index++)
                          Padding(
                            padding: index == widget.actions.length - 1
                                ? const EdgeInsets.only(right: 16.0)
                                : const EdgeInsets.only(right: 24.0),
                            child: widget.actions[index],
                          ),
                      ],
                    ),
                    const Divider(),
                  ]
                : const <Widget>[],
          ),
          onReorder: (oldIndex, newIndex) {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            setState(() {
              final item = children.removeAt(oldIndex);
              children.insert(newIndex, item);
            });
          },
          children: children.map((item) {
            return Draggable<DragListItem>(
              key: ValueKey(item.itemId),
              data: item,
              feedback: Material(child: item.child),
              childWhenDragging: item.draggingChild ??
                  widget.draggingChild ??
                  Opacity(
                    opacity: 0.5,
                    child: item.child,
                  ),
              child: item.child,
            );
          }).toList(),
        );
      },
      onAcceptWithDetails: (details) {
        // If the item is being dragged to the same list, do nothing
        if (details.data.listId == widget.id) {
          return;
        }

        widget.onAcceptWithDetails((
          fromListId: details.data.listId,
          toListId: widget.id,
          itemId: details.data.itemId,
        ));
      },
    );
  }
}
