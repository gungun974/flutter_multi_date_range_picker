import 'package:meta/meta.dart';

class Day {
  final DateTime date;
  final bool ignore;
  final bool inInterval;
  final bool isStart;
  final bool isEnd;

  Day({
    @required this.date,
    @required this.ignore,
    @required this.inInterval,
    @required this.isStart,
    @required this.isEnd,
  });
}
