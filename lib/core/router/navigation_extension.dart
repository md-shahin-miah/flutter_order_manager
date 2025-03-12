import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_order_manager/domain/entities/order.dart';
import 'package:flutter_order_manager/core/router/route_names.dart';

extension NavigationExtension on BuildContext {
  // Home navigation
  void gotoHomePage() {
    go(RouteNames.home);
  }
  
  // Order navigation
  void gotoOrderDetails(Order order) {
    push(RouteNames.getOrderDetailsPath(order.id!), extra: order);
  }
  
  void gotoAddOrder() {
    push(RouteNames.addOrder);
  }
  
  void gotoEditOrder(Order order) {
    push(RouteNames.getEditOrderPath(order.id!), extra: order);
  }
  
  // Navigation with replacement
  void replaceWithHomePage() {
    goNamed(RouteNames.home);
  }
  
  // Go back
  void goBack() {
    if (canPop()) {
      pop();
    } else {
      go(RouteNames.home);
    }
  }
}

