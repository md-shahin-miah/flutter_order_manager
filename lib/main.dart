import 'package:flutter/material.dart';
import 'package:flutter_order_manager/presentation/widgets/bottom_sheets/time_selection_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_order_manager/core/di/service_locator.dart';
import 'package:flutter_order_manager/core/router/app_router.dart';
import 'package:flutter_order_manager/presentation/widgets/new_order_banner.dart';
import 'package:flutter_order_manager/core/theme/app_theme.dart';

import 'presentation/widgets/bottom_sheets/countdown_timer_sheet.dart';
import 'presentation/widgets/bottom_sheets/order_details_sheet.dart';
import 'presentation/widgets/bottom_sheets/pickup_confirmation_sheet.dart';

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = getIt<AppRouter>().router;

    return MaterialApp.router(
      title: 'Order Manager',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
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


