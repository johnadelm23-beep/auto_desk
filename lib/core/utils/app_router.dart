import 'package:go_router/go_router.dart';

import '../../features/cars/presentation/screens/add_car_screen.dart';
import '../../features/cars/presentation/screens/cars_screen.dart';
import '../../features/car_details/presentation/screens/car_details_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/history/presentation/screens/history_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../widgets/main_navigation_shell.dart';

abstract class AppRouter {
  static const String splash = '/splash';
  static const String dashboard = '/';
  static const String cars = '/cars';
  static const String addCar = '/add-car';
  static const String editCar = '/edit-car';
  static const String carDetails = '/car-details';
  static const String history = '/history';
  static const String settings = '/settings';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: dashboard,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: cars,
                builder: (context, state) => const CarsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: history,
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: addCar,
        builder: (context, state) => const AddCarScreen(),
      ),
      GoRoute(
        path: '$editCar/:id',
        builder: (context, state) {
          final carId = int.parse(state.pathParameters['id']!);
          return AddCarScreen(carId: carId);
        },
      ),
      GoRoute(
        path: '$carDetails/:id',
        builder: (context, state) {
          final carId = int.parse(state.pathParameters['id']!);
          return CarDetailsScreen(carId: carId);
        },
      ),
    ],
  );
}
