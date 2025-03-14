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
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Restaurant Bottom Sheets',
//       theme: ThemeData(
//         primarySwatch: Colors.deepOrange,
//         fontFamily: 'SF Pro Display',
//         scaffoldBackgroundColor: const Color(0xFFF5F5F5),
//       ),
//       home: const BottomSheetDemo(),
//     );
//   }
// }

class BottomSheetDemo extends StatelessWidget {
  const BottomSheetDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bottom Sheet Examples'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _showTimeSelectionSheet(context),
              child: const Text('Time Selection Sheet'),
            ),
            const SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: () => _showOrderDetailsSheet(context),
            //   child: const Text('Order Details Sheet'),
            // ),
          ],
        ),
      ),
    );
  }

  void _showTimeSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TimeSelectionSheet(),
    );
  }




}
