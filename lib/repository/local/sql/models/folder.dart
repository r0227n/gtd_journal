import 'dart:ui';

class Folder {
  const Folder({
    required this.id,
    this.parentId,
    required this.name,
    required this.color,
    required this.priority,
  });

  final int id;
  final int? parentId;
  final String name;
  final Color color;
  final int priority;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Folder &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          parentId == other.parentId &&
          name == other.name &&
          color == other.color &&
          priority == other.priority;

  @override
  int get hashCode =>
      id.hashCode ^ parentId.hashCode ^ name.hashCode ^ color.hashCode ^ priority.hashCode;

  Folder copyWith({
    int? id,
    int? parentId,
    String? name,
    Color? color,
    int? priority,
  }) {
    return Folder(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      color: color ?? this.color,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parent_id': parentId,
      'name': name,
      'color': color.value,
      'priority': priority,
    };
  }

  factory Folder.fromJson(Map<String, dynamic> map) {
    return Folder(
      id: map['id'] as int,
      parentId: map['parent_id'] as int?,
      name: map['name'] as String,
      color: Color(map['color'] as int),
      priority: map['priority'] as int,
    );
  }
}
