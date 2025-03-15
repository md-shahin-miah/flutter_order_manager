import 'package:flutter/material.dart';
import 'package:flutter_order_manager/core/theme/app_colors.dart';

class OrderCard extends StatelessWidget {
  final String orderNumber;
  final String customerName;
  final String phoneNumber;
  final String time;
  final int remainingTime;
  final bool isInDelivery;

  const OrderCard({
    super.key,
    required this.orderNumber,
    required this.customerName,
    required this.phoneNumber,
    required this.time,
    required this.remainingTime,
    required this.isInDelivery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isInDelivery ? const Color(0xFFFF5C00) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isInDelivery
                            ? Colors.white.withOpacity(0.2)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '#$orderNumber',
                        style: TextStyle(
                          color: isInDelivery ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      customerName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isInDelivery ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  phoneNumber,
                  style: TextStyle(
                    color: isInDelivery
                        ? Colors.white.withOpacity(0.8)
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (isInDelivery) ...[
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
            const Text(
              'In delivery',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ]
          else ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
              decoration: BoxDecoration(
                color:AppColors.secondarySurfaceLight,
                borderRadius: BorderRadius.circular(45),
              ),
              child: Text(
                time,
                style:  TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: 0.5,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF2ECC71),
                    ),
                    strokeWidth: 4,
                  ),
                  Center(
                    child: Text(
                      remainingTime.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

