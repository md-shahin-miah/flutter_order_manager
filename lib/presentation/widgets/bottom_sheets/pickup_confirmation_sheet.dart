import 'package:flutter/material.dart';
import 'package:flutter_order_manager/core/di/service_locator.dart';
import 'package:flutter_order_manager/core/router/go_route_context_extension.dart';
import 'package:flutter_order_manager/core/theme/app_colors.dart';
import 'package:flutter_order_manager/domain/entities/order.dart';
import 'package:flutter_order_manager/domain/usecases/order_usecases.dart';
import 'package:flutter_order_manager/presentation/providers/order_providers.dart';
import 'package:flutter_order_manager/presentation/widgets/bottom_sheets/countdown_timer_sheet.dart';
import 'package:flutter_order_manager/presentation/widgets/bottom_sheets/custom_bottom_sheet.dart';
import 'package:flutter_order_manager/presentation/widgets/bottom_sheets/time_selection_sheet.dart';
import 'package:flutter_order_manager/presentation/widgets/common/custom_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_bottom_sheet.dart';

class PickupConfirmationSheet extends StatelessWidget {
  Order order;

  PickupConfirmationSheet(this.order, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final minutesWillPickup = DateTime.now().difference(order.pickupTime).inMinutes.abs();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => context.goBack,
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Text(
                'Pickup in $minutesWillPickup min can you make it?',
                textAlign: TextAlign.center,
                style: theme.textTheme.displaySmall,
              ),
              const SizedBox(height: 16),
              Text(
                'We\'ll also send this update to the customer',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textLight),
              ),
              const SizedBox(height: 32),
              Consumer(
                builder: (context, ref, child) => CustomButton(
                  text: 'Yes, lets do it!',
                  onPressed: () async {
                    updateOrderStatus('ongoing', order, ref, context, ref.read(selectedTimeProvider));
                  },
                  color: AppColors.primary,
                  textColor: AppColors.colorWhite,
                ),
              ),
              const SizedBox(height: 26),
              CustomButton(
                text: 'No, change estimate',
                onPressed: () async {
                  context.goBack();
                  _showBottomSheetTimeSelection(context, order);
                },
                color: AppColors.secondarySurfaceLightDeep,
                textColor: AppColors.primary,
              ),
            ],
          ),
        )
      ],
    );
  }

  Future<void> updateOrderStatus(
      String nextStatus, Order _currentOrder, WidgetRef ref, BuildContext context, String time) async {
    final updateOrderStatus = getIt<UpdateOrderStatusUseCase>();


    await updateOrderStatus.execute(_currentOrder, nextStatus);
    ref.invalidate(orderByIdProvider(_currentOrder.id!));
    context.goBack();

    // Refresh the lists
    ref.read(incomingOrdersProvider.notifier).loadOrders();
    ref.read(ongoingOrdersProvider.notifier).loadOrders();
    ref.read(readyOrdersProvider.notifier).loadOrders();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order moved to $nextStatus')),
      );
    }
  }

  void _showBottomSheetTimerInComing(BuildContext context, Order order) {
    CustomBottomSheet.show(
      context: context,
      heightFactor: 0.4,
      child: CountdownTimerSheet(order),
    );
  }

  void _showBottomSheetTimeSelection(BuildContext context, Order order) {
    CustomBottomSheet.show(
      context: context,
      heightFactor: 0.6,
      child: TimeSelectionSheet(order),
    );
  }
}
