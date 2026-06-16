import 'package:ev_connect_india/features/auth/login_screen.dart';
import 'package:ev_connect_india/features/auth/phone_login_screen.dart';
import 'package:ev_connect_india/features/home/home_screen.dart';
import 'package:ev_connect_india/features/home/main_shell.dart';
import 'package:ev_connect_india/features/map/map_screen.dart';
import 'package:ev_connect_india/features/search/search_screen.dart';
import 'package:ev_connect_india/features/favorites/favorites_screen.dart';
import 'package:ev_connect_india/features/profile/profile_screen.dart';
import 'package:ev_connect_india/features/add_station/add_station_screen.dart';
import 'package:ev_connect_india/features/station_details/station_details_screen.dart';
import 'package:ev_connect_india/features/station_details/review_screen.dart';
import 'package:ev_connect_india/features/station_details/report_issue_screen.dart';
import 'package:ev_connect_india/features/route_planner/route_planner_screen.dart';
import 'package:ev_connect_india/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class Routes {
  static const String home = '/home';
  static const String map = '/map';
  static const String search = '/search';
  static const String favorites = '/favorites';
  static const String profile = '/profile';
  static const String login = '/login';
  static const String phoneLogin = '/phone-login';
  static const String addStation = '/add-station';
  static const String routePlanner = '/route-planner';
  static String stationDetails(String id) => '/station/$id';
  static String addReview(String stationId) => '/station/$stationId/review';
  static String reportIssue(String stationId) => '/station/$stationId/report';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class _AuthStateNotifier extends ChangeNotifier {
  AuthState _state = const AuthState();
  AuthState get state => _state;
  void update(AuthState newState) {
    _state = newState;
    notifyListeners();
  }
}

final authStateNotifier = _AuthStateNotifier();

GoRouter appRouter(WidgetRef ref) {
  ref.listen<AuthState>(authProvider, (_, next) {
    authStateNotifier.update(next);
  });

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.home,
    debugLogDiagnostics: true,
    refreshListenable: authStateNotifier,
    redirect: (context, state) {
      final isAuthenticated = authStateNotifier.state.isAuthenticated;
      final isLoggingIn = state.matchedLocation.contains('/login');
      if (!isAuthenticated && !isLoggingIn) return Routes.login;
      if (isAuthenticated && isLoggingIn) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.phoneLogin,
        builder: (context, state) => const PhoneLoginScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: Routes.map,
            builder: (context, state) => const MapScreen(),
          ),
          GoRoute(
            path: Routes.search,
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: Routes.favorites,
            builder: (context, state) => const FavoritesScreen(),
          ),
          GoRoute(
            path: Routes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/station/:id',
        builder: (context, state) => StationDetailsScreen(
          stationId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/station/:id/review',
        builder: (context, state) => ReviewScreen(
          stationId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/station/:id/report',
        builder: (context, state) => ReportIssueScreen(
          stationId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: Routes.addStation,
        builder: (context, state) => const AddStationScreen(),
      ),
      GoRoute(
        path: Routes.routePlanner,
        builder: (context, state) => const RoutePlannerScreen(),
      ),
    ],
  );
}
