import 'package:flutter/material.dart';

class Tag {
  const Tag({
    required this.id,
    required this.name,
    required this.color,
  });

  /// The unique identifier for the tag
  final int id;

  /// The name of the tag
  final String name;

  /// The color of the tag
  final Color color;

  Tag copyWith({
    int? id,
    String? name,
    Color? color,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() {
    color.value;
    return {
      'id': id,
      'name': name,
      'color': color.value,
    };
  }

  factory Tag.fromJson(Map<String, dynamic> map) {
    return Tag(
      id: map['id'] as int,
      name: map['name'] as String,
      color: Color(map['color'] as int),
    );
  }
}
