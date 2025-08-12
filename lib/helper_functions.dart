import 'package:share_plus/share_plus.dart';
import 'storage.dart';

void shareNotes(List<int> noteIds) {
  NotesDatabase.getNoteStringToShare(noteIds).then((noteString) {
    SharePlus.instance.share(
      ShareParams(text: noteString),
    );
  });
}

String formatRelativeTime(int unixTimestamp) {
  // Convert unix timestamp (seconds) to DateTime
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000);
  DateTime now = DateTime.now();

  Duration difference = now.difference(dateTime);

  // Define time boundaries
  if (difference.inDays == 0) {
    // Today - show "Today 5:30 PM"
    String time = _formatTime(dateTime);
    return 'Today $time';
  } else if (difference.inDays == 1) {
    // Yesterday - show "Yesterday 3:15 PM"
    String time = _formatTime(dateTime);
    return 'Yesterday $time';
  } else if (difference.inDays < 7) {
    // Within a week - show "Monday 4:45 PM"
    String dayTime =
        '${_getDayName(dateTime.weekday)} ${_formatTime(dateTime)}';
    return dayTime;
  } else {
    // Older than a week - show absolute format "20th May 2025, 8:00 PM"
    String formattedDate =
        '${dateTime.day}${_getDaySuffix(dateTime.day)} ${_getMonthName(dateTime.month)} ${dateTime.year}, ${_formatTime(dateTime)}';
    return formattedDate;
  }
}

// Helper function to format time as "5:30 PM"
String _formatTime(DateTime dateTime) {
  int hour = dateTime.hour;
  String minute = dateTime.minute.toString().padLeft(2, '0');
  String period = hour >= 12 ? 'PM' : 'AM';

  // Convert to 12-hour format
  if (hour > 12) hour -= 12;
  if (hour == 0) hour = 12;

  return '$hour:$minute $period';
}

// Helper function to get day name
String _getDayName(int weekday) {
  return [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ][weekday - 1];
}

// Helper function to get month name
String _getMonthName(int month) {
  return [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ][month - 1];
}

// Helper function to get day suffix (st, nd, rd, th)
String _getDaySuffix(int day) {
  if (day >= 11 && day <= 13) {
    return 'th';
  }
  switch (day % 10) {
    case 1:
      return 'st';
    case 2:
      return 'nd';
    case 3:
      return 'rd';
    default:
      return 'th';
  }
}

extension StringCasingExtension on String {
  String capitalize() {
    if (isEmpty) {
      return this;
    }
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
