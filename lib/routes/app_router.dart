
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/login_screen.dart';
import '../features/role/role_selection_screen.dart';
import '../features/scanner/scanner_screen.dart';
import '../features/visitors/visitors_screen.dart';
import '../features/visitors/visitor_detail_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/profile/profile_screen.dart';
import '../core/widgets/main_navigation.dart';
import '../models/visitor.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/role-selection',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainNavigation(child: child),
      routes: [
        GoRoute(
          path: '/scanner',
          builder: (context, state) => const ScannerScreen(),
        ),
        GoRoute(
          path: '/visitors',
          builder: (context, state) => const VisitorsScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/visitor-detail/:id',
          builder: (context, state) {
            final visitor = state.extra as Visitor?;
            if (visitor == null) {
              // Fallback if visitor is not passed via extra
              return const Scaffold(
                body: Center(
                  child: Text('Visitor not found'),
                ),
              );
            }
            return VisitorDetailScreen(visitor: visitor);
          },
        ),
      ],
    ),
  ],
);