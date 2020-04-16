library multi_date_range_picker;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quiver/iterables.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'day.dart';

class MultiDateRangePicker extends StatefulWidget {
  final List<List<DateTime>> initialValue;
  final Function(List<List<DateTime>> intervals) onChanged;
  final Color selectionColor;
  final Color buttonColor;
  final Color primaryTextColor;
  final Color dateTextColor;
  final Color ignoreTextColor;
  final Color selectedDateTextColor;
  final Color selectedIgnoreTextColor;
  final Color backgroundTextColor;
  final bool onlyOne;

  const MultiDateRangePicker({
    Key key,
    @required this.initialValue,
    @required this.onChanged,
    this.onlyOne = false,
    this.selectionColor = Colors.lightGreenAccent,
    this.buttonColor = Colors.lightGreenAccent,
    this.primaryTextColor = Colors.black,
    this.dateTextColor = Colors.black,
    this.ignoreTextColor = Colors.grey,
    this.selectedDateTextColor = Colors.black,
    this.selectedIgnoreTextColor = Colors.black,
    this.backgroundTextColor = Colors.white,
  }) : super(key: key);

  @override
  _MultiDateRangePickerState createState() => _MultiDateRangePickerState();
}

class _MultiDateRangePickerState extends State<MultiDateRangePicker> {
  DateTime masterDate = DateTime.now();

  Day start;
  List<List<Day>> intervals = [];

  bool deleteConfirm = false;
  Day deleteDay;
  List<Day> deleteInterval;

  @override
  void initState() {
    super.initState();

    for (final interval in widget.initialValue) {
      intervals.add([
        Day(
          date: interval[0],
          ignore: null,
          inInterval: null,
          isEnd: null,
          isStart: null,
        ),
        Day(
          date: interval[1],
          ignore: null,
          inInterval: null,
          isEnd: null,
          isStart: null,
        )
      ]);

      intervals = mergeInterval(intervals);
    }
  }

  List<Day> getDays() {
    final List<Day> days = [];

    DateTime start = DateTime(masterDate.year, masterDate.month);
    DateTime finish = DateTime(masterDate.year, masterDate.month + 1);

    print(dateTimeSymbolMap()[Intl.getCurrentLocale()].FIRSTDAYOFWEEK);

    start = start.add(Duration(days: -start.weekday));

    start = start.subtract(Duration(days: (7 - dateTimeSymbolMap()[Intl.getCurrentLocale()].FIRSTDAYOFWEEK) % 7));

    finish = finish.add(Duration(days: 6 - finish.weekday));

    finish = finish.subtract(Duration(days: (7 - dateTimeSymbolMap()[Intl.getCurrentLocale()].FIRSTDAYOFWEEK) % 7));

    for (var i = 0; i <= finish.difference(start).inDays; i++) {
      final date = start.add(Duration(days: i + 1));

      bool inInterval = false;
      bool isStart = false;
      bool isEnd = false;

      for (final interval in intervals) {
        if (interval[0].date == date) {
          isStart = true;
        }
        if (interval[1].date == date) {
          isEnd = true;
        }
        if (interval[0].date.millisecondsSinceEpoch <=
                date.millisecondsSinceEpoch &&
            date.millisecondsSinceEpoch <=
                interval[1].date.millisecondsSinceEpoch) {
          inInterval = true;
          break;
        }
      }

      days.add(
        Day(
          date: date,
          ignore: date.month == masterDate.month,
          inInterval: inInterval,
          isStart: isStart,
          isEnd: isEnd,
        ),
      );
    }

    return days;
  }

  List<List<Day>> mergeInterval(List<List<Day>> intervals) {
    final List<List<Day>> result = [];

    intervals.sort((a, b) => a[0]
        .date
        .millisecondsSinceEpoch
        .compareTo(b[0].date.millisecondsSinceEpoch));

    List<Day> currentRange;

    for (final range in intervals) {
      if (range[0].date.millisecondsSinceEpoch >=
          range[1].date.millisecondsSinceEpoch) continue;

      if (currentRange == null) {
        currentRange = range;
        continue;
      }

      if (currentRange[1].date.millisecondsSinceEpoch <
          range[0].date.millisecondsSinceEpoch) {
        result.add(currentRange);
        currentRange = range;
      } else if (currentRange[1].date.millisecondsSinceEpoch <
          range[1].date.millisecondsSinceEpoch) {
        currentRange[1] = range[1];
      }
    }

    if (currentRange != null) {
      result.add(currentRange);
    }

    return result;
  }

  void click(Day day) {
    if (deleteConfirm) {
      if (day.date == deleteDay.date) {
        setState(() {
          intervals.remove(deleteInterval);
          start = null;
          deleteConfirm = false;
        });

        widget.onChanged(intervals
            .map((interval) => [interval[0].date, interval[1].date])
            .toList());
        return;
      }
      setState(() {
        deleteConfirm = false;
      });
    }
    if (start == null) {
      bool inInterval = false;
      List<Day> interval;
      setState(() {
        start = day;

        if (widget.onlyOne) intervals = [];

        for (final intervald in intervals) {
          if (intervald[0].date.millisecondsSinceEpoch <=
                  day.date.millisecondsSinceEpoch &&
              day.date.millisecondsSinceEpoch <=
                  intervald[1].date.millisecondsSinceEpoch) {
            inInterval = true;
            interval = intervald;
            break;
          }
        }

        if (inInterval) {
          deleteConfirm = true;
          deleteDay = day;
          deleteInterval = interval;
        }
      });

      if (widget.onlyOne)
        widget.onChanged(intervals
            .map((interval) => [interval[0].date, interval[1].date])
            .toList());
    } else if (start.date == day.date) {
      setState(() {
        start = null;
      });
    } else {
      setState(() {
        if (start.date.millisecondsSinceEpoch <=
            day.date.millisecondsSinceEpoch) {
          intervals.add([start, day]);
        } else {
          intervals.add([day, start]);
        }
        start = null;

        intervals = mergeInterval(intervals);

        widget.onChanged(intervals
            .map((interval) => [interval[0].date, interval[1].date])
            .toList());
      });
    }
  }

  List<Widget> buildCalendar() {
    List<Widget> list = [];
    final days = getDays();

    final weeks = partition(days, 7);

    for (final week in weeks) {
      final List<Widget> weekL = [];

      for (Day day in week) {
        if (start != null &&
            day.date == start.date &&
            day.inInterval == false) {
          day = Day(
            date: day.date,
            ignore: day.ignore,
            inInterval: true,
            isStart: true,
            isEnd: true,
          );
        }

        weekL.add(Expanded(
          child: GestureDetector(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(day.isStart ? 25 : 0),
                topRight: Radius.circular(day.isEnd ? 25 : 0),
                bottomLeft: Radius.circular(day.isStart ? 25 : 0),
                bottomRight: Radius.circular(day.isEnd ? 25 : 0),
              ),
              child: Container(
                color: day.inInterval
                    ? widget.selectionColor
                    : Color.fromRGBO(0, 0, 0, 0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      day.date.day.toString(),
                      style: day.ignore
                          ? (day.inInterval
                              ? TextStyle(
                                  color: widget.selectedDateTextColor,
                                )
                              : TextStyle(
                                  color: widget.dateTextColor,
                                ))
                          : (day.inInterval
                              ? TextStyle(
                                  color: widget.selectedIgnoreTextColor,
                                )
                              : TextStyle(
                                  color: widget.ignoreTextColor,
                                )),
                    ),
                  ),
                ),
              ),
            ),
            onTap: () {
              click(day);
            },
          ),
        ));
      }

      list.add(Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekL,
        ),
      ));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    DateFormat formatter = new DateFormat("MMMM yyyy");

    return Card(
      child: Container(
        color: widget.backgroundTextColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  RaisedButton(
                    child: Icon(
                      Icons.navigate_before,
                      color: widget.primaryTextColor,
                    ),
                    onPressed: () {
                      setState(() {
                        masterDate = masterDate.add(Duration(days: -31));
                      });
                    },
                    color: widget.buttonColor,
                  ),
                  Text(
                    formatter.format(masterDate),
                    style: TextStyle(
                      color: widget.primaryTextColor,
                    ),
                  ),
                  RaisedButton(
                    child: Icon(
                      Icons.navigate_next,
                      color: widget.primaryTextColor,
                    ),
                    onPressed: () {
                      setState(() {
                        masterDate = masterDate.add(Duration(days: 31));
                      });
                    },
                    color: widget.buttonColor,
                  ),
                ],
              ),
              SizedBox(
                height: 16,
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        DateFormat("EEE").format(DateTime(1, 1, dateTimeSymbolMap()[Intl.getCurrentLocale()].FIRSTDAYOFWEEK + 1)).toUpperCase().replaceAll(".", ""),
                        style: TextStyle(
                          color: widget.primaryTextColor,
                        ),
                      ),
                      Text(
                        DateFormat("EEE").format(DateTime(1, 1, dateTimeSymbolMap()[Intl.getCurrentLocale()].FIRSTDAYOFWEEK + 2)).toUpperCase().replaceAll(".", ""),
                        style: TextStyle(
                          color: widget.primaryTextColor,
                        ),
                      ),
                      Text(
                        DateFormat("EEE").format(DateTime(1, 1, dateTimeSymbolMap()[Intl.getCurrentLocale()].FIRSTDAYOFWEEK + 3)).toUpperCase().replaceAll(".", ""),
                        style: TextStyle(
                          color: widget.primaryTextColor,
                        ),
                      ),
                      Text(
                        DateFormat("EEE").format(DateTime(1, 1, dateTimeSymbolMap()[Intl.getCurrentLocale()].FIRSTDAYOFWEEK + 4)).toUpperCase().replaceAll(".", ""),
                        style: TextStyle(
                          color: widget.primaryTextColor,
                        ),
                      ),
                      Text(
                        DateFormat("EEE").format(DateTime(1, 1, dateTimeSymbolMap()[Intl.getCurrentLocale()].FIRSTDAYOFWEEK + 5)).toUpperCase().replaceAll(".", ""),
                        style: TextStyle(
                          color: widget.primaryTextColor,
                        ),
                      ),
                      Text(
                        DateFormat("EEE").format(DateTime(1, 1, dateTimeSymbolMap()[Intl.getCurrentLocale()].FIRSTDAYOFWEEK + 6)).toUpperCase().replaceAll(".", ""),
                        style: TextStyle(
                          color: widget.primaryTextColor,
                        ),
                      ),
                      Text(
                        DateFormat("EEE").format(DateTime(1, 1, dateTimeSymbolMap()[Intl.getCurrentLocale()].FIRSTDAYOFWEEK + 7)).toUpperCase().replaceAll(".", ""),
                        style: TextStyle(
                          color: widget.primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Column(
                    children: buildCalendar(),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
