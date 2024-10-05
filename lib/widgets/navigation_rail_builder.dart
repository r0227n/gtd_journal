import 'package:flutter/material.dart';
import 'split_view.dart';

/// A builder class for creating a custom navigation rail destination widget.
///
/// The `RailWidgetBuilder` class allows you to define a custom navigation rail
/// destination with various properties such as icons, labels, padding, and more.
///
/// The class provides the following properties:
///
/// - `icon`: The icon of the destination. Typically an [Icon] or an [ImageIcon]
///   widget. If another type of widget is provided, it should configure itself
///   to match the current [IconTheme] size and color. If [selectedIcon] is
///   provided, this will only be displayed when the destination is not selected.
///   To make the [NavigationRail] more accessible, consider choosing an icon
///   with a stroked and filled version, such as [Icons.cloud] and
///   [Icons.cloud_queue]. The [icon] should be set to the stroked version and
///   [selectedIcon] to the filled version.
///
/// - `selectedIcon`: An alternative icon displayed when this destination is
///   selected. If this icon is not provided, the [NavigationRail] will display
///   [icon] in either state. The size, color, and opacity of the
///   [NavigationRail.selectedIconTheme] will still apply.
///
/// - `indicatorColor`: The color of the [indicatorShape] when this destination
///   is selected.
///
/// - `indicatorShape`: The shape of the indicator when this destination is
///   selected.
///
/// - `label`: The label of the destination.
///
/// - `padding`: The padding around the destination.
///
/// - `disabled`: Indicates that this destination is inaccessible.
///
/// - `description`: An optional description for the destination.
///
/// - `builder`: A [WidgetBuilder] that builds the custom widget for the
///   destination.
class RailWidgetBuilder {
  const RailWidgetBuilder({
    required this.icon,
    Widget? selectedIcon,
    this.indicatorColor,
    this.indicatorShape,
    required this.label,
    this.padding,
    this.disabled = false,
    this.description,
    required this.builder,
  }) : selectedIcon = selectedIcon ?? icon;

  /// The icon of the destination.
  final Widget icon;

  /// An alternative icon displayed when this destination is selected.
  final Widget selectedIcon;

  /// The color of the [indicatorShape] when this destination is selected.
  final Color? indicatorColor;

  final ShapeBorder? indicatorShape;

  /// The label of the destination.
  final Widget label;

  /// The padding around the destination.
  final EdgeInsetsGeometry? padding;

  /// Indicates that this destination is inaccessible.
  final bool disabled;

  /// An optional description for the destination.
  final Widget? description;

  /// A [WidgetBuilder] that builds the custom widget for the destination.
  final WidgetBuilder builder;
}

class NavigationRailBuilder extends StatefulWidget {
  const NavigationRailBuilder({
    super.key,
    this.index = 0,
    required this.destinations,
    this.initialOpenDescription = true,
  });

  final int index;
  final List<RailWidgetBuilder> destinations;
  final bool initialOpenDescription;

  @override
  State<NavigationRailBuilder> createState() => _NavigationRailBuilderState();
}

class _NavigationRailBuilderState extends State<NavigationRailBuilder> {
  late int selectedRailIndex;
  late bool openDescription;

  @override
  void initState() {
    super.initState();
    selectedRailIndex = widget.index;
    openDescription = widget.initialOpenDescription;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: NavigationRail(
              minWidth: 50,
              destinations: widget.destinations
                  .map((e) => NavigationRailDestination(
                        icon: e.icon,
                        selectedIcon: e.selectedIcon,
                        indicatorColor: e.indicatorColor,
                        indicatorShape: e.indicatorShape,
                        label: e.label,
                        padding: e.padding,
                        disabled: e.disabled,
                      ))
                  .toList(),
              selectedIndex: selectedRailIndex,
              useIndicator: true,
              onDestinationSelected: (int index) {
                setState(() {
                  if (toggleOpenDescription(index)) {
                    openDescription = !openDescription;
                  }
                  selectedRailIndex = index;
                });
              },
            ),
          ),
          Expanded(
            child: SplitView(
              children: [
                if (widget.destinations[selectedRailIndex].description != null && openDescription)
                  widget.destinations[selectedRailIndex].description!,
                widget.destinations[selectedRailIndex].builder(context),
              ],
            ),
          )
        ],
      ),
    );
  }

  bool toggleOpenDescription(int index) {
    return selectedRailIndex != index && !openDescription || selectedRailIndex == index;
  }
}
