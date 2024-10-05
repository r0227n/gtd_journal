import 'dart:convert';

import 'package:flutter/services.dart';

import 'sql/models/folder.dart';
import 'sql/models/task.dart';

class MockSqlRepository {
  Future<List<Folder>> getFolders() async {
    final List json = await rootBundle
        .loadString('assets/mocks/folder.mock.json')
        .then((value) => jsonDecode(value));

    return json.map((e) => Folder.fromJson(Map.from(e))).toList();
  }

  Future<List<Task>> getTasks() async {
    final List json = await rootBundle
        .loadString('assets/mocks/task.mock.json')
        .then((value) => jsonDecode(value));

    return json.map((e) => Task.fromJson(Map.from(e))).toList();
  }
}
