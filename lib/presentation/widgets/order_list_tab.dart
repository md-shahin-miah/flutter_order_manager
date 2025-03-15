import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_order_manager/core/theme/app_colors.dart';
import 'package:flutter_order_manager/core/utils/utils.dart';
import 'package:flutter_order_manager/presentation/widgets/bottom_sheets/custom_bottom_sheet.dart';
import 'package:flutter_order_manager/presentation/widgets/bottom_sheets/order_details_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_order_manager/domain/entities/order.dart';
import 'package:flutter_order_manager/presentation/providers/order_providers.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class OrderListTab extends ConsumerStatefulWidget {
  final String status;

  const OrderListTab({super.key, required this.status});

  @override
  ConsumerState<OrderListTab> createState() => _OrderListTabState();
}

class _OrderListTabState extends ConsumerState<OrderListTab> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Update the UI every minute to refresh the time differences
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersProvider = widget.status == 'incoming'
        ? incomingOrdersProvider
        : widget.status == 'ongoing'
            ? ongoingOrdersProvider
            : readyOrdersProvider;

    final ordersAsync = ref.watch(ordersProvider);

    return ordersAsync.when(
      data: (orders) {
        if (orders.isEmpty) {
          return Center(
            child: Text('No ${widget.status} orders'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.read(ordersProvider.notifier).loadOrders();
          },
          child: ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return OrderListItem(order: order, isInDelivery: widget.status == "ready");
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text('Error: $error'),
      ),
    );
  }
}

class OrderListItem extends ConsumerWidget {
  final Order order;
  bool isInDelivery = false;

  OrderListItem({super.key, required this.order, required this.isInDelivery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Calculate minutes since creation
    final minutesSinceCreation = DateTime.now().difference(order.createdTime).inMinutes;

    return Container(
      decoration: BoxDecoration(
        color: isInDelivery ? AppColors.primary: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isInDelivery? AppColors.primary.withOpacity(0.1): Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: InkWell(
        onTap: () {
          ref.read(selectedOrderProvider.notifier).state = order;

          if(isInDelivery){
            _showBottomSheet(context,order);
          }
          else{
            context.push('/order/${order.id}', extra: order);

          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                          decoration: BoxDecoration(
                            color:isInDelivery?AppColors.colorWhite : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '#${order.id}',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textLight),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            order.customerName ,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color:isInDelivery?AppColors.colorWhite: AppColors.textPrimary, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 2),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                     '+${order.customerMobile}',
                      style:
                          theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color:isInDelivery?AppColors.colorWhite : AppColors.textLight),
                    ),
                  ],
                ),
              ),

              if (isInDelivery) ...[
             Expanded(
               flex: 3,
               child: Row(
                 mainAxisSize: MainAxisSize.max,
                 mainAxisAlignment: MainAxisAlignment.start,
                 children: [
                   Container(
                     padding: const EdgeInsets.all(8),
                     decoration: const BoxDecoration(
                       color: Colors.white,
                       shape: BoxShape.circle,
                     ),
                     child: const Icon(
                       Icons.delivery_dining,
                       color: Color(0xFFFF5C00),
                       size: 24,
                     ),
                   ),
                   const SizedBox(width: 8),
                   Flexible(
                     child: Text(
                       order.readyStatus,
                       style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.colorWhite),
                     ),
                   ),
               
                 ],
               ),
             )
              ] else ...[


                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.secondarySurfaceLight,
                    borderRadius: BorderRadius.circular(45),
                  ),
                  child: Text(
                    getTimeString(order.createdTime),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 12),
                // Timer circle
                CircularPercentIndicator(
                  radius: 25.0,
                  animation: false,
                  animationDuration: 1200,
                  lineWidth: 5.0,
                  percent: minutesSinceCreation/30>1.0?0.4:minutesSinceCreation/30,
                  center: Text(
                    '$minutesSinceCreation',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  circularStrokeCap: CircularStrokeCap.butt,
                  backgroundColor: AppColors.surface,
                  progressColor: Colors.teal,
                ),
              ]

            ],
          ),
        ),
      ),
    );
  }
  void _showBottomSheet(BuildContext context, Order order) {
    CustomBottomSheet.show(
      context: context,
      heightFactor: 0.35,
      child: OrderDetailsSheet(order),
    );
  }


}
