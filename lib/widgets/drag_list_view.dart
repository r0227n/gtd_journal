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
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.isThreeLine = false,
    this.onTap,
    this.onLongPress,
  });

  /// The unique identifier for the drag list
  final int? listId;

  /// The unique identifier for the drag list item
  final int itemId;

  final Widget? leading;

  /// The main widget to display for the item
  final Widget title;

  final Widget? subtitle;

  final Widget? trailing;

  final bool isThreeLine;

  /// Called when the user taps this list tile.
  ///
  /// Inoperative if [enabled] is false.
  final GestureTapCallback? onTap;

  /// Called when the user long-presses on this list tile.
  ///
  /// Inoperative if [enabled] is false.
  final GestureLongPressCallback? onLongPress;

  DragListItem copyWith({
    int? listId,
    int? itemId,
    Widget? leading,
    Widget? title,
    Widget? subtitle,
    Widget? trailing,
    bool? isThreeLine,
    GestureTapCallback? onTap,
    GestureLongPressCallback? onLongPress,
  }) {
    return DragListItem(
      listId: listId ?? this.listId,
      itemId: itemId ?? this.itemId,
      leading: leading ?? this.leading,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      trailing: trailing ?? this.trailing,
      isThreeLine: isThreeLine ?? this.isThreeLine,
      onTap: onTap ?? this.onTap,
      onLongPress: onLongPress ?? this.onLongPress,
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

  /// Callback function that is called when an item is accepted by a [DragTarget].
  final void Function(DragTargetAcceptWithDetailsValue) onAcceptWithDetails;

  @override
  State<DragListView> createState() => _DragListViewState();

  DragListView copyWith({
    int? id,
    List<DragListItem>? children,
    Widget? feedback,
    void Function(DragTargetAcceptWithDetailsValue)? onAcceptWithDetails,
  }) {
    return DragListView(
      id: id ?? this.id,
      children: children ?? this.children,
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
            return ListTile(
              key: ValueKey(item.itemId),
              leading: item.leading,
              title: Draggable<DragListItem>(
                data: item,
                feedback: Material(child: item.title),
                childWhenDragging: Opacity(
                  opacity: 0.5,
                  child: item.title,
                ),
                child: item.title,
              ),
              subtitle: item.subtitle,
              trailing: item.trailing != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 24.0),
                      child: item.trailing,
                    )
                  : null,
              isThreeLine: item.isThreeLine,
              onTap: item.onTap,
              onLongPress: item.onLongPress,
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
