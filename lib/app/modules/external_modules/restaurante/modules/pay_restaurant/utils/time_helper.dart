class TimeHelper {
  static String expirationRemainingTime(int seconds) {
    int minutes = (seconds / 60).floor();
    int remainingSeconds = seconds - (minutes * 60);

    return "$minutes minutos e $remainingSeconds segundos";
  }
}
