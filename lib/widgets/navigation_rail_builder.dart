import 'package:flutter/material.dart';
import 'split_view.dart';

class RailWidgetBuilder {
  const RailWidgetBuilder({
    required this.icon,
    Widget? selectedIcon,
    this.indicatorColor,
    this.indicatorShape,
    required this.label,
    this.padding,
    this.disabled = false,
    this.panel,
    required this.children,
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

  /// An optional panel for the destination.
  final Widget? panel;

  /// The widget to display when this destination is selected.
  final List<Widget> children;
}

class NavigationRailBuilder extends StatefulWidget {
  const NavigationRailBuilder({
    super.key,
    this.index = 0,
    this.minWidth = 50,
    required this.destinations,
    this.initialOpenPanel = true,
  });

  final int index;
  final double minWidth;
  final List<RailWidgetBuilder> destinations;
  final bool initialOpenPanel;

  @override
  State<NavigationRailBuilder> createState() => _NavigationRailBuilderState();
}

class _NavigationRailBuilderState extends State<NavigationRailBuilder> {
  late int selectedRailIndex;
  late bool openPanel;

  @override
  void initState() {
    super.initState();
    selectedRailIndex = widget.index;
    openPanel = widget.initialOpenPanel;
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
                  if (toggleOpenPanel(index)) {
                    openPanel = !openPanel;
                  }
                  selectedRailIndex = index;
                });
              },
            ),
          ),
          Expanded(
            child: SplitView(
              constraints: BoxConstraints(minWidth: widget.minWidth),
              children: [
                if (widget.destinations[selectedRailIndex].panel != null && openPanel)
                  widget.destinations[selectedRailIndex].panel!,
                if (widget.destinations[selectedRailIndex].children.isEmpty)
                  const SizedBox.square(dimension: 100),
                ...widget.destinations[selectedRailIndex].children,
              ],
            ),
          )
        ],
      ),
    );
  }

  bool toggleOpenPanel(int index) {
    return selectedRailIndex != index && !openPanel || selectedRailIndex == index;
  }
}
