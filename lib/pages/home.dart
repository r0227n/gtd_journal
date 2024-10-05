import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/widgets.dart';
import '../l10n/l10n.dart';
import '../themes/theme.dart';
import '../state/board.vm.dart';
import '../state/project_state.dart';
import '../state/task_state.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectState = ref.watch(projectStateProvider);
    final projectMethod = ref.read(projectStateProvider.notifier);
    final projectBoard = ref.watch(boardViewModelProvider(Board.project)).cast<Project>();

    return Scaffold(
      appBar: AppBar(),
      body: projectState.when(
        data: (projects) {
          return NavigationRailBuilder(destinations: [
            RailWidgetBuilder(
              icon: const Icon(Icons.home),
              label: const Text('home'),
              panel: ListView.builder(
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final folderTrailing = projectBoard.contains(projects[index])
                      ? IconButton(
                          onPressed: () {
                            final project =
                                projectMethod.getProjectByFolderId(projects[index].folder.id);

                            ref
                                .read(boardViewModelProvider(Board.project).notifier)
                                .remove(project);
                          },
                          icon: const Icon(Icons.close_fullscreen),
                        )
                      : IconButton(
                          onPressed: () {
                            final project =
                                projectMethod.getProjectByFolderId(projects[index].folder.id);

                            ref.read(boardViewModelProvider(Board.project).notifier).add(project);
                          },
                          icon: const Icon(Icons.open_in_full),
                        );

                  return FolderListTile(
                    title: Text(projects[index].folder.name),
                    trailing: folderTrailing,
                    children: projects[index]
                        .tasks
                        .map(
                          (e) => ListTile(
                            title: Text(e.title),
                            subtitle: Text(e.description),
                            onTap: () {
                              showModalSideSheet(
                                  context: context,
                                  builder: (context) {
                                    return Center(
                                      child: Text(e.description),
                                    );
                                  });
                            },
                          ),
                        )
                        .toList(),
                  );
                },
              ),
              children: projectBoard
                  .map((e) => Builder(builder: (context) => ProjectListView(e)))
                  .toList(),
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
      actions: [
        IconButton(
          onPressed: () {
            ref.read(boardViewModelProvider(Board.project).notifier).remove(project);
          },
          icon: const Icon(Icons.close),
        )
      ],
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
          ref.read(projectStateProvider.notifier).moveFolder(
                fromListId: details.fromListId!,
                toListId: details.toListId!,
                taskId: details.itemId,
              );
        }
      },
    );
  }
}
