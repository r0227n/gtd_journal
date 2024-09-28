import 'package:flutter/material.dart';
import 'widgets/widgets.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SplitViewDemo(),
    );
  }
}

class SplitViewDemo extends StatefulWidget {
  const SplitViewDemo({super.key});

  @override
  _SplitViewDemoState createState() => _SplitViewDemoState();
}

class _SplitViewDemoState extends State<SplitViewDemo> {
  void onAcceptWithDetails(DragTargetAcceptWithDetailsValue details) {
    final dragListItem = children
        .expand((element) => element.children)
        .firstWhere((element) => element.itemId == details.itemId);
    final fromList = children.firstWhere((fromList) => fromList.id == details.fromListId);
    final toList = children.firstWhere((toList) => toList.id == details.toListId);

    fromList.children.remove(dragListItem);
    toList.children.add(dragListItem);

    setState(() {
      children = [
        for (final child in children)
          if (child.id == details.fromListId)
            child.copyWith(children: fromList.children)
          else if (child.id == toList.id)
            child.copyWith(children: toList.children)
          else
            child,
      ];
    });
  }

  List<DragListView> children = [];

  @override
  void initState() {
    super.initState();
    children.add(
      DragListView(
        id: 1,
        title: const Text('List 1'),
        children: [
          DragListItem(
            itemId: 1,
            child: Container(
              color: Colors.red[100],
              child: const Center(child: Text('View A')),
            ),
          ),
          DragListItem(
            itemId: 2,
            child: Container(
              color: Colors.green[100],
              child: const Center(child: Text('View B')),
            ),
          ),
          DragListItem(
            itemId: 3,
            child: Container(
              color: Colors.blue[100],
              child: const Center(child: Text('View C')),
            ),
          ),
        ],
        actions: [const Icon(Icons.add), const Icon(Icons.remove)]
            .map((e) => IconButton(
                icon: e,
                onPressed: () {
                  showModalSideSheet(
                    context: context,
                    builder: (context) => const Center(child: Text('hoge')),
                  );
                }))
            .toList(),
        onAcceptWithDetails: (details) {
          onAcceptWithDetails(details);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Split View Demo'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                children.add(
                  DragListView(
                    id: 2,
                    children: [
                      DragListItem(
                        itemId: 4,
                        child: Container(
                          color: Colors.red[100],
                          child: const Center(child: Text('View D')),
                        ),
                      ),
                      DragListItem(
                        itemId: 5,
                        child: Container(
                          color: Colors.green[100],
                          child: const Center(child: Text('View E')),
                        ),
                      ),
                      DragListItem(
                        itemId: 6,
                        child: Container(
                          color: Colors.blue[100],
                          child: const Center(child: Text('View F')),
                        ),
                      ),
                    ],
                    actions: const [Text('hoge')],
                    onAcceptWithDetails: (details) {
                      onAcceptWithDetails(details);
                    },
                  ),
                );
              });
            },
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                children.removeLast();
              });
            },
            icon: const Icon(Icons.remove),
          ),
        ],
      ),
      body: SplitView(children: children),
    );
  }
}
