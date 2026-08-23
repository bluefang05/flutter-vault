import 'package:flutter/material.dart';

String formatMoney(int cents) {
  final negative = cents < 0;
  final absolute = cents.abs();
  final whole = absolute ~/ 100;
  final decimals = absolute % 100;
  final grouped = whole.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => ',',
      );
  return '${negative ? '-' : ''}RD\$$grouped.${decimals.toString().padLeft(2, '0')}';
}

int parseMoneyToCents(String raw) {
  var value = raw.trim().replaceAll(RegExp(r'[^0-9,.-]'), '');
  if (value.isEmpty) return 0;

  final negative = value.startsWith('-');
  value = value.replaceAll('-', '');
  if (value.isEmpty) return 0;

  final lastComma = value.lastIndexOf(',');
  final lastDot = value.lastIndexOf('.');
  String whole;
  String decimals;

  if (lastComma >= 0 && lastDot >= 0) {
    final decimalIndex = lastComma > lastDot ? lastComma : lastDot;
    whole = value.substring(0, decimalIndex).replaceAll(RegExp(r'[,.]'), '');
    decimals = value.substring(decimalIndex + 1).replaceAll(RegExp(r'[,.]'), '');
  } else {
    final separatorIndex = lastComma >= 0 ? lastComma : lastDot;
    if (separatorIndex >= 0 && value.length - separatorIndex - 1 <= 2) {
      whole = value.substring(0, separatorIndex).replaceAll(RegExp(r'[,.]'), '');
      decimals = value.substring(separatorIndex + 1).replaceAll(RegExp(r'[,.]'), '');
    } else {
      whole = value.replaceAll(RegExp(r'[,.]'), '');
      decimals = '';
    }
  }

  final wholeUnits = int.tryParse(whole.isEmpty ? '0' : whole) ?? 0;
  final paddedDecimals = decimals.padRight(2, '0');
  var cents = int.tryParse(paddedDecimals.substring(0, 2)) ?? 0;
  if (paddedDecimals.length > 2 && int.tryParse(paddedDecimals[2]) != null) {
    if (int.parse(paddedDecimals[2]) >= 5) cents += 1;
  }

  var result = wholeUnits * 100 + cents;
  if (cents >= 100) result = (wholeUnits + 1) * 100;
  return negative ? -result : result;
}

String formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

String formatTime(DateTime date) {
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final suffix = date.hour >= 12 ? 'p. m.' : 'a. m.';
  return '$hour:${date.minute.toString().padLeft(2, '0')} $suffix';
}

String formatDateTime(DateTime date) => '${formatDate(date)} · ${formatTime(date)}';

DateTime startOfDay(DateTime value) => DateTime(value.year, value.month, value.day);
DateTime endOfDay(DateTime value) => DateTime(value.year, value.month, value.day, 23, 59, 59, 999);

Color statusColor(BuildContext context, String status) {
  switch (status) {
    case 'completed':
      return Colors.green;
    case 'cancelled':
    case 'no_show':
      return Colors.red;
    case 'confirmed':
      return Colors.blue;
    default:
      return Theme.of(context).colorScheme.primary;
  }
}

String statusLabel(String status) {
  switch (status) {
    case 'confirmed':
      return 'Confirmada';
    case 'completed':
      return 'Completada';
    case 'cancelled':
      return 'Cancelada';
    case 'no_show':
      return 'No asistió';
    default:
      return 'Pendiente';
  }
}
