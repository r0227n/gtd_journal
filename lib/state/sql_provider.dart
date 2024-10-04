import 'package:riverpod_annotation/riverpod_annotation.dart';

import '/repository/sql.dart';

part 'sql_provider.g.dart';

@riverpod
MockSqlRepository sqlRepository(SqlRepositoryRef ref) {
  return MockSqlRepository();
}
