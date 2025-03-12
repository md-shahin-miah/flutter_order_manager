import 'package:flutter_order_manager/domain/entities/order.dart';
import 'package:flutter_order_manager/domain/repositories/order_repository.dart';

class GetOrdersUseCase {
  final OrderRepository repository;

  GetOrdersUseCase(this.repository);

  Future<List<Order>> execute() {
    return repository.getOrders();
  }
}

class GetOrdersByStatusUseCase {
  final OrderRepository repository;

  GetOrdersByStatusUseCase(this.repository);

  Future<List<Order>> execute(String status) {
    return repository.getOrdersByStatus(status);
  }
}

class GetOrderByIdUseCase {
  final OrderRepository repository;

  GetOrderByIdUseCase(this.repository);

  Future<Order?> execute(int id) {
    return repository.getOrderById(id);
  }
}

class AddOrderUseCase {
  final OrderRepository repository;

  AddOrderUseCase(this.repository);

  Future<int> execute(Order order) {
    return repository.addOrder(order);
  }
}

class UpdateOrderUseCase {
  final OrderRepository repository;

  UpdateOrderUseCase(this.repository);

  Future<int> execute(Order order) {
    return repository.updateOrder(order);
  }
}

class DeleteOrderUseCase {
  final OrderRepository repository;

  DeleteOrderUseCase(this.repository);

  Future<int> execute(int id) {
    return repository.deleteOrder(id);
  }
}

class UpdateOrderStatusUseCase {
  final OrderRepository repository;

  UpdateOrderStatusUseCase(this.repository);

  Future<int> execute(Order order, String newStatus) {
    final updatedOrder = order.copyWith(status: newStatus);
    return repository.updateOrder(updatedOrder);
  }
}

class UpdateReadyStatusUseCase {
  final OrderRepository repository;

  UpdateReadyStatusUseCase(this.repository);

  Future<int> execute(Order order, String newReadyStatus) {
    final updatedOrder = order.copyWith(readyStatus: newReadyStatus);
    return repository.updateOrder(updatedOrder);
  }
}

