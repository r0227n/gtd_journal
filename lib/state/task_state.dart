import 'package:riverpod_annotation/riverpod_annotation.dart';

import '/repository/sql.dart';

part 'task_state.g.dart';

extension ListTaskX on List<Task> {
  List<Task> sortByFolderPriority() {
    sort((a, b) => a.folder.priority.compareTo(b.folder.priority));
    return this;
  }
}

class FolderState {
  const FolderState({
    required this.folder,
    required this.tasks,
  });

  final Folder folder;
  final List<Task> tasks;

  FolderState copyWith({
    Folder? folder,
    List<Task>? tasks,
  }) {
    return FolderState(
      folder: folder ?? this.folder,
      tasks: tasks ?? this.tasks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'folder': folder.toJson(),
      'tasks': tasks.map((e) => e.toJson()).toList(),
    };
  }

  factory FolderState.fromJson(Map<String, dynamic> map) {
    return FolderState(
      folder: Folder.fromJson(map['folder'] as Map<String, dynamic>),
      tasks: (map['tasks'] as List).map((e) => Task.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  factory FolderState.fromFoloderWithTasks(Folder folder, List<Task> task) {
    return FolderState(
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
class TaskState extends _$TaskState {
  @override
  FutureOr<List<Task>> build() async {
    mockSqlRepository = MockSqlRepository();

    return mockSqlRepository.getTasks();
  }

  late final MockSqlRepository mockSqlRepository;

  List<FolderState> getFolders(
    List<Task> tasks, {
    bool ignoreCompleted = false,
  }) {
    if (ignoreCompleted) {
      tasks = tasks.where((e) => e.completedAt != null).toList();
    }

    final folders = tasks.map((e) => e.folder).toSet();

    final states = folders.map((e) => FolderState.fromFoloderWithTasks(e, tasks)).toList();

    states.sort((a, b) => a.folder.priority.compareTo(b.folder.priority));
    return states;
  }

  Future<List<Task>> moveFolder({
    required int fromListId,
    required int toListId,
    required int taskId,
  }) async {
    return update((tasks) {
      state = const AsyncLoading();

      final updateFolder =
          tasks.firstWhere((e) => e.folder.id == toListId).folder.copyWith(id: toListId);

      final update = tasks.map((e) {
        if (e.id == taskId) {
          return tasks.firstWhere((e) => e.id == taskId).copyWith(folder: updateFolder);
        }

        return e;
      }).toList();

      return update.sortByFolderPriority();
    });
  }

  Future<void> updateState({
    required int id,
    int? parentId,
    String? title,
    String? description,
    List<Tag>? tags,
    Folder? folder,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueAt,
    DateTime? completedAt,
    int? priority,
  }) async {
    final List<Future> queries = [];

    /// TODO: propertyのnull毎に更新処理を追加

    await Future.wait([
      update((tasks) {
        state = const AsyncLoading();

        final task = tasks.firstWhere((e) => e.id == id);

        final update = tasks.map((e) {
          if (e.id == id) {
            return task.copyWith(
              id: id,
              parentId: parentId ?? task.parentId,
              title: title ?? task.title,
              description: description ?? task.description,
              tags: tags ?? task.tags,
              folder: folder ?? task.folder,
              createdAt: createdAt ?? task.createdAt,
              updatedAt: updatedAt ?? task.updatedAt,
              dueAt: dueAt ?? task.dueAt,
              completedAt: completedAt ?? task.completedAt,
              priority: priority ?? task.priority,
            );
          }

          return e;
        }).toList();

        return update.sortByFolderPriority();
      }),
      ...queries,
    ]);
  }
}
