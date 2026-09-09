abstract final class GreetingHelper {
  static String getGreeting([DateTime? currentTime]) {
    final hour = (currentTime ?? DateTime.now()).hour;
    if (hour >= 5 && hour < 12) {
      return 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon';
    } else if (hour >= 17 && hour < 22) {
      return 'Good evening';
    } else {
      return 'Burning the midnight oil';
    }
  }

  static String getGreetingEmoji([DateTime? currentTime]) {
    final hour = (currentTime ?? DateTime.now()).hour;
    if (hour >= 5 && hour < 12) {
      return '☀️';
    } else if (hour >= 12 && hour < 17) {
      return '🌤️';
    } else if (hour >= 17 && hour < 22) {
      return '🌆';
    } else {
      return '🌙';
    }
  }
}
