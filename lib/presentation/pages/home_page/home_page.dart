import 'package:flutter/material.dart';
import 'package:flutter_order_manager/core/router/go_route_context_extension.dart';
import 'package:flutter_order_manager/core/theme/app_colors.dart';
import 'package:flutter_order_manager/core/utils/random_mobile_number_generator.dart';
import 'package:flutter_order_manager/core/utils/random_name_generator.dart';
import 'package:flutter_order_manager/core/utils/utils.dart';
import 'package:flutter_order_manager/presentation/pages/create_order_page/order_form_page.dart';
import 'package:flutter_order_manager/presentation/pages/home_page/widget/tab_item.dart';
import 'package:flutter_order_manager/presentation/pages/home_page/widget/tab_item_rush.dart';
import 'package:flutter_order_manager/presentation/providers/order_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_order_manager/presentation/pages/order_details_page/widget/order_list_tab.dart';
import 'dart:isolate';
import 'dart:async';
import 'package:flutter_order_manager/domain/entities/order.dart';
import 'package:flutter_order_manager/core/di/service_locator.dart';
import 'package:flutter_order_manager/domain/usecases/order_usecases.dart';
import 'package:flutter_order_manager/presentation/widgets/new_order_banner.dart';
import 'package:flutter_order_manager/core/services/sound_service.dart';
import 'dart:math';
import 'package:flutter_order_manager/domain/entities/item.dart';
import 'package:flutter_order_manager/domain/entities/sub_item.dart';

// State provider for rush mode
final rushModeProvider = StateProvider<bool>((ref) => false);
final selectTabProvider = StateProvider<int>((ref) => 0);
final selectTabProviderRush = StateProvider<int>((ref) => 0);

// Message class for Isolate communication
class IsolateMessage {
  final SendPort sendPort;
  final int interval;

  IsolateMessage(this.sendPort, this.interval);
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with TickerProviderStateMixin {
  Isolate? _isolate;
  ReceivePort? _receivePort;

  @override
  void initState() {
    super.initState();
    _startOrderCreationTimer();

  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  Future<void> _startOrderCreationTimer() async {
    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(
      _timerIsolate,
      IsolateMessage(_receivePort!.sendPort, 300), // 5 minutes interval
    );

    _receivePort!.listen((message) {
      _createRandomOrder();
    });
  }

  void _stopTimer() {
    _isolate?.kill();
    _receivePort?.close();
    _isolate = null;
    _receivePort = null;
  }

  static void _timerIsolate(IsolateMessage message) {
    Timer.periodic(Duration(seconds: message.interval), (_) {
      message.sendPort.send(true);
    });
  }

  // Update the _createRandomOrder method to use Item and SubItem models
  Future<void> _createRandomOrder() async {
    try {
      // Generate random items with subitems
      final items = generateRandomItems(2); // Generate 2 random items

      // Set times
      final createdTime = DateTime.now();
      final pickupTime = createdTime.add(const Duration(minutes: 30));
      final deliveryTime = pickupTime.add(const Duration(minutes: 30));

      final order = Order(
        items: items,
        createdTime: createdTime,
        deliveryTime: deliveryTime,
        orderMakingFinishTime: pickupTime,
        customerNote: 'Automatically generated order',
        pickupTime: pickupTime,
        status: 'incoming',
        customerMobile: RandomMobileNumberGenerator.generateUKMobileNumber(),
        customerName: RandomNameGenerator.generateRandomName(),
      );

      final addOrder = getIt<AddOrderUseCase>();
      final orderId = await addOrder.execute(order);

      // Get the created order
      final getOrderById = getIt<GetOrderByIdUseCase>();
      final newOrder = await getOrderById.execute(orderId);

      if (newOrder != null) {
        // Show banner and play sound
        ref.read(newOrderProvider.notifier).state = newOrder;
        getIt<SoundService>().playOrderCreatedSound();
      }

      // Refresh the orders list
      ref.read(incomingOrdersProvider.notifier).loadOrders();
    } catch (e) {
      print('Error creating random order: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rushMode = ref.watch(rushModeProvider);


    // Watch the order counts
    final incomingOrdersAsync = ref.watch(incomingOrdersProvider);
    final ongoingOrdersAsync = ref.watch(ongoingOrdersProvider);
    final readyOrdersAsync = ref.watch(readyOrdersProvider);

    final selectedTab = ref.watch(selectTabProvider);

    final incomingCount = incomingOrdersAsync.value?.length ?? 0;
    final ongoingCount = ongoingOrdersAsync.value?.length ?? 0;
    final readyCount = readyOrdersAsync.value?.length ?? 0;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Active Orders'),
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Icon(Icons.menu),
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                context.gotoAddOrder();
              },
              icon: const Icon(Icons.add),
              label: Text('Create Order'),
            ),
          ],
        ),
        body: Column(
          children: [
            // Rush mode and restaurant status
            SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      ref.read(rushModeProvider.notifier).state = true;
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      color: rushMode ? AppColors.selectedSurface : AppColors.surfaceLight,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            color: rushMode ? theme.colorScheme.primary : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Enable Rushmode',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: rushMode ? theme.colorScheme.primary : Colors.grey
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      ref.read(rushModeProvider.notifier).state = false;
                    },
                    child: Container(
                      color: !rushMode ? AppColors.selectedSurface : AppColors.surfaceLight,
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            child: Icon(
                                size: 12,
                                !rushMode ? Icons.circle : Icons.circle_outlined,
                                color: !rushMode ? AppColors.success : AppColors.textSecondary),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Restaurant open',
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: !rushMode ? AppColors.textPrimary : Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          rushMode?  Container(
              width: MediaQuery.of(context).size.width,
              color: AppColors.primary,
              height: 40,
              child: Center(child: Text("You are in RushMode",style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight:FontWeight.bold,color: AppColors.colorWhite),)),
            ):SizedBox(),

            SizedBox(
              height: 15,
            ),
            // Custom tab bar

            !rushMode
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          buildTab('Incoming', incomingCount, theme, 0),
                          const SizedBox(width: 8),
                          buildTab('Outgoing', ongoingCount, theme, 1),
                          const SizedBox(width: 8),
                          buildTab('Ready', readyCount, theme, 2),
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          buildTabRush('Incoming', incomingCount, theme, 0, rushMode),
                          const SizedBox(width: 8),
                          buildTabRush('Outgoing', ongoingCount, theme, 1, rushMode),
                          const SizedBox(width: 8),
                          buildTabRush('Ready', readyCount, theme, 2, rushMode),
                        ],
                      ),
                    ),
                  ),
            const SizedBox(height: 16),
            // Tab content
            !rushMode
                ? Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: TabBarView(
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          OrderListTab(status: 'incoming'),
                          OrderListTab(status: 'ongoing'),
                          OrderListTab(status: 'ready'),
                        ],
                      ),
                    ),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
  Widget buildTab(String title, int count, ThemeData theme, int index) {
    return Consumer(builder: (context, ref, child) {
      final selectedIndex = ref.watch(selectTabProvider);

      return Expanded(
        child: InkWell(
          onTap: () {
            DefaultTabController.of(context).index = index;
            ref.read(selectTabProvider.notifier).state = index;
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selectedIndex == index ? theme.colorScheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selectedIndex == index ? theme.colorScheme.primary : Colors.grey.shade300,
              ),
            ),
            child: Row(

              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [

                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: selectedIndex == index ? AppColors.colorWhite : AppColors.textLight,

                  ),
                ),

                Text(
                  ' $count',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: selectedIndex == index ? AppColors.colorWhite : AppColors.textLight,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }


}
