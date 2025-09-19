import 'package:intl/intl.dart';

class AppDateUtils {
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  static DateTime stripTime(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
