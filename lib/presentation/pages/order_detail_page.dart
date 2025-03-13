import 'package:flutter/material.dart';
import 'package:flutter_order_manager/core/theme/app_colors.dart';
import 'package:flutter_order_manager/core/utils/utils.dart';
import 'package:flutter_order_manager/presentation/widgets/custom_button.dart';
import 'package:flutter_order_manager/presentation/widgets/message_bubble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_order_manager/domain/entities/order.dart';
import 'package:flutter_order_manager/domain/entities/item.dart';
import 'package:flutter_order_manager/domain/entities/sub_item.dart';
import 'package:flutter_order_manager/presentation/providers/order_providers.dart';
import 'package:flutter_order_manager/core/di/service_locator.dart';
import 'package:flutter_order_manager/domain/usecases/order_usecases.dart';
import 'package:flutter_order_manager/core/router/navigation_extension.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailPage extends ConsumerStatefulWidget {
  final Order order;
  final int orderId;

  const OrderDetailPage({
    super.key,
    required this.order,
    required this.orderId,
  });

  @override
  ConsumerState<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends ConsumerState<OrderDetailPage> {
  late Order _currentOrder;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    final getOrderById = getIt<GetOrderByIdUseCase>();
    final order = await getOrderById.execute(widget.orderId);
    if (order != null) {
      setState(() {
        _currentOrder = order;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy - HH:mm');
    final theme = Theme.of(context);
    final minutesSinceCreation = DateTime.now().difference(_currentOrder.pickupTime).inMinutes;

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
                            _currentOrder.customerMobile,
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
                        style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              // Pickup Banner
              _currentOrder.status == 'ongoing'
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      color: AppColors.secondarySurfaceLightDeep,
                      child: Text(
                        'Pickup in $minutesSinceCreation min ${getTimeString(_currentOrder.pickupTime)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFFF5C00),
                          fontSize: 15,
                        ),
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
                      backgroundColor: Color(0xFFF8E8DD),
                      textColor: Color(0xFF8A5A44),
                    ),
                    _buildItemsSection(context, _currentOrder.items, theme),
                    _buildTotalPrice(_currentOrder.items, theme),
                    const SizedBox(height: 16),
                    _buildActionButtons(context, theme),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemsSection(BuildContext context, List<Item> items, ThemeData theme) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (items.isEmpty)
            Text('No items', style: theme.textTheme.bodyMedium)
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildItemCard(item, theme);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildItemCard(Item item, ThemeData theme) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '${item.quantity} x ${item.name}',
                style: theme.textTheme.titleMedium?.copyWith(),
              ),
            ),
          ],
        ),
        if (item.subItems.isNotEmpty) ...[
          ...item.subItems.map((subItem) => Padding(
                padding: const EdgeInsets.only(left: 0, bottom: 2),
                child: Row(
                  children: [
                    Text(
                      subItem.name,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              )),
        ],
        Container(
          margin: EdgeInsets.only(top: 8),
          width: MediaQuery.of(context).size.width - 50,
          height: 1,
          color: AppColors.greyLight,
        ),
        SizedBox(
          height: 10,
        )
      ],
    );
  }

  Widget _buildStatusUpdateButton(BuildContext context, ThemeData theme) {
    String nextStatus = _currentOrder.status == 'incoming' ? 'ongoing' : 'ready';
    String buttonText = 'Mark as ${nextStatus.toUpperCase()}';

    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: buttonText,
        onPressed: () async {
          await _updateOrderStatus(nextStatus);
        },
        color: AppColors.primary,
        textColor: AppColors.colorWhite,
      ),
    );
  }

  Widget _buildReadyStatusButtons(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Update Ready Status:',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildReadyStatusButton('Pickup in', Colors.blue, theme),
            _buildReadyStatusButton('In Delivery', Colors.orange, theme),
            _buildReadyStatusButton('Delivered', Colors.green, theme),
          ],
        ),
      ],
    );
  }

  Widget _buildReadyStatusButton(String status, Color color, ThemeData theme) {
    bool isActive = _currentOrder.readyStatus == status;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? color : null,
        foregroundColor: isActive ? Colors.white : null,
      ),
      onPressed: isActive ? null : () => _updateReadyStatus(status),
      child: Text(status, style: theme.textTheme.labelLarge),
    );
  }

  Future<void> _updateOrderStatus(String nextStatus) async {
    final updateOrderStatus = getIt<UpdateOrderStatusUseCase>();
    await updateOrderStatus.execute(_currentOrder, nextStatus);
    context.goBack();
    // Refresh the current order
    await _loadOrder();

    // Refresh the lists
    ref.read(incomingOrdersProvider.notifier).loadOrders();
    ref.read(ongoingOrdersProvider.notifier).loadOrders();
    ref.read(readyOrdersProvider.notifier).loadOrders();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order marked as $nextStatus')),
      );
    }
  }

  Future<void> _updateReadyStatus(String readyStatus) async {
    final updateReadyStatus = getIt<UpdateReadyStatusUseCase>();
    await updateReadyStatus.execute(_currentOrder, readyStatus);

    // Refresh the current order
    await _loadOrder();

    // Refresh the ready orders list
    ref.read(readyOrdersProvider.notifier).loadOrders();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order status updated to $readyStatus')),
      );
    }
  }

  Future<void> _callCustomer(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone dialer')),
        );
      }
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Order', style: theme.textTheme.titleLarge),
        content: Text('Are you sure you want to delete this order?', style: theme.textTheme.bodyLarge),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: theme.textTheme.labelLarge),
          ),
          TextButton(
            onPressed: () async {
              final deleteOrder = getIt<DeleteOrderUseCase>();
              await deleteOrder.execute(_currentOrder.id!);

              // Refresh the lists
              ref.read(incomingOrdersProvider.notifier).loadOrders();
              ref.read(ongoingOrdersProvider.notifier).loadOrders();
              ref.read(readyOrdersProvider.notifier).loadOrders();

              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                context.gotoHomePage(); // Go back to home
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order deleted')),
                );
              }
            },
            child: Text('Delete', style: theme.textTheme.labelLarge?.copyWith(color: Colors.red)),
          ),
        ],
      ),
    );
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
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  // Update the buttons section in OrderDetailPage
  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    if (_currentOrder.status == 'incoming') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomButton(
              text: 'Next',
              onPressed: () async {
                await _updateOrderStatus('ongoing');
                context.goBack();
              },
              color: AppColors.primary,
              textColor: AppColors.colorWhite),
          const SizedBox(height: 16),
          CustomButton(
              text: 'Reject',
              onPressed: () async {
                await _updateOrderStatus('rejected');
                context.goBack();
              },
              color: Colors.red.shade100,
              textColor: AppColors.textRed),
        ],
      );
    } else if (_currentOrder.status != 'ready' && _currentOrder.status != 'rejected') {
      return _buildStatusUpdateButton(context, theme);
    } else if (_currentOrder.status == 'ready') {
      return _buildReadyStatusButtons(context, theme);
    }

    return const SizedBox.shrink();
  }
}
