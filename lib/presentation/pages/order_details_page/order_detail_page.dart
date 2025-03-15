import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_order_manager/core/router/go_route_context_extension.dart';
import 'package:flutter_order_manager/core/theme/app_colors.dart';
import 'package:flutter_order_manager/core/utils/utils.dart';
import 'package:flutter_order_manager/presentation/widgets/bottom_sheets/countdown_timer_ongoing_sheet.dart';
import 'package:flutter_order_manager/presentation/widgets/bottom_sheets/custom_bottom_sheet.dart';
import 'package:flutter_order_manager/presentation/widgets/bottom_sheets/pickup_confirmation_sheet.dart';
import 'package:flutter_order_manager/presentation/pages/order_details_page/widget/cart_item_widget.dart';
import 'package:flutter_order_manager/presentation/widgets/common/custom_button.dart';
import 'package:flutter_order_manager/presentation/widgets/common/message_bubble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_order_manager/domain/entities/order.dart';
import 'package:flutter_order_manager/domain/entities/item.dart';
import 'package:flutter_order_manager/presentation/providers/order_providers.dart';
import 'package:flutter_order_manager/core/di/service_locator.dart';
import 'package:flutter_order_manager/domain/usecases/order_usecases.dart';
import 'package:intl/intl.dart';

final timeToUpdate = StateProvider(
  (ref) => 0,
);

class OrderDetailPage extends ConsumerStatefulWidget {
  final Order order;
  final String orderId;

  const OrderDetailPage({
    super.key,
    required this.order,
    required this.orderId,
  });

  @override
  ConsumerState<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends ConsumerState<OrderDetailPage> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.order.status == "ongoing") {
        _showBottomSheet(context, widget.order);
      }
    });
    if (widget.order.status == 'ongoing') {
      _timer = Timer.periodic(const Duration(minutes: 1), (_) {
        if (mounted) {
          ref.read(timeToUpdate.notifier).state = ref.read(timeToUpdate) + 1;
        }
      });
    }
  }

  @override
  void dispose() {
    if (widget.order.status == 'ongoing') {
      _timer.cancel();

    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderByIdProvider(widget.order.id!));
    print('-------------called---build--->');

    return orderAsync.when(
      data: (currentOrder) {
        if (currentOrder == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Order Details')),
            body: const Center(child: Text('Order not found')),
          );
        }

        return _buildOrderDetails(context, ref, currentOrder);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Order Details')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: const Text('Order Details')),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildOrderDetails(BuildContext context, WidgetRef ref, Order _currentOrder) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: AppColors.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black87),
                        onPressed: () => context.goBack(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentOrder.customerName,
                            style: theme.textTheme.titleLarge,
                          ),
                          Text(
                            '+${_currentOrder.customerMobile}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.secondarySurfaceLight,
                        borderRadius: BorderRadius.circular(45),
                      ),
                      child: Text(
                        getTimeString(_currentOrder.createdTime),
                        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              // Pickup Banner
              _currentOrder.status == 'ongoing'
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      color: AppColors.secondarySurfaceLightDeep,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Pickup in ',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.primary),
                          ),
                          Consumer(
                            builder: (context, ref, child) {
                              ref.watch(timeToUpdate);

                              print('-------------called------>');
                              final minutesSinceCreation = DateTime.now().difference(_currentOrder.pickupTime).inMinutes.abs();

                              return Text(
                                '$minutesSinceCreation min ',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                              );
                            },
                          ),
                          Text(
                            '(${getTimeString(_currentOrder.pickupTime)})',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.primary),
                          )
                        ],
                      ),
                    )
                  : SizedBox(),

              SizedBox(
                height: 20,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.selectedSurface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '#${_currentOrder.id}',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textLight),
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    MessageBubble(
                      message: _currentOrder.customerNote.trim() == ''
                          ? 'No onion please, I am very allergic. It would be best if no onion was handled.'
                          : _currentOrder.customerNote,
                      backgroundColor: AppColors.secondarySurface,
                      textColor: AppColors.textPrimary,
                    ),
                    buildItemsSection(context, _currentOrder.items, theme, true),
                    _buildTotalPrice(_currentOrder.items, theme),
                    const SizedBox(height: 16),
                    _buildActionButtons(context, theme, _currentOrder),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusUpdateButton(BuildContext context, ThemeData theme, _currentOrder) {
    String nextStatus = _currentOrder.status == 'incoming' ? 'ongoing' : 'ready';
    // String buttonText = 'Mark as ${nextStatus.toUpperCase()}';

    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: 'Ready for delivery',
        onPressed: () async {
          await _updateOrderStatus(nextStatus, _currentOrder);
        },
        color: AppColors.primary,
        textColor: AppColors.colorWhite,
      ),
    );
  }



  Future<void> _updateOrderStatus(String nextStatus, Order _currentOrder) async {
    final updateOrderStatus = getIt<UpdateOrderStatusUseCase>();

    if (nextStatus == 'ready') {
      final createdTime = DateTime.now();
      _currentOrder.orderMakingFinishTime = createdTime;
    }

    await updateOrderStatus.execute(_currentOrder, nextStatus);
    ref.invalidate(orderByIdProvider(_currentOrder.id!));
    if (nextStatus == 'ready') {
      context.goBack();
    }

    // Refresh the lists
    ref.read(incomingOrdersProvider.notifier).loadOrders();
    ref.read(ongoingOrdersProvider.notifier).loadOrders();
    ref.read(readyOrdersProvider.notifier).loadOrders();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Order moved to $nextStatus',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.colorWhite),
          ),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }


  // Add a method to display the total price of the order
  Widget _buildTotalPrice(List<Item> items, ThemeData theme) {
    double total = 0;

    // Calculate total price
    for (var item in items) {
      total += item.price * item.quantity;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total: ',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${total.toStringAsFixed(2)}€',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // Update the buttons section in OrderDetailPage
  Widget _buildActionButtons(BuildContext context, ThemeData theme, Order currentOrder) {
    if (currentOrder.status == 'incoming') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomButton(
              text: 'Next',
              onPressed: () async {
                _showBottomSheetPickupConfirmOngoing(context, currentOrder);
              },
              color: AppColors.primary,
              textColor: AppColors.colorWhite),
          const SizedBox(height: 24),
          CustomButton(
              text: 'Reject',
              onPressed: () async {
                await _updateOrderStatus('rejected', currentOrder);
                context.goBack();
              },
              color: Colors.red.shade100,
              textColor: AppColors.textRed),
        ],
      );
    } else if (currentOrder.status != 'ready' && currentOrder.status != 'rejected') {
      return _buildStatusUpdateButton(context, theme, currentOrder);
    }
    // else if (currentOrder.status == 'ready') {
    //   return _buildReadyStatusButtons(context, theme,currentOrder);
    // }

    return const SizedBox.shrink();
  }

  void _showBottomSheetPickupConfirmOngoing(BuildContext context, Order order) {
    CustomBottomSheet.show(
      context: context,
      heightFactor: 0.5,
      child: PickupConfirmationSheet(order),
    );
  }

  void _showBottomSheet(BuildContext context, Order order) {
    CustomBottomSheet.show(
      context: context,
      heightFactor: 0.45,
      child: CountdownTimerSheet(order),
    );
  }
}
