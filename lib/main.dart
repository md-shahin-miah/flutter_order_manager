import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_order_manager/core/di/service_locator.dart';
import 'package:flutter_order_manager/core/router/app_router.dart';
import 'package:flutter_order_manager/presentation/widgets/new_order_banner.dart';
import 'package:flutter_order_manager/core/theme/app_theme.dart';


final GetIt getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup service locator
  setupServiceLocator();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Order Manager',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      builder: (context, child) {
        return Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) => Stack(
                children: [
                  child!,
                  const NewOrderBanner(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}


