# Multi Date Range Picker

A simple and customize Date range picker with multi range

## Features

* Create Multi Range picker
* Support multi language (with intl localization)

## Getting Started

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  ...
  multi_date_range_picker: "^0.0.4"
```

In your library add the following import:

```dart
import 'package:flutter_slidable/flutter_slidable.dart';
```

and use `MultiDateRangePicker` Widget to show

```dart
MultiDateRangePicker(
  initialValue: [],
  onChanged: (List<List<DateTime>> intervals) {
    
  },
);
`````

## Customization

You can change colors of selection and background and more.


```dart
onlyOne = false // Allow only one selection
selectionColor = Colors.lightGreenAccent // Sets the color of the selection
buttonColor = Colors.lightGreenAccent // Sets the color of the buttons
primaryTextColor = Colors.black // Sets the color of UI text
dateTextColor = Colors.black // Sets the color of calendar date
ignoreTextColor = Colors.grey // Sets the color of external calendar date
selectedDateTextColor = Colors.black // Sets the color of calendar date when is selected
selectedIgnoreTextColor = Colors.black // Sets the color of external calendar date when is selected
backgroundTextColor = Colors.white // Sets the background color
```

### Note
For the customization of the local you will need at the start of your application to define the default local in intl
```dart
Intl.defaultLocale = 'fr';
initializeDateFormatting();
```