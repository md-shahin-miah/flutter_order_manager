import 'package:flutter_order_manager/data/datasources/order_local_data_source.dart';
import 'package:flutter_order_manager/domain/entities/order.dart';
import 'package:flutter_order_manager/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderLocalDataSource localDataSource;

  OrderRepositoryImpl(this.localDataSource);

  @override
  Future<List<Order>> getOrders() {
    return localDataSource.getOrders();
  }

  @override
  Future<List<Order>> getOrdersByStatus(String status) {
    return localDataSource.getOrdersByStatus(status);
  }

  @override
  Future<Order?> getOrderById(int id) {
    return localDataSource.getOrderById(id);
  }

  @override
  Future<int> addOrder(Order order) {
    return localDataSource.addOrder(order);
  }

  @override
  Future<int> updateOrder(Order order) {
    return localDataSource.updateOrder(order);
  }

  @override
  Future<int> deleteOrder(int id) {
    return localDataSource.deleteOrder(id);
  }
}

