String inclineDuration(Duration duration) {
  //? День
  if (duration.inDays == 1 || duration.inDays == 21) {
    return '${duration.inDays} день';
  }
  if (duration.inDays >= 2 && duration.inDays <= 4 ||
      duration.inDays >= 22 ||
      duration.inDays == 24) {
    return '${duration.inDays} дня';
  }

  if (duration.inDays > 5) {
    return '${duration.inDays} дней';
  }

  //? Часы
  if (duration.inHours == 1 || duration.inHours == 21) {
    return '${duration.inHours} час';
  }
  if (duration.inHours >= 2 && duration.inHours <= 4 ||
      duration.inHours >= 22 ||
      duration.inHours == 24) {
    return '${duration.inHours} часа';
  }

  if (duration.inHours > 5) {
    return '${duration.inHours} часов';
  }

  //? Минуты
  if (duration.inMinutes == 1 || duration.inMinutes == 21) {
    return '${duration.inMinutes} минута';
  }
  if (duration.inMinutes >= 2 && duration.inMinutes <= 4 ||
      duration.inMinutes >= 22 ||
      duration.inMinutes == 24) {
    return '${duration.inMinutes} минуты';
  }

  if (duration.inMinutes > 5) {
    return '${duration.inMinutes} минут';
  }

  //? Секунд
  if (duration.inSeconds == 1 || duration.inSeconds == 21) {
    return '${duration.inSeconds} секунда';
  }
  if (duration.inSeconds >= 2 && duration.inSeconds <= 4 ||
      duration.inSeconds >= 22 ||
      duration.inSeconds == 24) {
    return '${duration.inSeconds} секунды';
  }

  return '${duration.inSeconds} секунд';
}
