import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'board_item.dart';
import 'sql_provider.dart';
import 'task_state.dart';
import '../repository/sql.dart';

export 'board_item.dart';

part 'project_state.g.dart';

@riverpod
class ProjectState extends _$ProjectState {
  @override
  FutureOr<List<Project>> build() async {
    final (List<Folder> folders, List<Task> tasks) = await (
      ref.watch(sqlRepositoryProvider).getFolders(),
      ref.watch(taskStateProvider.future)
    ).wait;

    return folders.map((e) => Project.fromFoloderWithTasks(e, tasks)).toList();
  }

  Future<List<Project>> moveFolder({
    required int fromListId,
    required int toListId,
    required int taskId,
  }) async {
    return update((projects) {
      state = const AsyncLoading();
      final fromTask = projects
          .firstWhere((e) => e.folder.id == fromListId)
          .tasks
          .firstWhere((e) => e.id == taskId);

      return [
        for (final project in projects)
          if (project.folder.id == fromListId)
            project.copyWith(
              tasks: project.tasks.where((e) => e.id != taskId).toList(),
            )
          else if (project.folder.id == toListId)
            project.copyWith(
              tasks: [...project.tasks, fromTask],
            )
          else
            project,
      ];
    });
  }

  Folder? getFolderByTaskId(int id) {
    return switch (state) {
      AsyncValue(:final value?) => value.firstWhere((e) => e.tasks.any((e) => e.id == id)).folder,
      _ => null,
    };
  }

  Project getProjectByFolderId(int id) {
    return switch (state) {
      AsyncValue(:final value?) => value.firstWhere((e) => e.folder.id == id),
      _ => throw Exception('Project not found'),
    };
  }
}
