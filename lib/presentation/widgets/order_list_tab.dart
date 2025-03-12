import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_order_manager/core/theme/app_colors.dart';
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
              return OrderListItem(order: order);
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

  const OrderListItem({super.key, required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // Calculate minutes since creation
    final minutesSinceCreation = DateTime.now().difference(order.createdTime).inMinutes;
    
    return Container(
        decoration: BoxDecoration(
          color: Colors.white, // Default to white if no color provided
          borderRadius:  BorderRadius.circular(8.0), // Default to rounded corners
          boxShadow:  [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: InkWell(
        onTap: () {
          ref.read(selectedOrderProvider.notifier).state = order;
          context.push('/order/${order.id}', extra: order);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal:18, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '#${order.id}',
                            style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold, color: AppColors.textLight
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                         order.customerName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      order.customerMobile,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold, color: AppColors.textLight
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal:18, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '#${order.id}',
                  style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold, color: AppColors.textLight
                  ),
                ),
              ),
              // Timer circle
               CircularPercentIndicator(
                radius: 25.0,
                animation: false,
                animationDuration: 1200,
                lineWidth: 5.0,
                percent: 0.3,
                center: Text(
                  '$minutesSinceCreation',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                circularStrokeCap: CircularStrokeCap.butt,
                backgroundColor:AppColors.surface,
                progressColor: Colors.teal,
              ),
              // Container(
              //   width: 40,
              //   height: 40,
              //   decoration: BoxDecoration(
              //     shape: BoxShape.circle,
              //     border: Border.all(
              //       color: theme.colorScheme.primary,
              //       width: 2,
              //     ),
              //   ),
              //   child: Center(
              //     child: Text(
              //       '$minutesSinceCreation',
              //       style: theme.textTheme.titleMedium?.copyWith(
              //         fontWeight: FontWeight.bold,
              //         color: theme.colorScheme.primary,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

