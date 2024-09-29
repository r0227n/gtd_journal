import 'package:intl/intl.dart';

extension DateTimeX on DateTime {
  String toYmd() {
    return DateFormat('yyyy/MM/dd').format(this);
  }
}
