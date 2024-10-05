import 'package:gtd_journal/repository/sql.dart';

sealed class BoardItem {}

class Project extends BoardItem {
  Project({
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

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'folder': folder.toJson(),
      'tasks': tasks.map((e) => e.toJson()).toList(),
    };
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
