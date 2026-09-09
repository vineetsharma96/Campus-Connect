import 'package:supabase_flutter/supabase_flutter.dart';

abstract final class ErrorSanitizer {
  static String sanitize(dynamic error) {
    if (error is PostgrestException) {
      // Handle known Postgres error codes safely
      if (error.code == '23505') {
        return 'A record with this identifier already exists.';
      }
      if (error.code == '42501') {
        return 'Access denied: You do not have permission to perform this action.';
      }
      if (error.message.contains('Conflict Error')) {
        return error.message;
      }
      return 'The operation could not be completed. Please try again.';
    }

    if (error is AuthException) {
      return error.message;
    }

    final errStr = error.toString();
    if (errStr.contains('SocketException') ||
        errStr.contains('Failed host lookup')) {
      return 'Unable to reach the campus servers. Please check your network connection.';
    }
    if (errStr.contains('TimeoutException')) {
      return 'The request timed out. Please try again.';
    }

    return 'An unexpected issue occurred. Please try again shortly.';
  }
}
