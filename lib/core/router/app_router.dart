import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_order_manager/domain/entities/order.dart';
import 'package:flutter_order_manager/presentation/pages/home_page.dart';
import 'package:flutter_order_manager/presentation/pages/order_detail_page.dart';
import 'package:flutter_order_manager/presentation/pages/order_form_page.dart';
import 'package:flutter_order_manager/core/router/route_names.dart';

class AppRouter {
  late final GoRouter router;

  AppRouter() {
    router = GoRouter(
      initialLocation: RouteNames.home,
      routes: [
        GoRoute(
          path: RouteNames.home,
          builder: (context, state) => const HomePage(),
          routes: [
            GoRoute(
              path: 'order/:id',
              builder: (context, state) {
                final order = state.extra as Order?;
                final orderId = int.parse(state.pathParameters['id']!);
                return OrderDetailPage(order: order!, orderId: orderId);
              },
            ),
            GoRoute(
              path: 'add-order',
              builder: (context, state) => const OrderFormPage(),
            ),
            GoRoute(
              path: 'edit-order/:id',
              builder: (context, state) {
                final order = state.extra as Order;
                return OrderFormPage(order: order);
              },
            ),
          ],
        ),
      ],
    );
  }
}

