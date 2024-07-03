
  String formatMilliseconds(int milliseconds) {
    int totalSeconds = (milliseconds / 1000).floor();
    int minutes = (totalSeconds / 60).floor();
    int seconds = totalSeconds % 60;

    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');

    return '$minutesStr:$secondsStr';
  }