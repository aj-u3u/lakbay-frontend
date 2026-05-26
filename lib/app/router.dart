import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'api_service.dart';
import '../features/home/home_page.dart';
import '../features/trip/trip_page.dart';
import '../features/group/group_page.dart';
import '../features/profile/profile_page.dart';
import '../features/auth/landing_page.dart';
import '../features/auth/login_page.dart';
import '../features/auth/signup_page.dart';
import '../shared/widgets/guest_explore_carousel.dart';
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
  redirect: (context, state) {
    final token = ProviderScope.containerOf(context).read(authTokenProvider);
    final isGuest = token == null;
    final path = state.uri.path;

    // Handle root path /
    if (path == '/') {
      return isGuest ? '/landing' : '/home';
    }

    // Public paths
    final isPublic = path == '/landing' || path == '/explore' || path == '/login' || path == '/signup';

    if (isGuest && !isPublic) {
      if (path.startsWith('/destination/') || path.startsWith('/trip/') || path.startsWith('/group/')) {
        return '/login?redirect=$path';
      }
      return '/explore';
    }

    // If logged in and trying to go to landing or explore, redirect to home
    if (!isGuest && (path == '/landing' || path == '/explore')) {
      return '/home';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/landing',
      builder: (context, state) => const LandingPage(),
    ),
    GoRoute(
      path: '/explore',
      builder: (context, state) => const GuestExploreCarousel(
        title: "Explore the Davao Region's\n5 provinces with us",
        redirectPath: '/home',
      ),
    ),
    GoRoute(
      path: '/login',
      redirect: (context, state) {
        final token = ProviderScope.containerOf(context).read(authTokenProvider);
        if (token != null) return '/home';
        return null;
      },
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/signup',
      redirect: (context, state) {
        final token = ProviderScope.containerOf(context).read(authTokenProvider);
        if (token != null) return '/home';
        return null;
      },
      builder: (context, state) => const SignupPage(),
    ),
    GoRoute(
      path: '/destination/:id',
      redirect: (context, state) {
        final token = ProviderScope.containerOf(context).read(authTokenProvider);
        if (token == null) {
          final id = state.pathParameters['id']!;
          return '/login?redirect=/destination/$id';
        }
        return null;
      },
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return DestinationDetailsPage(id: id);
      },
    ),
    GoRoute(
      path: '/trip/:id',
      redirect: (context, state) {
        final token = ProviderScope.containerOf(context).read(authTokenProvider);
        if (token == null) {
          final id = state.pathParameters['id']!;
          return '/login?redirect=/trip/$id';
        }
        return null;
      },
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return TripDetailsPage(id: id);
      },
    ),
    GoRoute(
      path: '/group/:id',
      redirect: (context, state) {
        final token = ProviderScope.containerOf(context).read(authTokenProvider);
        if (token == null) {
          final id = state.pathParameters['id']!;
          return '/login?redirect=/group/$id';
        }
        return null;
      },
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return GroupDetailsPage(id: id);
      },
    ),
    GoRoute(
      path: '/ai-planner',
      redirect: (context, state) {
        final token = ProviderScope.containerOf(context).read(authTokenProvider);
        if (token == null) {
          return '/login?redirect=/ai-planner';
        }
        return null;
      },
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
      redirect: (context, state) {
        final token = ProviderScope.containerOf(context).read(authTokenProvider);
        if (token == null) return '/login';
        return null;
      },
      builder: (context, state) {
        final plan = state.extra as PlannerItineraryPlan;
        return ItineraryCustomizePage(initialPlan: plan);
      },
    ),
    GoRoute(
      path: '/ai-plan-details',
      redirect: (context, state) {
        final token = ProviderScope.containerOf(context).read(authTokenProvider);
        if (token == null) return '/login';
        return null;
      },
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
