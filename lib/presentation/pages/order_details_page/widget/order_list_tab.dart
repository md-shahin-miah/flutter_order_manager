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

import '../../home_page/widget/order_item.dart';

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

