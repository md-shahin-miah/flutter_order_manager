import 'package:flutter/material.dart';
import 'package:flutter_order_manager/domain/entities/order.dart';
import 'package:flutter_order_manager/presentation/pages/error_page/not_found_page.dart';
import 'package:flutter_order_manager/presentation/pages/home_page/home_page.dart';
import 'package:flutter_order_manager/presentation/pages/order_details_page/order_detail_page.dart';
import 'package:flutter_order_manager/presentation/pages/create_order_page/order_form_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'go_router_notifier.dart';
import 'route_names.dart';
import 'route_paths.dart';

final GlobalKey<NavigatorState> _rootNavigator = GlobalKey(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigator = GlobalKey(debugLabel: 'shell');

final goRouterProvider = Provider<GoRouter>((ref) {
  bool isDuplicate = false;
  final notifier = ref.read(goRouterNotifierProvider);

  return GoRouter(
    initialLocation: initialLocation,
    debugLogDiagnostics: true,
    navigatorKey: _rootNavigator,
    refreshListenable: notifier,
    errorBuilder: (context, state) => const NotFoundPage(),
    redirect: (context, state) {
      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.home,
        name: RouteNames.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: RoutePaths.addOrder,
        name: RouteNames.addOrder,
        builder: (context, state) => OrderFormPage(),
      ),
      //
      GoRoute(
          path: RoutePaths.orderDetails,
          name: RouteNames.orderDetails,
          builder: (context, state) {
            Order order = state.extra as Order;
            return OrderDetailPage(order: order, orderId: state.pathParameters['orderId']!);
          }
          // builder: (context, state) => OrderDetailPage(order: order, orderId: orderId),
          ),
    ],
  );
});

String initialLocation = RoutePaths.home;
