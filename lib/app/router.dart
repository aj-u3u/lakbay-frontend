import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../features/home/home_page.dart';
import '../features/trip/trip_page.dart';
import '../features/group/group_page.dart';
import '../features/profile/profile_page.dart';
import '../features/auth/landing_page.dart';
import '../features/auth/login_page.dart';
import '../features/auth/signup_page.dart';
import '../features/home/destination_details_page.dart';
import '../features/trip/trip_details_page.dart';
import '../features/group/group_details_page.dart';
import '../features/planner/ai_planner_page.dart';
import '../features/planner/itinerary_customize_page.dart';
import '../features/planner/models/planner_models.dart';
import '../features/planner/plan_details_page.dart';
import '../features/profile/edit_profile_page.dart';
import '../features/profile/settings_detail_page.dart';
import '../features/home/notifications_page.dart';
import '../features/home/filter_destinations_page.dart';
import '../features/home/new_special_page.dart';
import '../features/home/recommended_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/landing',
  routes: [
    GoRoute(
      path: '/landing',
      builder: (context, state) => const LandingPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupPage(),
    ),
    GoRoute(
      path: '/destination/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return DestinationDetailsPage(id: id);
      },
    ),
    GoRoute(
      path: '/trip/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return TripDetailsPage(id: id);
      },
    ),
    GoRoute(
      path: '/group/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return GroupDetailsPage(id: id);
      },
    ),
    GoRoute(
      path: '/ai-planner',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return AIPlannerPage(
          destination: extra?['destination'],
          isSolo: extra?['isSolo'] ?? true,
        );
      },
    ),
    GoRoute(
      path: '/filter',
      builder: (context, state) => const FilterDestinationsPage(),
    ),
    GoRoute(
      path: '/new-special',
      builder: (context, state) => const NewSpecialPage(),
    ),
    GoRoute(
      path: '/recommended',
      builder: (context, state) => const RecommendedPage(),
    ),
    GoRoute(
      path: '/customize-itinerary',
      builder: (context, state) {
        final plan = state.extra as PlannerItineraryPlan;
        return ItineraryCustomizePage(initialPlan: plan);
      },
    ),
    GoRoute(
      path: '/ai-plan-details',
      builder: (context, state) {
        final plan = state.extra as PlannerItineraryPlan;
        return PlanDetailsPage(plan: plan);
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomePage(),
              routes: [
                GoRoute(
                  path: 'notifications',
                  builder: (context, state) => const NotificationsPage(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/trip',
              builder: (context, state) => const TripPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/group',
              builder: (context, state) => const GroupPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfilePage(),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) => const EditProfilePage(),
                ),
                GoRoute(
                  path: 'settings/:type',
                  builder: (context, state) {
                    final type = state.pathParameters['type']!;
                    return SettingsDetailPage(title: type[0].toUpperCase() + type.substring(1));
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (int index) => _onTap(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(LucideIcons.house),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.map),
            label: 'Trip',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.users),
            label: 'Group',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.user),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
