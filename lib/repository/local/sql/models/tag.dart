import 'package:flutter/material.dart';

class Tag {
  const Tag({
    required this.id,
    required this.name,
    required this.color,
    this.priority = 0,
  });

  /// The unique identifier for the tag
  final int id;

  /// The name of the tag
  final String name;

  /// The color of the tag
  final Color color;

  /// The priority of the tag
  final int priority;

  Tag copyWith({
    int? id,
    String? name,
    Color? color,
    int? priority,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
      'priority': priority,
    };
  }

  factory Tag.fromJson(Map<String, dynamic> map) {
    return Tag(
      id: map['id'] as int,
      name: map['name'] as String,
      color: Color(map['color'] as int),
      priority: map['priority'] as int,
    );
  }
}
