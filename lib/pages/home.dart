import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/l10n/l10n.dart';
import '/themes/theme.dart';
import '/state/task_state.dart';
import '/widgets/widgets.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Split View Demo'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.remove),
          ),
        ],
      ),
      body: taskState.when(
        data: (folders) {
          return SplitView(
            children: [
              for (final folder in ref.read(taskStateProvider.notifier).getFolders(folders))
                DragListView(
                  id: folder.folder.id,
                  title: Text(folder.folder.name),
                  children: folder.tasks
                      .map(
                        (e) => DragListItem(
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
                                e.dueAt?.toYmd() ?? context.l10n.noSet(context.l10n.dueDate),
                              ),
                            ),
                          ),
                          trailing: Wrap(
                            spacing: 8.0,
                            children: e.tags
                                .map((e) => Chip(
                                      label:
                                          Text(e.name, style: const TextStyle(color: Colors.white)),
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
                        ),
                      )
                      .toList(),
                  onAcceptWithDetails: (details) async {
                    if (details.fromListId != null && details.toListId != null) {
                      await ref.read(taskStateProvider.notifier).moveFolder(
                            fromListId: details.fromListId!,
                            toListId: details.toListId!,
                            taskId: details.itemId,
                          );
                    }
                  },
                )
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Error: $error')), // TODO: create error widget
      ),
    );
  }
}
