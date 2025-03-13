String getTimeString(DateTime dateTime) {
  // Format the time part of the DateTime object.
  return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}