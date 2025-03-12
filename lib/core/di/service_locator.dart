import 'package:get_it/get_it.dart';
import 'package:flutter_order_manager/data/datasources/order_local_data_source.dart';
import 'package:flutter_order_manager/data/repositories/order_repository_impl.dart';
import 'package:flutter_order_manager/domain/repositories/order_repository.dart';
import 'package:flutter_order_manager/domain/usecases/order_usecases.dart';
import 'package:flutter_order_manager/core/router/app_router.dart';
import 'package:flutter_order_manager/core/services/sound_service.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  // Router
  getIt.registerSingleton<AppRouter>(AppRouter());
  
  // Services
  getIt.registerLazySingleton<SoundService>(() => SoundService());
  
  // Data sources
  getIt.registerLazySingleton<OrderLocalDataSource>(() => OrderLocalDataSource());
  
  // Repositories
  getIt.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(getIt<OrderLocalDataSource>()),
  );
  
  // Use cases
  getIt.registerLazySingleton<GetOrdersUseCase>(
    () => GetOrdersUseCase(getIt<OrderRepository>()),
  );
  
  getIt.registerLazySingleton<GetOrdersByStatusUseCase>(
    () => GetOrdersByStatusUseCase(getIt<OrderRepository>()),
  );
  
  getIt.registerLazySingleton<GetOrderByIdUseCase>(
    () => GetOrderByIdUseCase(getIt<OrderRepository>()),
  );
  
  getIt.registerLazySingleton<AddOrderUseCase>(
    () => AddOrderUseCase(getIt<OrderRepository>()),
  );
  
  getIt.registerLazySingleton<UpdateOrderUseCase>(
    () => UpdateOrderUseCase(getIt<OrderRepository>()),
  );
  
  getIt.registerLazySingleton<DeleteOrderUseCase>(
    () => DeleteOrderUseCase(getIt<OrderRepository>()),
  );
  
  getIt.registerLazySingleton<UpdateOrderStatusUseCase>(
    () => UpdateOrderStatusUseCase(getIt<OrderRepository>()),
  );
  
  getIt.registerLazySingleton<UpdateReadyStatusUseCase>(
    () => UpdateReadyStatusUseCase(getIt<OrderRepository>()),
  );
}

