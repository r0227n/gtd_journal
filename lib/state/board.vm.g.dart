// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'board.vm.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$idsHash() => r'7c225a41de31fd278d47efc3fb96ae929eacb0a6';

/// See also [Ids].
@ProviderFor(Ids)
final idsProvider = AutoDisposeNotifierProvider<Ids, List<int>>.internal(
  Ids.new,
  name: r'idsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$idsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Ids = AutoDisposeNotifier<List<int>>;
String _$boardViewModelHash() => r'4ba98748b8f63b278b9e22d8cfbb05b5ccee2186';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$BoardViewModel
    extends BuildlessAutoDisposeNotifier<List<BoardItem>> {
  late final Board board;

  List<BoardItem> build(
    Board board,
  );
}

/// See also [BoardViewModel].
@ProviderFor(BoardViewModel)
const boardViewModelProvider = BoardViewModelFamily();

/// See also [BoardViewModel].
class BoardViewModelFamily extends Family<List<BoardItem>> {
  /// See also [BoardViewModel].
  const BoardViewModelFamily();

  /// See also [BoardViewModel].
  BoardViewModelProvider call(
    Board board,
  ) {
    return BoardViewModelProvider(
      board,
    );
  }

  @override
  BoardViewModelProvider getProviderOverride(
    covariant BoardViewModelProvider provider,
  ) {
    return call(
      provider.board,
    );
  }

  static final Iterable<ProviderOrFamily> _dependencies = <ProviderOrFamily>[
    idsProvider,
    projectStateProvider
  ];

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static final Iterable<ProviderOrFamily> _allTransitiveDependencies =
      <ProviderOrFamily>{
    idsProvider,
    ...?idsProvider.allTransitiveDependencies,
    projectStateProvider,
    ...?projectStateProvider.allTransitiveDependencies
  };

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'boardViewModelProvider';
}

/// See also [BoardViewModel].
class BoardViewModelProvider
    extends AutoDisposeNotifierProviderImpl<BoardViewModel, List<BoardItem>> {
  /// See also [BoardViewModel].
  BoardViewModelProvider(
    Board board,
  ) : this._internal(
          () => BoardViewModel()..board = board,
          from: boardViewModelProvider,
          name: r'boardViewModelProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$boardViewModelHash,
          dependencies: BoardViewModelFamily._dependencies,
          allTransitiveDependencies:
              BoardViewModelFamily._allTransitiveDependencies,
          board: board,
        );

  BoardViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.board,
  }) : super.internal();

  final Board board;

  @override
  List<BoardItem> runNotifierBuild(
    covariant BoardViewModel notifier,
  ) {
    return notifier.build(
      board,
    );
  }

  @override
  Override overrideWith(BoardViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: BoardViewModelProvider._internal(
        () => create()..board = board,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        board: board,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<BoardViewModel, List<BoardItem>>
      createElement() {
    return _BoardViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BoardViewModelProvider && other.board == board;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, board.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin BoardViewModelRef on AutoDisposeNotifierProviderRef<List<BoardItem>> {
  /// The parameter `board` of this provider.
  Board get board;
}

class _BoardViewModelProviderElement
    extends AutoDisposeNotifierProviderElement<BoardViewModel, List<BoardItem>>
    with BoardViewModelRef {
  _BoardViewModelProviderElement(super.provider);

  @override
  Board get board => (origin as BoardViewModelProvider).board;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
