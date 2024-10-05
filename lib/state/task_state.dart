import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'sql_provider.dart';
import '/repository/sql.dart';

part 'task_state.g.dart';

extension ListTaskX on List<Task> {
  List<Task> sortByFolderPriority() {
    sort((a, b) => a.folder.priority.compareTo(b.folder.priority));
    return this;
  }
}

@riverpod
class TaskState extends _$TaskState {
  @override
  FutureOr<List<Task>> build() async {
    return ref.watch(sqlRepositoryProvider).getTasks();
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
