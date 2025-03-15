import 'package:flutter/material.dart';
import 'package:flutter_order_manager/core/router/go_route_context_extension.dart';
import 'package:flutter_order_manager/core/theme/app_colors.dart';
import 'package:flutter_order_manager/core/utils/utils.dart';
import 'package:flutter_order_manager/domain/entities/order.dart';
import 'package:flutter_order_manager/presentation/pages/order_details_page/widget/cart_item_widget.dart';
import 'package:flutter_order_manager/presentation/widgets/common/message_bubble.dart';
import 'base_bottom_sheet.dart';

class OrderDetailsSheet extends StatelessWidget {
  Order order;

  OrderDetailsSheet(this.order, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final minutesSinceReady = DateTime.now().difference(order.orderMakingFinishTime).inMinutes;
    final minutesWillPickup = DateTime.now().difference(order.pickupTime).inMinutes.abs();

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => context.goBack(),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.selectedSurface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.close, size: 18),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.selectedSurface,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '#${order.id}',
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textLight),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.customerName,
                                style: theme.textTheme.titleLarge,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Text(
                        '+${order.customerMobile}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  MessageBubble(
                    message: order.customerNote.trim() == ''
                        ? 'No onion please, I am very allergic. It would be best if no onion was handled.'
                        : order.customerNote,
                    backgroundColor: AppColors.secondarySurface,
                    textColor: AppColors.textPrimary,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '$minutesSinceReady min ago',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              "(${getTimeString(order.orderMakingFinishTime)})",
                              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                            )
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.delivery_dining_outlined,
                            color: Colors.deepOrange,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 8),
                         Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Pickup in',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '$minutesWillPickup min (${getTimeString(order.pickupTime)})',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.deepOrange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  buildItemsSection(context, order.items, theme,false),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}

class OrderItem extends StatelessWidget {
  final int quantity;
  final String name;
  final String? additionalInfo;

  const OrderItem({
    Key? key,
    required this.quantity,
    required this.name,
    this.additionalInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$quantity ×',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (additionalInfo != null)
                Text(
                  additionalInfo!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
