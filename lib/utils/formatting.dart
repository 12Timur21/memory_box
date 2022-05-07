enum TimeFormattingType {
  minuteSecond,
  hourMinute,
  hourMinuteSecond,
}

enum DayTimeFormattingType {
  dayMonthYear,
  dayMonth,
  day,
}

String convertDurationToString({
  Duration? duration,
  TimeFormattingType? formattingType,
}) {
  if (duration != null) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitsHours = twoDigits(duration.inHours.remainder(24));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    if (formattingType == TimeFormattingType.minuteSecond) {
      return "$twoDigitMinutes:$twoDigitSeconds";
    }
    if (formattingType == TimeFormattingType.hourMinute) {
      return "$twoDigitsHours:$twoDigitMinutes";
    }
    return "$twoDigitsHours:$twoDigitMinutes:$twoDigitSeconds";
  }
  return '00:00:00';
}

String convertDateTimeToString({
  required DateTime date,
  DayTimeFormattingType? dayTimeFormattingType,
}) {
  String twoDigitDay = date.day.toString().padLeft(2, '0');
  String twoDigitMonth = date.month.toString().padLeft(2, '0');
  String twoDigitYear = date.year.toString().padLeft(2, '0').substring(2);

  if (dayTimeFormattingType == DayTimeFormattingType.dayMonthYear) {
    return "$twoDigitDay.$twoDigitMonth.$twoDigitYear";
  }
  if (dayTimeFormattingType == DayTimeFormattingType.dayMonth) {
    return "$twoDigitDay.$twoDigitMonth";
  }
  if (dayTimeFormattingType == DayTimeFormattingType.day) {
    return twoDigitDay;
  }
  return '';
}
