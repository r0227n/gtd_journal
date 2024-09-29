import 'tag.dart';

class Task {
  Task({
    required this.id,
    this.parentId,
    required this.title,
    required this.description,
    required this.tags,
    required this.folder,
    required this.createdAt,
    required this.updatedAt,
    this.dueAt,
    this.completedAt,
    this.priority = 0,
  });

  /// The unique identifier for the task
  final int id;

  /// The unique identifier for the parent task
  final int? parentId;

  /// The title of the task
  final String title;

  /// The description of the task
  final String description;

  /// The tags of the task
  final List<Tag> tags;

  /// The folder of the task
  final String folder;

  /// The date and time the task was created
  final DateTime createdAt;

  /// The date and time the task was last updated
  final DateTime updatedAt;

  /// The date and time the task is due
  final DateTime? dueAt;

  /// The date and time the task was completed
  final DateTime? completedAt;

  /// The priority of the task
  final int priority;

  Task copyWith({
    int? id,
    int? parentId,
    String? title,
    String? description,
    List<Tag>? tags,
    String? folder,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueAt,
    DateTime? completedAt,
    int? priority,
  }) {
    return Task(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      folder: folder ?? this.folder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueAt: dueAt ?? this.dueAt,
      completedAt: completedAt ?? this.completedAt,
      priority: priority ?? this.priority,
    );
  }

  bool get isCompleted => completedAt != null;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'parentId': parentId,
      'title': title,
      'description': description,
      'tags': tags.map((e) => e.toJson()).toList(),
      'folder': folder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'due_at': dueAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int,
      parentId: map['parentId'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      tags: (map['tags'] as List).map((e) => Tag.fromJson(Map<String, dynamic>.from(e))).toList(),
      folder: map['folder'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      dueAt: map['due_at'] == null ? null : DateTime.parse(map['due_at'] as String),
      completedAt:
          map['completed_at'] == null ? null : DateTime.parse(map['completed_at'] as String),
      priority: map['priority'] as int? ?? 0,
    );
  }
}
