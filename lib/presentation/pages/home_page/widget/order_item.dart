import 'package:flutter/material.dart';
import 'package:flutter_order_manager/core/router/go_route_context_extension.dart';
import 'package:flutter_order_manager/core/theme/app_colors.dart';
import 'package:flutter_order_manager/core/utils/utils.dart';
import 'package:flutter_order_manager/domain/entities/order.dart';
import 'package:flutter_order_manager/presentation/pages/home_page/widget/order_list_tab.dart';
import 'package:flutter_order_manager/presentation/pages/order_details_page/order_detail_page.dart';
import 'package:flutter_order_manager/presentation/providers/order_providers.dart';
import 'package:flutter_order_manager/presentation/widgets/bottom_sheets/custom_bottom_sheet.dart';
import 'package:flutter_order_manager/presentation/widgets/bottom_sheets/order_details_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';

class OrderListItem extends ConsumerWidget {
  final Order order;
  bool isInReady = false;

  OrderListItem({super.key, required this.order, required this.isInReady});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Calculate minutes since creation

    return Container(
      decoration: BoxDecoration(
        color: isInReady ? AppColors.primary: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isInReady? AppColors.primary.withOpacity(0.1): Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: InkWell(
        onTap: () {
          ref.invalidate(timeToUpdate);
          ref.read(selectedOrderProvider.notifier).state = order;

          if(isInReady){
            _showBottomSheet(context,order);
          }
          else{
            context.gotoOrderDetails(order);

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
                            color:isInReady?AppColors.colorWhite : AppColors.surfaceLight,
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
                                ?.copyWith(color:isInReady?AppColors.colorWhite: AppColors.textPrimary, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 2),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '+${order.customerMobile}',
                      style:
                      theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color:isInReady?AppColors.colorWhite : AppColors.textLight),
                    ),
                  ],
                ),
              ),

              if (isInReady) ...[
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
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary,fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                // Timer circle
                Consumer(
                  builder: (context, ref, child) {
                    final minutesSinceCreation = DateTime.now().difference(order.createdTime).inMinutes;
                    ref.watch(timerUpdateProviderHome);
                    return CircularPercentIndicator(
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
                  );}
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
      heightFactor: 0.65,
      child: OrderDetailsSheet(order),
    );
  }


}
