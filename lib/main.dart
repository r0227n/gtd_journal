import 'package:flutter/material.dart';
import 'l10n/l10n.dart';
import 'themes/theme.dart';
import 'widgets/widgets.dart';
import 'repository/sql.dart';

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
  List<DragListView> children = [];

  final MockSqlRepository mockSqlRepository = MockSqlRepository();
  late final Future<List<Task>> futureTasks;

  @override
  void initState() {
    super.initState();
    children.add(
      DragListView(
        id: 1,
        title: const Text('List 1'),
        children: [
          for (final value in [1, 2, 3])
            DragListItem(
              itemId: value,
              title: Container(
                color: Colors.red[100],
                child: const Center(child: Text('View A')),
              ),
              leading: Checkbox(value: true, onChanged: (value) {}),
              trailing: const Icon(Icons.abc),
              onTap: () {
                showModalSideSheet(
                  context: context,
                  builder: (context) => const Center(child: Text('hoge')),
                );
              },
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

    futureTasks = mockSqlRepository.getTasks();
  }

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
                      for (final value in [4, 5, 6])
                        DragListItem(
                          itemId: value,
                          title: Container(
                            color: Colors.blue[100],
                            child: const Center(child: Text('View B')),
                          ),
                          onTap: () {
                            showModalSideSheet(
                              context: context,
                              builder: (context) => const Center(child: Text('hoge')),
                            );
                          },
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
      body: FutureBuilder(
          future: futureTasks,
          builder: (context, snapshot) {
            return switch ((snapshot.connectionState, snapshot.data)) {
              (ConnectionState.waiting, null) => const Center(child: CircularProgressIndicator()),
              (ConnectionState.done, null) => const Center(child: Text('No data')),
              (ConnectionState.done, List<Task> tasks) => SplitView(
                  children: [
                    DragListView(
                        children: tasks
                            .map((e) => DragListItem(
                                  itemId: e.id,
                                  leading: Checkbox(value: e.isCompleted, onChanged: (value) {}),
                                  title: Text(
                                    e.title,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  subtitle: Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton(
                                      onPressed: () async {
                                        showDatePicker(
                                          context: context,
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime.now().add(const Duration(days: 365)),
                                          initialDate: DateTime.now(),
                                        );
                                        // TODO: update dueAt
                                      },
                                      child: Text(
                                        e.dueAt?.toYmd() ??
                                            context.l10n.noSet(context.l10n.dueDate),
                                      ),
                                    ),
                                  ),
                                  trailing: Wrap(
                                    spacing: 8.0,
                                    children: e.tags
                                        .map((e) => Chip(
                                              label: Text(e.name,
                                                  style: const TextStyle(color: Colors.white)),
                                              backgroundColor: e.color,
                                            ))
                                        .toList(),
                                  ),
                                  onTap: () {
                                    showModalSideSheet(
                                      context: context,
                                      builder: (context) => Center(
                                        child: Text(e.description),
                                      ),
                                    );
                                  },
                                ))
                            .toList(),
                        onAcceptWithDetails: onAcceptWithDetails)
                  ],
                ),
              (ConnectionState.done, Error error) => Center(child: Text('Error: $error')),
              _ => const Center(child: Text('Error')),
            };
          }),
    );
  }
}
