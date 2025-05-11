import 'dart:io';

import 'package:intl/intl.dart';

class FormatUtilities {
  static String extractDataFromDateString(String dateString) {
// Convert string to DateTime
    DateTime dateTime = DateFormat("MMMM dd, yyyy hh:mm").parse(dateString);

// Convert DateTime to String in wished format
    return DateFormat("dd MMMM yyyy").format(dateTime);
  }

  static String formatTimestamp(int timestamp) {
    final String locale = Platform.localeName;
    final DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final String formattedDate =
        DateFormat('E dd MMM yyyy', locale).format(dateTime);
    return formattedDate;
  }

// We transform the seconds to hh:mm:ss or mm:ss
  static String intToDurationFormatted(int seconds) {
    final duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours == 0) {
      return "$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
  }

// We may get the duration from rss feed as hh:mm:ss or mm:ss but we need it as seconds as String
  static String durationToSeconds(String durationString) {
    List<String> parts = durationString.split(':');
    int hours = 0;
    int minutes = 0;
    int seconds = 0;
    if (parts.length == 3) {
      hours = int.parse(parts[0]);
      minutes = int.parse(parts[1]);
      seconds = int.parse(parts[2]);
    } else if (parts.length == 2) {
      minutes = int.parse(parts[0]);
      seconds = int.parse(parts[1]);
    } else {
      // Just in case...
      seconds = int.parse(parts[0]);
    }

    return (hours * 3600 + minutes * 60 + seconds).toString();
  }

// Just remove the milliseconds from duration for string in text widget
  static String durationWithMillisecondsRemovedFormatted(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours == 0) {
      return "$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
  }

  static String remainingDurationFormatted(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String sign = duration.isNegative ? "-" : "";
    if (duration.inHours == 0) {
      return "$sign$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "$sign${twoDigits(duration.inHours.abs())}:$twoDigitMinutes:$twoDigitSeconds";
    }
  }

  static Duration parseDuration(String s) {
    int hours = 0;
    int minutes = 0;
    int seconds = 0;
    List<String> parts = s.split(':');
    if (parts.length > 2) {
      hours = int.parse(parts[0]);
      minutes = int.parse(parts[1]);
      seconds = int.parse(parts[2]);
    } else if (parts.length > 1) {
      minutes = int.parse(parts[0]);
      seconds = int.parse(parts[1]);
    } else if (parts.isNotEmpty) {
      seconds = int.parse(parts[0]);
    }
    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }

// converts duration to milliseconds
  static int durationToInt(Duration duration) {
    String formattedDuration = duration.toString();
    List<String> parts = formattedDuration.split(':');
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    int seconds = double.parse(parts[2]).toInt();

    DateTime zeroTime = DateTime.utc(1970, 1, 1);
    DateTime formattedTime = zeroTime
        .add(Duration(hours: hours, minutes: minutes, seconds: seconds));
    int milliseconds = (formattedTime.millisecondsSinceEpoch / 1000).round();

    return milliseconds;
  }
}
