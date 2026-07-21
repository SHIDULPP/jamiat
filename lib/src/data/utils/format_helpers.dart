String formatRupee(num amount) {
  final raw = amount.round().toString();
  final buf = StringBuffer();
  final len = raw.length;
  for (var i = 0; i < len; i++) {
    if (i > 0 && (len - i) % 3 == 0) buf.write(',');
    buf.write(raw[i]);
  }
  return '₹ $buf';
}

String formatRupeeCompact(num amount) {
  if (amount >= 10000000) {
    return '₹ ${(amount / 10000000).toStringAsFixed(1)}Cr';
  }
  if (amount >= 100000) {
    return '₹ ${(amount / 100000).toStringAsFixed(1)}L';
  }
  if (amount >= 1000) {
    return '₹ ${(amount / 1000).toStringAsFixed(1)}K';
  }
  return formatRupee(amount);
}

String formatDobForApi(String ddMmYyyy) {
  final parts = ddMmYyyy.split('/');
  if (parts.length != 3) return ddMmYyyy;
  return '${parts[2]}-${parts[1]}-${parts[0]}';
}

String formatDobForUi(DateTime? date) {
  if (date == null) return '';
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

String formatDateLabel(DateTime? date) {
  if (date == null) return '';
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

const _monthLabels = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String formatDonationGroupLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final diff = today.difference(target).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  return '${_monthLabels[date.month - 1]} ${date.day}';
}

String formatDonationDateTime(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = _monthLabels[date.month - 1];
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'pm' : 'am';
  return '$day $month, ${date.year} • $hour:$minute $period';
}
