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
