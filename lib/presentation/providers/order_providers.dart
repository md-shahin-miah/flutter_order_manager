import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_order_manager/domain/entities/order.dart';
import 'package:flutter_order_manager/core/di/service_locator.dart';
import 'package:flutter_order_manager/domain/usecases/order_usecases.dart';

// State notifiers
class OrdersNotifier extends StateNotifier<AsyncValue<List<Order>>> {
  final GetOrdersByStatusUseCase getOrdersByStatus;
  final String status;

  OrdersNotifier({required this.getOrdersByStatus, required this.status})
      : super(const AsyncValue.loading()) {
    loadOrders();
  }

  Future<void> loadOrders() async {
    state = const AsyncValue.loading();
    try {
      final orders = await getOrdersByStatus.execute(status);
      state = AsyncValue.data(orders);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// Providers
final incomingOrdersProvider = StateNotifierProvider<OrdersNotifier, AsyncValue<List<Order>>>((ref) {
  return OrdersNotifier(
    getOrdersByStatus: getIt<GetOrdersByStatusUseCase>(),
    status: 'incoming',
  );
});

final ongoingOrdersProvider = StateNotifierProvider<OrdersNotifier, AsyncValue<List<Order>>>((ref) {
  return OrdersNotifier(
    getOrdersByStatus: getIt<GetOrdersByStatusUseCase>(),
    status: 'ongoing',
  );
});

final readyOrdersProvider = StateNotifierProvider<OrdersNotifier, AsyncValue<List<Order>>>((ref) {
  return OrdersNotifier(
    getOrdersByStatus: getIt<GetOrdersByStatusUseCase>(),
    status: 'ready',
  );
});

final rejectedOrdersProvider = StateNotifierProvider<OrdersNotifier, AsyncValue<List<Order>>>((ref) {
  return OrdersNotifier(
    getOrdersByStatus: getIt<GetOrdersByStatusUseCase>(),
    status: 'rejected',
  );
});

// Selected order provider
final selectedOrderProvider = StateProvider<Order?>((ref) => null);

final orderByIdProvider = FutureProvider.family<Order?, int>((ref, orderId) async {
  final getOrderById = getIt<GetOrderByIdUseCase>();
  return await getOrderById.execute(orderId);
});