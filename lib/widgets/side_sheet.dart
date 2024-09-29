import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const Duration _sideSheetEnterDuration = Duration(milliseconds: 250);
const Duration _sideSheetExitDuration = Duration(milliseconds: 200);
const Curve _modalSideSheetCurve = decelerateEasing;
const double _minFlingVelocity = 700.0;
const double _closeProgressThreshold = 0.5;

/// Not implemented rtl yet
enum SideSheetDirection {
  /// Not implemented yet
  top,
  bottom,

  /// Not implemented yet
  start,
  end,
}

extension SideSheetDirectionX on SideSheetDirection {
  bool get isVertical => this == SideSheetDirection.top || this == SideSheetDirection.bottom;
}

/// ref. https://github.com/flutter/flutter/issues/18030
class SideSheet extends StatefulWidget {
  /// Creates a bottom sheet.
  ///
  /// Typically, bottom sheets are created implicitly by
  /// [ScaffoldState.showSideSheet], for persistent bottom sheets, or by
  /// [showModalSideSheet], for modal bottom sheets.
  const SideSheet({
    Key? key,
    this.animationController,
    this.enableDrag = true,
    this.onDragStart,
    this.onDragEnd,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.clipBehavior,
    required this.onClosing,
    required this.builder,
    required this.direction,
  })  : assert(elevation == null || elevation >= 0.0),
        super(key: key);

  /// The animation controller that controls the bottom sheet's entrance and
  /// exit animations.
  ///
  /// The SideSheet widget will manipulate the position of this animation, it
  /// is not just a passive observer.
  final AnimationController? animationController;

  /// Called when the bottom sheet begins to close.
  ///
  /// A bottom sheet might be prevented from closing (e.g., by user
  /// interaction) even after this callback is called. For this reason, this
  /// callback might be call multiple times for a given bottom sheet.
  final VoidCallback onClosing;

  /// A builder for the contents of the sheet.
  ///
  /// The bottom sheet will wrap the widget produced by this builder in a
  /// [Material] widget.
  final WidgetBuilder builder;

  /// If true, the bottom sheet can be dragged up and down and dismissed by
  /// swiping downwards.
  ///
  /// Default is true.
  final bool enableDrag;

  /// Called when the user begins dragging the bottom sheet vertically, if
  /// [enableDrag] is true.
  ///
  /// Would typically be used to change the bottom sheet animation curve so
  /// that it tracks the user's finger accurately.
  final BottomSheetDragStartHandler? onDragStart;

  /// Called when the user stops dragging the bottom sheet, if [enableDrag]
  /// is true.
  ///
  /// Would typically be used to reset the bottom sheet animation curve, so
  /// that it animates non-linearly. Called before [onClosing] if the bottom
  /// sheet is closing.
  final BottomSheetDragEndHandler? onDragEnd;

  /// The bottom sheet's background color.
  ///
  /// Defines the bottom sheet's [Material.color].
  ///
  /// Defaults to null and falls back to [Material]'s default.
  final Color? backgroundColor;

  /// The z-coordinate at which to place this material relative to its parent.
  ///
  /// This controls the size of the shadow below the material.
  ///
  /// Defaults to 0. The value is non-negative.
  final double? elevation;

  /// The shape of the bottom sheet.
  ///
  /// Defines the bottom sheet's [Material.shape].
  ///
  /// Defaults to null and falls back to [Material]'s default.
  final ShapeBorder? shape;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defines the bottom sheet's [Material.clipBehavior].
  ///
  /// Use this property to enable clipping of content when the bottom sheet has
  /// a custom [shape] and the content can extend past this shape. For example,
  /// a bottom sheet with rounded corners and an edge-to-edge [Image] at the
  /// top.
  ///
  /// If this property is null then [SideSheetThemeData.clipBehavior] of
  /// [ThemeData.bottomSheetTheme] is used. If that's null then the behavior
  /// will be [Clip.none].
  final Clip? clipBehavior;

  final SideSheetDirection direction;

  @override
  _SideSheetState createState() => _SideSheetState();

  /// Creates an [AnimationController] suitable for a
  /// [SideSheet.animationController].
  ///
  /// This API available as a convenience for a Material compliant bottom sheet
  /// animation. If alternative animation durations are required, a different
  /// animation controller could be provided.
  static AnimationController createAnimationController(TickerProvider vsync) {
    return AnimationController(
      duration: _sideSheetEnterDuration,
      reverseDuration: _sideSheetExitDuration,
      debugLabel: 'SideSheet',
      vsync: vsync,
    );
  }
}

class _SideSheetState extends State<SideSheet> {
  final GlobalKey _childKey = GlobalKey(debugLabel: 'SideSheet child');

  double get _childDimension {
    final RenderBox renderBox = _childKey.currentContext!.findRenderObject()! as RenderBox;
    return widget.direction.isVertical ? renderBox.size.height : renderBox.size.width;
  }

  bool get _dismissUnderway => widget.animationController!.status == AnimationStatus.reverse;

  void _handleDragStart(DragStartDetails details) {
    if (widget.onDragStart != null) {
      widget.onDragStart!(details);
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    assert(widget.enableDrag);
    if (_dismissUnderway) return;
    widget.animationController!.value -= details.primaryDelta! / _childDimension;
  }

  void _handleDragEnd(DragEndDetails details) {
    assert(widget.enableDrag);
    if (_dismissUnderway) return;
    bool isClosing = false;
    if ((widget.direction.isVertical
            ? details.velocity.pixelsPerSecond.dy
            : details.velocity.pixelsPerSecond.dx) >
        _minFlingVelocity) {
      final double flingVelocity = (widget.direction.isVertical
              ? -details.velocity.pixelsPerSecond.dy
              : -details.velocity.pixelsPerSecond.dx) /
          _childDimension;
      if (widget.animationController!.value > 0.0) {
        widget.animationController!.fling(velocity: flingVelocity);
      }
      if (flingVelocity < 0.0) {
        isClosing = true;
      }
    } else if (widget.animationController!.value < _closeProgressThreshold) {
      if (widget.animationController!.value > 0.0)
        widget.animationController!.fling(velocity: -1.0);
      isClosing = true;
    } else {
      widget.animationController!.forward();
    }

    if (widget.onDragEnd != null) {
      widget.onDragEnd!(
        details,
        isClosing: isClosing,
      );
    }

    if (isClosing) {
      widget.onClosing();
    }
  }

  bool extentChanged(DraggableScrollableNotification notification) {
    if (notification.extent == notification.minExtent) {
      widget.onClosing();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final BottomSheetThemeData bottomSheetTheme = Theme.of(context).bottomSheetTheme;
    final Color? color = widget.backgroundColor ?? bottomSheetTheme.backgroundColor;
    final double elevation = widget.elevation ?? bottomSheetTheme.elevation ?? 0;
    final ShapeBorder? shape = widget.shape ?? bottomSheetTheme.shape;
    final Clip clipBehavior = widget.clipBehavior ?? bottomSheetTheme.clipBehavior ?? Clip.none;

    final Widget bottomSheet = Material(
      key: _childKey,
      color: color,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      child: NotificationListener<DraggableScrollableNotification>(
        onNotification: extentChanged,
        child: widget.direction.isVertical
            ? widget.builder(context)
            : SafeArea(top: false, child: widget.builder(context)),
      ),
    );
    final Widget safeBottomSheet = widget.direction.isVertical
        ? bottomSheet
        : SafeArea(top: true, left: false, right: false, child: bottomSheet);
    return !widget.enableDrag
        ? safeBottomSheet
        : GestureDetector(
            onHorizontalDragStart: !widget.direction.isVertical ? _handleDragStart : null,
            onHorizontalDragUpdate: !widget.direction.isVertical ? _handleDragUpdate : null,
            onHorizontalDragEnd: !widget.direction.isVertical ? _handleDragEnd : null,
            onVerticalDragStart: widget.direction.isVertical ? _handleDragStart : null,
            onVerticalDragUpdate: widget.direction.isVertical ? _handleDragUpdate : null,
            onVerticalDragEnd: widget.direction.isVertical ? _handleDragEnd : null,
            child: safeBottomSheet,
            excludeFromSemantics: true,
          );
  }
}

// PERSISTENT BOTTOM SHEETS

// See scaffold.dart

// MODAL BOTTOM SHEETS
class _ModalSideSheetLayout extends SingleChildLayoutDelegate {
  const _ModalSideSheetLayout(
    this.progress,
    this.isScrollControlled,
    this.direction,
  );

  final double progress;
  final bool isScrollControlled;
  final SideSheetDirection direction;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return direction.isVertical
        ? BoxConstraints(
            minWidth: constraints.maxWidth,
            maxWidth: constraints.maxWidth,
            minHeight: 0.0,
            maxHeight:
                isScrollControlled ? constraints.maxHeight : constraints.maxHeight * 9.0 / 16.0,
          )
        : BoxConstraints(
            minWidth: 0.0,
            maxWidth: isScrollControlled ? constraints.maxWidth : constraints.maxWidth * 9.0 / 16.0,
            minHeight: constraints.maxHeight,
            maxHeight: constraints.maxHeight,
          );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return direction.isVertical
        ? Offset(0.0, size.height - childSize.height * progress)
        : Offset(size.width - childSize.width * progress, 0.0);
  }

  @override
  bool shouldRelayout(_ModalSideSheetLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

class _ModalSideSheet<T> extends StatefulWidget {
  const _ModalSideSheet({
    Key? key,
    this.route,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.clipBehavior,
    this.isScrollControlled = false,
    this.enableDrag = true,
    required this.direction,
  }) : super(key: key);

  final _ModalSideSheetRoute<T>? route;
  final bool isScrollControlled;
  final Color? backgroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final Clip? clipBehavior;
  final bool enableDrag;
  final SideSheetDirection direction;

  @override
  _ModalSideSheetState<T> createState() => _ModalSideSheetState<T>();
}

class _ModalSideSheetState<T> extends State<_ModalSideSheet<T>> {
  ParametricCurve<double> animationCurve = _modalSideSheetCurve;

  String _getRouteLabel(MaterialLocalizations localizations) {
    switch (Theme.of(context).platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return '';
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return localizations.dialogLabel;
    }
  }

  void handleDragStart(DragStartDetails details) {
    // Allow the bottom sheet to track the user's finger accurately.
    animationCurve = Curves.linear;
  }

  void handleDragEnd(DragEndDetails details, {bool? isClosing}) {
    // Allow the bottom sheet to animate smoothly from its current position.
    animationCurve = _SideSheetSuspendedCurve(
      widget.route!.animation!.value,
      curve: _modalSideSheetCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    assert(debugCheckHasMaterialLocalizations(context));
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);
    final String routeLabel = _getRouteLabel(localizations);

    return AnimatedBuilder(
      animation: widget.route!.animation!,
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: SideSheet(
          animationController: widget.route!._animationController,
          onClosing: () {
            if (widget.route!.isCurrent) {
              Navigator.pop(context);
            }
          },
          builder: widget.route!.builder!,
          backgroundColor: widget.backgroundColor,
          elevation: widget.elevation,
          shape: widget.shape,
          clipBehavior: widget.clipBehavior,
          enableDrag: widget.enableDrag,
          onDragStart: handleDragStart,
          onDragEnd: handleDragEnd,
          direction: widget.direction,
        ),
      ),
      builder: (BuildContext context, Widget? child) {
        // Disable the initial animation when accessible navigation is on so
        // that the semantics are added to the tree at the correct time.
        final double animationValue = animationCurve
            .transform(mediaQuery.accessibleNavigation ? 1.0 : widget.route!.animation!.value);
        return Semantics(
          scopesRoute: true,
          namesRoute: true,
          label: routeLabel,
          explicitChildNodes: true,
          child: ClipRect(
            child: CustomSingleChildLayout(
              delegate: _ModalSideSheetLayout(
                  animationValue, widget.isScrollControlled, widget.direction),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _ModalSideSheetRoute<T> extends PopupRoute<T> {
  _ModalSideSheetRoute({
    this.builder,
    required this.capturedThemes,
    this.barrierLabel,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.clipBehavior,
    this.modalBarrierColor,
    this.isDismissible = true,
    this.enableDrag = true,
    required this.isScrollControlled,
    RouteSettings? settings,
    this.transitionAnimationController,
    required this.direction,
  }) : super(settings: settings);

  final WidgetBuilder? builder;
  final CapturedThemes capturedThemes;
  final bool isScrollControlled;
  final Color? backgroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final Clip? clipBehavior;
  final Color? modalBarrierColor;
  final bool isDismissible;
  final bool enableDrag;
  final AnimationController? transitionAnimationController;
  final SideSheetDirection direction;

  @override
  Duration get transitionDuration => _sideSheetEnterDuration;

  @override
  Duration get reverseTransitionDuration => _sideSheetExitDuration;

  @override
  bool get barrierDismissible => isDismissible;

  @override
  final String? barrierLabel;

  @override
  Color get barrierColor => modalBarrierColor ?? Colors.black54;

  AnimationController? _animationController;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    _animationController =
        transitionAnimationController ?? BottomSheet.createAnimationController(navigator!.overlay!);
    return _animationController!;
  }

  @override
  Widget buildPage(
      BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    // By definition, the bottom sheet is aligned to the bottom of the page
    // and isn't exposed to the top padding of the MediaQuery.
    final Widget bottomSheet = MediaQuery.removePadding(
      context: context,
      removeTop: direction == SideSheetDirection.bottom,
      // Conflicts with SafeArea
      //removeLeft: Directionality.of(context) == TextDirection.rtl
      //    ? direction == SideSheetDirection.end
      //    : direction == SideSheetDirection.start,
      //removeRight: Directionality.of(context) == TextDirection.rtl
      //    ? direction == SideSheetDirection.start
      //    : direction == SideSheetDirection.end,
      //removeBottom: direction == SideSheetDirection.top,
      child: Builder(
        builder: (BuildContext context) {
          final BottomSheetThemeData sheetTheme = Theme.of(context).bottomSheetTheme;
          return _ModalSideSheet<T>(
            route: this,
            backgroundColor:
                backgroundColor ?? sheetTheme.modalBackgroundColor ?? sheetTheme.backgroundColor,
            elevation: elevation ?? sheetTheme.modalElevation ?? sheetTheme.elevation,
            shape: shape,
            clipBehavior: clipBehavior,
            isScrollControlled: isScrollControlled,
            enableDrag: enableDrag,
            direction: direction,
          );
        },
      ),
    );
    return capturedThemes.wrap(bottomSheet);
  }
}

// TODO(guidezpl): Look into making this public. A copy of this class is in
//  scaffold.dart, for now, https://github.com/flutter/flutter/issues/51627
/// A curve that progresses linearly until a specified [startingPoint], at which
/// point [curve] will begin. Unlike [Interval], [curve] will not start at zero,
/// but will use [startingPoint] as the Y position.
///
/// For example, if [startingPoint] is set to `0.5`, and [curve] is set to
/// [Curves.easeOut], then the bottom-left quarter of the curve will be a
/// straight line, and the top-right quarter will contain the entire contents of
/// [Curves.easeOut].
///
/// This is useful in situations where a widget must track the user's finger
/// (which requires a linear animation), and afterwards can be flung using a
/// curve specified with the [curve] argument, after the finger is released. In
/// such a case, the value of [startingPoint] would be the progress of the
/// animation at the time when the finger was released.
///
/// The [startingPoint] and [curve] arguments must not be null.
class _SideSheetSuspendedCurve extends ParametricCurve<double> {
  /// Creates a suspended curve.
  const _SideSheetSuspendedCurve(
    this.startingPoint, {
    this.curve = Curves.easeOutCubic,
  });

  /// The progress value at which [curve] should begin.
  ///
  /// This defaults to [Curves.easeOutCubic].
  final double startingPoint;

  /// The curve to use when [startingPoint] is reached.
  final Curve curve;

  @override
  double transform(double t) {
    assert(t >= 0.0 && t <= 1.0);
    assert(startingPoint >= 0.0 && startingPoint <= 1.0);

    if (t < startingPoint) {
      return t;
    }

    if (t == 1.0) {
      return t;
    }

    final double curveProgress = (t - startingPoint) / (1 - startingPoint);
    final double transformed = curve.transform(curveProgress);
    return lerpDouble(startingPoint, 1, transformed)!;
  }

  @override
  String toString() {
    return '${describeIdentity(this)}($startingPoint, $curve)';
  }
}

/// Shows a modal material design bottom sheet.
///
/// A modal bottom sheet is an alternative to a menu or a dialog and prevents
/// the user from interacting with the rest of the app.
///
/// A closely related widget is a persistent bottom sheet, which shows
/// information that supplements the primary content of the app without
/// preventing the use from interacting with the app. Persistent bottom sheets
/// can be created and displayed with the [showSideSheet] function or the
/// [ScaffoldState.showSideSheet] method.
///
/// The `context` argument is used to look up the [Navigator] and [Theme] for
/// the bottom sheet. It is only used when the method is called. Its
/// corresponding widget can be safely removed from the tree before the bottom
/// sheet is closed.
///
/// The `isScrollControlled` parameter specifies whether this is a route for
/// a bottom sheet that will utilize [DraggableScrollableSheet]. If you wish
/// to have a bottom sheet that has a scrollable child such as a [ListView] or
/// a [GridView] and have the bottom sheet be draggable, you should set this
/// parameter to true.
///
/// The `useRootNavigator` parameter ensures that the root navigator is used to
/// display the [SideSheet] when set to `true`. This is useful in the case
/// that a modal [SideSheet] needs to be displayed above all other content
/// but the caller is inside another [Navigator].
///
/// The [isDismissible] parameter specifies whether the bottom sheet will be
/// dismissed when user taps on the scrim.
///
/// The [enableDrag] parameter specifies whether the bottom sheet can be
/// dragged up and down and dismissed by swiping downwards.
///
/// The optional [backgroundColor], [elevation], [shape], [clipBehavior] and [transitionAnimationController]
/// parameters can be passed in to customize the appearance and behavior of
/// modal bottom sheets.
///
/// The [transitionAnimationController] controls the bottom sheet's entrance and
/// exit animations if provided.
///
/// The optional `routeSettings` parameter sets the [RouteSettings] of the modal bottom sheet
/// sheet. This is particularly useful in the case that a user wants to observe
/// [PopupRoute]s within a [NavigatorObserver].
///
/// Returns a `Future` that resolves to the value (if any) that was passed to
/// [Navigator.pop] when the modal bottom sheet was closed.
///
/// {@tool dartpad --template=stateless_widget_scaffold}
///
/// This example demonstrates how to use `showModalSideSheet` to display a
/// bottom sheet that obscures the content behind it when a user taps a button.
/// It also demonstrates how to close the bottom sheet using the [Navigator]
/// when a user taps on a button inside the bottom sheet.
///
/// ```dart
/// Widget build(BuildContext context) {
///   return Center(
///     child: ElevatedButton(
///       child: const Text('showModalSideSheet'),
///       onPressed: () {
///         showModalSideSheet<void>(
///           context: context,
///           builder: (BuildContext context) {
///             return Container(
///               height: 200,
///               color: Colors.amber,
///               child: Center(
///                 child: Column(
///                   mainAxisAlignment: MainAxisAlignment.center,
///                   mainAxisSize: MainAxisSize.min,
///                   children: <Widget>[
///                     const Text('Modal SideSheet'),
///                     ElevatedButton(
///                       child: const Text('Close SideSheet'),
///                       onPressed: () => Navigator.pop(context),
///                     )
///                   ],
///                 ),
///               ),
///             );
///           },
///         );
///       },
///     ),
///   );
/// }
/// ```
/// {@end-tool}
/// See also:
///
///  * [SideSheet], which becomes the parent of the widget returned by the
///    function passed as the `builder` argument to [showModalSideSheet].
///  * [showSideSheet] and [ScaffoldState.showSideSheet], for showing
///    non-modal bottom sheets.
///  * [DraggableScrollableSheet], which allows you to create a bottom sheet
///    that grows and then becomes scrollable once it reaches its maximum size.
///  * <https://material.io/design/components/sheets-bottom.html#modal-bottom-sheet>
Future<T?> showModalSideSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  double? elevation,
  ShapeBorder? shape,
  Clip? clipBehavior,
  Color? barrierColor,
  bool isScrollControlled = false,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
  RouteSettings? routeSettings,
  AnimationController? transitionAnimationController,
  SideSheetDirection direction = SideSheetDirection.end,
}) {
  assert(debugCheckHasMediaQuery(context));
  assert(debugCheckHasMaterialLocalizations(context));

  final NavigatorState navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  return navigator.push(_ModalSideSheetRoute<T>(
    builder: builder,
    capturedThemes: InheritedTheme.capture(from: context, to: navigator.context),
    isScrollControlled: isScrollControlled,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    backgroundColor: backgroundColor,
    elevation: elevation,
    shape: shape,
    clipBehavior: clipBehavior,
    isDismissible: isDismissible,
    modalBarrierColor: barrierColor,
    enableDrag: enableDrag,
    settings: routeSettings,
    transitionAnimationController: transitionAnimationController,
    direction: direction,
  ));
}
