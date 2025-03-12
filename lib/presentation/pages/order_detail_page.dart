import 'package:flutter/material.dart';
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
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${_currentOrder.id}', style: theme.textTheme.headlineSmall),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.gotoEditOrder(_currentOrder);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmation(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${_currentOrder.id}',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Status', _currentOrder.status.toUpperCase(), theme),
                    if (_currentOrder.status == 'ready')
                      _buildInfoRow('Ready Status', _currentOrder.readyStatus, theme),
                    _buildInfoRow('Created Time', dateFormat.format(_currentOrder.createdTime), theme),
                    _buildInfoRow('Pickup Time', dateFormat.format(_currentOrder.pickupTime), theme),
                    _buildInfoRow('Delivery Time', dateFormat.format(_currentOrder.deliveryTime), theme),
                    _buildInfoRow('Customer Note', _currentOrder.customerNote, theme),
                    InkWell(
                      onTap: () => _callCustomer(_currentOrder.customerMobile),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 120,
                              child: Text(
                                'Mobile:',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Text(_currentOrder.customerMobile, style: theme.textTheme.bodyLarge),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.call, size: 16, color: Colors.blue),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildItemsSection(context, 'Items', _currentOrder.items, theme),
            _buildTotalPrice(_currentOrder.items, theme),
            const SizedBox(height: 16),
            _buildActionButtons(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }

  Widget _buildItemsSection(BuildContext context, String title, List<Item> items, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
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
      ),
    );
  }

  Widget _buildItemCard(Item item, ThemeData theme) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  currencyFormat.format(item.price),
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Quantity: ${item.quantity}',
              style: theme.textTheme.bodyMedium,
            ),
            if (item.subItems.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Ingredients:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              ...item.subItems.map((subItem) => Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 2),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 8),
                    const SizedBox(width: 8),
                    Text(
                      '${subItem.name} (x${subItem.quantity})',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusUpdateButton(BuildContext context, ThemeData theme) {
    String nextStatus = _currentOrder.status == 'incoming' ? 'ongoing' : 'ready';
    String buttonText = 'Mark as ${nextStatus.toUpperCase()}';

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () async {
          await _updateOrderStatus(nextStatus);
        },
        child: Text(buttonText, style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
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
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    double total = 0;
    
    // Calculate total price
    for (var item in items) {
      total += item.price * item.quantity;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            'Total: ',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            currencyFormat.format(total),
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () => _updateOrderStatus('ongoing'),
            child: Text(
              'Next',
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade100,
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () => _updateOrderStatus('rejected'),
            child: Text(
              'Reject',
              style: theme.textTheme.titleMedium,
            ),
          ),
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

