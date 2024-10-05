import 'package:flutter/material.dart';

class FolderListTile extends StatefulWidget {
  const FolderListTile({
    super.key,
    required this.title,
    required this.children,
    this.trailing,
  });

  final Widget title;
  final List<Widget> children;
  final Widget? trailing;

  @override
  _FolderListTileState createState() => _FolderListTileState();
}

class _FolderListTileState extends State<FolderListTile> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  late AnimationController _controller;
  late Animation<double> _iconRotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _iconRotation = Tween<double>(begin: 0.0, end: 0.5).animate(_controller);
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: RotationTransition(
            turns: _iconRotation,
            child: IconButton(
              icon: const Icon(Icons.expand_more),
              onPressed: _toggleExpansion,
            ),
          ),
          title: widget.title,
          trailing: widget.trailing,
          onTap: _toggleExpansion,
        ),
        if (_isExpanded)
          Column(
            children: widget.children,
          ),
      ],
    );
  }
}
