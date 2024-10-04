import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'sql_provider.dart';
import 'task_state.dart';
import '../repository/sql.dart';

part 'project_state.g.dart';

class Project {
  const Project({
    required this.folder,
    required this.tasks,
  });

  final Folder folder;
  final List<Task> tasks;

  Project copyWith({
    Folder? folder,
    List<Task>? tasks,
  }) {
    return Project(
      folder: folder ?? this.folder,
      tasks: tasks ?? this.tasks,
    );
  }

  factory Project.fromFoloderWithTasks(Folder folder, List<Task> task) {
    return Project(
      folder: Folder(
        id: folder.id,
        name: folder.name,
        color: folder.color,
        priority: folder.priority,
      ),
      tasks: task.where((e) => e.folder.id == folder.id).toList(),
    );
  }
}

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
}
