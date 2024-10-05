import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/state/project_state.dart';
import '/widgets/widgets.dart';
import '/l10n/l10n.dart';
import '/themes/theme.dart';

import '../state/task_state.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectState = ref.watch(projectStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Split View Demo'),
      ),
      body: projectState.when(
        data: (projects) {
          return NavigationRailBuilder(destinations: [
            RailWidgetBuilder(
              icon: const Icon(Icons.home),
              label: const Text('home'),
              panel: ListView.builder(
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  return ExpansionTile(
                    title: Text(projects[index].folder.name),
                    children: projects[index]
                        .tasks
                        .map(
                          (e) => ListTile(
                            title: Text(e.title),
                            subtitle: Text(e.description),
                            onTap: () {
                              final folder =
                                  ref.read(projectStateProvider.notifier).getFolderByTaskId(e.id);

                              final project = ref
                                  .read(projectStateProvider.notifier)
                                  .getProjectByFolderId(folder?.id ?? -1);
                            },
                          ),
                        )
                        .toList(),
                  );
                },
              ),
              children: projects.map((e) => ProjectListView(e)).toList(),
            ),
            const RailWidgetBuilder(
              icon: Icon(Icons.settings),
              label: Text('settings'),
              panel: Text('settings'),
              children: [Text('settings')],
            ),
          ]);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Error: $error')), // TODO: create error widget
      ),
    );
  }
}

class ProjectListView extends ConsumerWidget {
  const ProjectListView(this.project, {super.key});

  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DragListView(
      id: project.folder.id,
      title: Text(project.folder.name),
      children: project.tasks
          .map(
            (e) => DragListItem(
              itemId: e.id,
              leading: Checkbox(
                  value: e.isCompleted,
                  onChanged: (_) => ref
                      .read(taskStateProvider.notifier)
                      .updateState(id: e.id, completedAt: DateTime.now())),
              title: Text(
                e.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      initialDate: DateTime.now(),
                    );
                    if (selectedDate == null) {
                      return;
                    }

                    await ref
                        .read(taskStateProvider.notifier)
                        .updateState(id: e.id, dueAt: selectedDate);
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
                          label: Text(e.name, style: const TextStyle(color: Colors.white)),
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
    );
  }
}
