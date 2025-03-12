import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_order_manager/domain/entities/order.dart';
import 'package:flutter_order_manager/core/di/service_locator.dart';
import 'package:flutter_order_manager/core/services/sound_service.dart';
import 'package:flutter_order_manager/core/theme/app_colors.dart';
import 'package:flutter_order_manager/presentation/widgets/app_button.dart';
import 'package:flutter_order_manager/core/router/navigation_extension.dart';

// Provider to track new orders
final newOrderProvider = StateProvider<Order?>((ref) => null);

class NewOrderBanner extends ConsumerStatefulWidget {
  const NewOrderBanner({super.key});

  @override
  ConsumerState<NewOrderBanner> createState() => _NewOrderBannerState();
}

class _NewOrderBannerState extends ConsumerState<NewOrderBanner> 
    with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _blinkController,
      curve: Curves.easeInOut,
    ));

    _blinkController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final newOrder = ref.watch(newOrderProvider);
    final theme = Theme.of(context);
    
    if (newOrder == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _opacityAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: child,
          );
        },
        child: Material(
          elevation: 8,
          color: Colors.transparent,
          child: Container(
            color: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  const Icon(
                    Icons.notifications_active,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'You have a new order',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '#${newOrder.id}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppButton(
                    text: 'View',
                    variant: AppButtonVariant.secondary,
                    size: AppButtonSize.small,
                    onPressed: () {
                      // Stop sound
                      getIt<SoundService>().stopSound();
                      
                      // Clear the new order
                      ref.read(newOrderProvider.notifier).state = null;
                      
                      // Navigate to order details
                      context.gotoOrderDetails(newOrder);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

