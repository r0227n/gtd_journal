import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'project_state.dart';

part 'board.vm.g.dart';

enum Board { project }

@riverpod
class Ids extends _$Ids {
  @override
  List<int> build() {
    return const [];
  }

  void add(int id) {
    state = [...state, id];
  }

  void remove(int id) {
    state = state.where((e) => e != id).toList();
  }
}

@Riverpod(dependencies: [Ids, ProjectState])
class BoardViewModel extends _$BoardViewModel {
  @override
  List<BoardItem> build(Board board) {
    final ids = ref.watch(idsProvider);
    final list = switch (board) {
      Board.project => ref
          .watch(projectStateProvider)
          .whenData((projects) => projects.where((e) => ids.contains(e.folder.id)).toList())
    };
    print('init: $list');

    return switch (list) {
      AsyncValue(:final List<Project> value) => value,
      _ => [],
    };
  }

  void add(BoardItem item) {
    if (state.contains(item)) {
      return;
    }

    state = [...state, item];
    ref.read(idsProvider.notifier).add((item as Project).folder.id);
  }

  void remove(BoardItem item) {
    state = state.where((e) => e != item).toList();
    ref.read(idsProvider.notifier).remove((item as Project).folder.id);
  }
}
