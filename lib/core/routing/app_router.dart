import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/user_role.dart';
import '../../features/academic/presentation/screens/academic_hub_screen.dart';
import '../../features/academic/presentation/screens/course_syllabus_screen.dart';
import '../../features/admin/presentation/screens/institute_admin_dashboard_screen.dart';
import '../../features/auth/domain/auth_state_model.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/club_admin/presentation/screens/club_admin_dashboard_screen.dart';
import '../../features/faculty_admin/presentation/screens/faculty_console_screen.dart';
import '../../features/navigation/presentation/screens/main_navigation_shell.dart';
import '../../features/notices/presentation/screens/mentor_notices_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import 'app_routes.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AppAuthState>(
      authControllerProvider,
      (_, __) => notifyListeners(),
    );
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: notifier,
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authControllerProvider);
      final isSplash = state.matchedLocation == AppRoutes.splash;
      final isLoggingIn = state.matchedLocation == AppRoutes.login;

      // 1. Splash check while auth initializes
      if (authState is AuthInitial) {
        return AppRoutes.splash;
      }

      final isAuthenticated = authState is Authenticated;

      // 2. Unauthenticated Barrier
      if (!isAuthenticated && !isLoggingIn) {
        return AppRoutes.login;
      }

      // 3. Authenticated Redirection from Splash or Login
      if (isAuthenticated && (isLoggingIn || isSplash)) {
        return AppRoutes.dashboard;
      }

      // 4. Role-Based Route Guards
      if (isAuthenticated) {
        final role = authState.profile.role;

        // Guard: Institute Admin Portal
        if (state.matchedLocation == AppRoutes.instituteAdminDashboard) {
          if (role != UserRole.instituteAdmin) {
            return AppRoutes.dashboard;
          }
        }

        // Guard: Faculty Console
        if (state.matchedLocation == AppRoutes.facultyConsole) {
          final hasFacultyAccess =
              role == UserRole.faculty || role == UserRole.instituteAdmin;
          if (!hasFacultyAccess) {
            return AppRoutes.dashboard;
          }
        }

        // Guard: Club Admin Console
        if (state.matchedLocation == AppRoutes.clubAdminDashboard) {
          final hasClubAccess =
              role == UserRole.clubAdmin || role == UserRole.instituteAdmin;
          if (!hasClubAccess) {
            return AppRoutes.dashboard;
          }
        }
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        builder: (BuildContext context, GoRouterState state) =>
            const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (BuildContext context, GoRouterState state) =>
            const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (BuildContext context, GoRouterState state) =>
            const MainNavigationShell(),
      ),
      GoRoute(
        path: AppRoutes.academicHub,
        builder: (BuildContext context, GoRouterState state) =>
            const AcademicHubScreen(),
      ),
      GoRoute(
        path: AppRoutes.courseSyllabus,
        builder: (BuildContext context, GoRouterState state) =>
            const CourseSyllabusScreen(),
      ),
      GoRoute(
        path: AppRoutes.mentorNotices,
        builder: (BuildContext context, GoRouterState state) =>
            const MentorNoticesScreen(),
      ),
      GoRoute(
        path: AppRoutes.clubAdminDashboard,
        builder: (BuildContext context, GoRouterState state) =>
            const ClubAdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.facultyConsole,
        builder: (BuildContext context, GoRouterState state) =>
            const FacultyConsoleScreen(),
      ),
      GoRoute(
        path: AppRoutes.instituteAdminDashboard,
        builder: (BuildContext context, GoRouterState state) =>
            const InstituteAdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (BuildContext context, GoRouterState state) =>
            const NotificationsScreen(),
      ),
    ],
  );
});
