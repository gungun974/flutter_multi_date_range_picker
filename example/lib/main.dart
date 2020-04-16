import 'dart:io';

import 'package:flutter/material.dart';
import 'package:multi_date_range_picker/multi_date_range_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {

  Intl.defaultLocale = Intl.verifiedLocale(Platform.localeName, NumberFormat.localeExists,
      onFailure: (_) => 'en_US');
  initializeDateFormatting();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyAppPage(),
    );
  }
}

class MyAppPage extends StatefulWidget {
  const MyAppPage({Key key}) : super(key: key);

  @override
  _MyAppPageState createState() => _MyAppPageState();
}

class _MyAppPageState extends State<MyAppPage> {
  List<List<DateTime>> intervals = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi Date Range Picker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            MultiDateRangePicker(
              initialValue: intervals,
              onChanged: (List<List<DateTime>> intervals) {
                setState(() {
                  this.intervals = intervals;
                });
              },
              selectionColor: Colors.lightBlueAccent,
              buttonColor: Colors.lightBlueAccent,
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 16.0),
                      child: Column(
                        children: buildColumn(),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  List<Widget> buildColumn() {
    final List<Widget> list = [];

    for (final interval in intervals) {
      list.add(Text(interval[0].toString() + " - " + interval[1].toString()));
      if (interval != intervals.last)
        list.add(SizedBox(
          height: 8,
        ));
    }

    return list;
  }
}
