
import 'package:flutter/material.dart';
import 'package:flutter_order_manager/domain/entities/order.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';

/// Extension on [BuildContext] to simplify navigation
extension GoRouterContextExtension on BuildContext {
  void pop() {
    GoRouter.of(this).pop();
  }

  void gotoHomePage() {
    GoRouter.of(this).pushReplacementNamed(RouteNames.home);
  }
  void gotoAddOrder() {
    GoRouter.of(this).pushNamed(RouteNames.addOrder);
  }
  void gotoOrderDetails(Order order) {
    final orderId=order.id!.toString();
    GoRouter.of(this)
        .pushNamed(RouteNames.orderDetails, extra: order, pathParameters: {'orderId': orderId});
    // GoRouter.of(this).pushNamed(RouteNames.orderDetails);
  }



  void goBack() {
    if (canPop()) {
      pop();
    } else {
      go(RouteNames.home);
    }
  }


}
