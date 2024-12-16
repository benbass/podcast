// We transform the seconds to hh:mm:ss or mm:ss
String formatIntDuration(int seconds) {
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
String durationToSeconds(String durationString) {
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
String formatDurationDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  if (duration.inHours == 0) {
    return "$twoDigitMinutes:$twoDigitSeconds";
  } else {
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}

String formatRemainingDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  String sign = duration.isNegative ? "-" : "";
  if (duration.inHours == 0) {
    return "$sign$twoDigitMinutes:$twoDigitSeconds";
  } else {
    return "$sign${twoDigits(
        duration.inHours.abs())}:$twoDigitMinutes:$twoDigitSeconds";
  }
}

Duration parseDuration(String s) {
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
