import 'package:flutter/material.dart';
import 'package:flutter_order_manager/core/theme/app_colors.dart';
import 'package:flutter_order_manager/presentation/pages/order_form_page.dart';
import 'package:flutter_order_manager/presentation/providers/order_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_order_manager/presentation/widgets/order_list_tab.dart';
import 'package:flutter_order_manager/core/router/navigation_extension.dart';
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

class _HomePageState extends ConsumerState<HomePage> {
  Isolate? _isolate;
  ReceivePort? _receivePort;
  var _tabController;

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
      IsolateMessage(_receivePort!.sendPort, 120), // 2 minutes interval
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
      final items = _generateRandomItems(2); // Generate 2 random items

      // Set times
      final createdTime = DateTime.now();
      final pickupTime = createdTime.add(const Duration(minutes: 30));
      final deliveryTime = pickupTime.add(const Duration(minutes: 30));

      final order = Order(
        items: items,
        createdTime: createdTime,
        deliveryTime: deliveryTime,
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

  // Add this method to generate random items
  List<Item> _generateRandomItems(int count) {
    final foodNames = ['Pizza', 'Burger', 'Pasta', 'Salad', 'Sandwich', 'Taco', 'Sushi', 'Soup'];
    final ingredients = ['Cheese', 'Tomato', 'Lettuce', 'Onion', 'Mushroom', 'Pepperoni', 'Chicken', 'Beef', 'Bacon'];

    final random = Random();
    final items = <Item>[];

    for (int i = 0; i < count; i++) {
      // Generate random subitems (ingredients)
      final subItemCount = random.nextInt(4) + 1; // 1-4 ingredients
      final subItems = <SubItem>[];

      for (int j = 0; j < subItemCount; j++) {
        final ingredient = ingredients[random.nextInt(ingredients.length)];
        final quantity = random.nextInt(10) + 1; // 1-10 quantity

        subItems.add(SubItem(
          name: ingredient,
          quantity: quantity,
        ));
      }

      // Create the item
      final foodName = foodNames[random.nextInt(foodNames.length)];
      final quantity = random.nextInt(3) + 1; // 1-3 quantity
      final price = (random.nextInt(1500) + 500) / 100; // $5.00-$20.00

      items.add(Item(
        name: foodName,
        quantity: quantity,
        price: price,
        subItems: subItems,
      ));
    }

    return items;
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
                      ref.read(rushModeProvider.notifier).state = !rushMode;
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      color: rushMode ? AppColors.selectedSurface : AppColors.surface,
                      child: Row(
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
                              color: rushMode ? theme.colorScheme.primary : Colors.grey,
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
                      ref.read(rushModeProvider.notifier).state = !rushMode;
                    },
                    child: Container(
                      color: !rushMode ? AppColors.selectedSurface : AppColors.surface,
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: !rushMode ? Colors.green : Colors.red,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Restaurant open',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            // Custom tab bar

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildTab(
                      'Incoming',
                      incomingCount,
                      theme,
                      0,
                    ),
                    const SizedBox(width: 8),
                    _buildTab(
                      'Outgoing',
                      ongoingCount,
                      theme,
                      1,
                    ),
                    const SizedBox(width: 8),
                    _buildTab(
                      'Ready',
                      readyCount,
                      theme,
                      2,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Tab content
            const Expanded(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, int count, ThemeData theme, int index) {
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
            child: Text(
              '$title $count',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: selectedIndex == index ? Colors.white : theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    });
  }
}
