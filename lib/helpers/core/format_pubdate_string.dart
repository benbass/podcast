import 'dart:io';

import 'package:intl/intl.dart';

String extractDataFromDateString(String dateString) {
// Convert string to DateTime
  DateTime dateTime =
      DateFormat("MMMM dd, yyyy hh:mm").parse(dateString);

// Convert DateTime to String in wished format
  return DateFormat("dd MMMM yyyy").format(dateTime);
}

String formatTimestamp(int timestamp) {
  final String locale = Platform.localeName;
  final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  final String formattedDate = DateFormat('E dd MMM yyyy', locale).format(dateTime);
  return formattedDate;
}
