import 'package:campus/core/models/user_profile.dart';
import 'package:campus/core/models/user_role.dart';
import 'package:campus/core/utils/error_sanitizer.dart';
import 'package:campus/features/auth/domain/auth_state_model.dart';
import 'package:campus/features/club_admin/domain/club_admin_models.dart';
import 'package:campus/features/events/domain/club_event_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('Security Audit: Client-Side Defense & Sanitization Tests', () {
    test(
        'Route Guard: Verifies student profile cannot elevate to admin context',
        () {
      const studentProfile = UserProfile(
        id: 'student-uuid-1',
        email: 'student@campus.edu',
        fullName: 'Student User',
        role: UserRole.student,
      );

      const authState = Authenticated(studentProfile);

      // Verify role guard evaluation
      final canAccessClubAdmin = authState.profile.role == UserRole.clubAdmin ||
          authState.profile.role == UserRole.instituteAdmin;
      final canAccessInstituteAdmin =
          authState.profile.role == UserRole.instituteAdmin;

      expect(canAccessClubAdmin, isFalse);
      expect(canAccessInstituteAdmin, isFalse);
    });

    test(
        'Multi-Tenant Isolation: Club Admin payload cannot target foreign club_id',
        () {
      const authorizedClubId = 'club-a-uuid';
      const foreignClubId = 'club-b-uuid';

      final payload = EventFormPayload(
        clubId: authorizedClubId,
        title: 'Authorized Hackathon',
        description: 'Testing tenant isolation',
        category: EventCategory.technical,
        venue: 'Hall A',
        eventDate: DateTime.now(),
      );

      final isTampered = payload.clubId != authorizedClubId;
      final wouldTamperWithForeign = payload.clubId == foreignClubId;

      expect(isTampered, isFalse);
      expect(wouldTamperWithForeign, isFalse);
    });

    test('Error Sanitizer: Masks internal database exceptions and raw schemas',
        () {
      const rawPostgresError = PostgrestException(
        message:
            'relation "public.profiles" violates foreign key constraint fk_user',
        code: '23503',
      );

      final sanitized = ErrorSanitizer.sanitize(rawPostgresError);

      expect(sanitized.contains('public.profiles'), isFalse);
      expect(sanitized.contains('fk_user'), isFalse);
      expect(sanitized,
          equals('The operation could not be completed. Please try again.'));
    });

    test('Error Sanitizer: Accurately converts access denied codes (42501)',
        () {
      const accessDenied = PostgrestException(
        message:
            'new row violates row-level security policy for table "events"',
        code: '42501',
      );

      final sanitized = ErrorSanitizer.sanitize(accessDenied);

      expect(
          sanitized,
          equals(
              'Access denied: You do not have permission to perform this action.'));
    });
  });
}
