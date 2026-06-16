import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _currencyFormat = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 2,
    locale: 'en_IN',
  );
  static final _compactNumberFormat = NumberFormat.compact(locale: 'en_IN');
  static final _dateFormat = DateFormat('dd MMM yyyy');
  static final _timeFormat = DateFormat('hh:mm a');
  static final _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');
  static final _relativeDateFormat = DateFormat('EEEE');
  static final _dayMonthFormat = DateFormat('dd MMM');

  static String formatCurrency(double amount) {
    return _currencyFormat.format(amount);
  }

  static String formatCompactNumber(int number) {
    return _compactNumberFormat.format(number);
  }

  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }
    final km = meters / 1000;
    if (km < 10) {
      return '${km.toStringAsFixed(1)} km';
    }
    return '${km.round()} km';
  }

  static String formatDistanceKm(double kilometers) {
    if (kilometers < 1) {
      final meters = (kilometers * 1000).round();
      return '$meters m';
    }
    if (kilometers < 10) {
      return '${kilometers.toStringAsFixed(1)} km';
    }
    return '${kilometers.round()} km';
  }

  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours.remainder(24)}h';
    }
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    }
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    }
    return '${duration.inSeconds}s';
  }

  static String formatTimeRange(int openMinutes, int closeMinutes) {
    final openHour = openMinutes ~/ 60;
    final openMin = openMinutes % 60;
    final closeHour = closeMinutes ~/ 60;
    final closeMin = closeMinutes % 60;

    return '${openHour.toString().padLeft(2, '0')}:${openMin.toString().padLeft(2, '0')} - '
        '${closeHour.toString().padLeft(2, '0')}:${closeMin.toString().padLeft(2, '0')}';
  }

  static String formatPhoneNumber(String phone) {
    if (phone.length == 10) {
      return '+91 ${phone.substring(0, 5)} ${phone.substring(5)}';
    }
    if (phone.startsWith('+91') && phone.length == 13) {
      return '+91 ${phone.substring(3, 8)} ${phone.substring(8)}';
    }
    return phone;
  }

  static String formatRating(double rating) {
    return rating.toStringAsFixed(1);
  }

  static String formatPowerKw(double powerKw) {
    if (powerKw >= 1000) {
      return '${(powerKw / 1000).toStringAsFixed(1)} MW';
    }
    return '${powerKw.toStringAsFixed(0)} kW';
  }

  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(0)}%';
  }

  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    }
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }
    return _dateFormat.format(date);
  }

  static String formatPowerInUnits(double powerKw) {
    if (powerKw >= 1000) {
      return '${(powerKw / 1000).toStringAsFixed(1)}MW';
    }
    return '${powerKw.toStringAsFixed(0)}kW';
  }

  static String formatChargerCount(int available, int total) {
    return '$available/$total';
  }

  static String listToCommaSeparated(List<String> items) {
    if (items.isEmpty) return '';
    if (items.length == 1) return items.first;
    if (items.length == 2) return '${items.first} & ${items.last}';
    return '${items.first}, ${listToCommaSeparated(items.sublist(1))}';
  }

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static String capitalizeAll(String text) {
    return text.split(' ').map(capitalize).join(' ');
  }
}

class DurationFormatter {
  static String format(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
