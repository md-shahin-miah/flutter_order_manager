import 'package:flutter/material.dart';
import 'package:flutter_order_manager/core/router/go_route_context_extension.dart';
import 'package:flutter_order_manager/core/theme/app_colors.dart';
import 'package:flutter_order_manager/core/utils/utils.dart';
import 'package:flutter_order_manager/domain/entities/order.dart';
import 'package:flutter_order_manager/presentation/widgets/common/custom_button.dart';

class CountdownTimerSheet extends StatelessWidget {
  Order order;

  CountdownTimerSheet(this.order, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeLeft = DateTime.now().difference(order.pickupTime).inMinutes.abs();
    final timePassed = DateTime.now().difference(order.createdTime).inMinutes.abs();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 80,
                    width: 80,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: 0.5,
                          strokeWidth: 8,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.colorGreenAccent),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$timePassed',
                                style: Theme.of(context).textTheme.headlineLarge,
                              ),
                              Text(
                                getTimeString(DateTime.now()),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '$timeLeft minutes left',
                    style:Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Start preparing the order',
                    style: Theme.of(context).textTheme.bodySmall
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'ok',
                    onPressed: () async {
                      context.goBack();
                    },
                    color: AppColors.primary,
                    textColor: AppColors.colorWhite,
                  ),

                ],
              ),
            ),
          
          ),
        )
        ],
      ),
    );
  }
}

