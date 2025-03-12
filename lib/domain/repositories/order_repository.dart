import 'package:flutter_order_manager/domain/entities/order.dart';

abstract class OrderRepository {
  Future<List<Order>> getOrders();
  Future<List<Order>> getOrdersByStatus(String status);
  Future<Order?> getOrderById(int id);
  Future<int> addOrder(Order order);
  Future<int> updateOrder(Order order);
  Future<int> deleteOrder(int id);
}

