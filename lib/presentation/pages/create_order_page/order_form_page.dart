import 'package:flutter/material.dart';
import 'package:flutter_order_manager/core/router/go_route_context_extension.dart';
import 'package:flutter_order_manager/core/theme/app_colors.dart';
import 'package:flutter_order_manager/core/utils/random_mobile_number_generator.dart';
import 'package:flutter_order_manager/core/utils/random_name_generator.dart';
import 'package:flutter_order_manager/core/utils/utils.dart';
import 'package:flutter_order_manager/presentation/pages/create_order_page/widget/info_row.dart';
import 'package:flutter_order_manager/presentation/widgets/common/custom_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_order_manager/domain/entities/order.dart';
import 'package:flutter_order_manager/domain/entities/item.dart';
import 'package:flutter_order_manager/presentation/providers/order_providers.dart';
import 'package:flutter_order_manager/presentation/widgets/new_order_banner.dart';
import 'package:flutter_order_manager/core/di/service_locator.dart';
import 'package:flutter_order_manager/domain/usecases/order_usecases.dart';
import 'package:flutter_order_manager/core/services/sound_service.dart';
import 'package:intl/intl.dart';

class OrderFormPage extends ConsumerStatefulWidget {

  const OrderFormPage({super.key});

  @override
  ConsumerState<OrderFormPage> createState() => _OrderFormPageState();
}

class _OrderFormPageState extends ConsumerState<OrderFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _customerNoteController = TextEditingController();
  final _customerMobileController = TextEditingController();
  
  late DateTime _createdTime;
  late DateTime _pickupTime;
  late DateTime _deliveryTime;
  String _status = 'incoming';
  String _readyStatus = 'Pickup in';

  @override
  void initState() {
    super.initState();
      _customerNoteController.text ='No onion please, I am very allergic. It would be best if no onion was handled.';
      // Set default times for new orders
      _createdTime = DateTime.now();
      _pickupTime = _createdTime.add(const Duration(minutes: 30));
      _deliveryTime = _pickupTime.add(const Duration(minutes: 30));

  }

  @override
  void dispose() {
    _customerNoteController.dispose();
    _customerMobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy - HH:mm');
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
         'Add Order',
          style: theme.textTheme.headlineSmall,
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              TextFormField(
                controller: _customerNoteController,
                decoration: const InputDecoration(
                  labelText: 'Customer Note',
                  border: OutlineInputBorder(),
                ),
                style: theme.textTheme.bodyLarge,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              // Display times but don't allow editing
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order Times', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      buildInfoRow('Created Time', dateFormat.format(_createdTime), theme),
                      buildInfoRow('Pickup Time', dateFormat.format(_pickupTime), theme),
                      buildInfoRow('Delivery Time', dateFormat.format(_deliveryTime), theme),
                    ],
                  ),
                ),
              ),


              const SizedBox(height: 24),
              CustomButton(text: 'Add Order', color: AppColors.primary, textColor: AppColors.colorWhite, onPressed: _saveOrder)


            ],
          ),
        ),
      ),
    );
  }




  void _saveOrder() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Generate random items or use existing ones
        final List<Item> items =  generateRandomItems(3);
        
        final order = Order(
          items: items,
          createdTime: _createdTime,
          orderMakingFinishTime: _pickupTime,
          deliveryTime: _deliveryTime,
          customerNote: _customerNoteController.text,
          pickupTime: _pickupTime,
          status: _status,
          readyStatus: _readyStatus,
          customerMobile:   RandomMobileNumberGenerator.generateUKMobileNumber(),
          customerName: RandomNameGenerator.generateRandomName()
          ,
        );
        
        int orderId = 0;
        
          // Add new order
          final addOrder = getIt<AddOrderUseCase>();
          orderId = await addOrder.execute(order);
          
          // Get the order with the new ID
          final getOrderById = getIt<GetOrderByIdUseCase>();
          final newOrder = await getOrderById.execute(orderId);

          if (newOrder != null) {
            // Play sound continuously
            await getIt<SoundService>().playOrderCreatedSound();
            
            // Show persistent banner
            ref.read(newOrderProvider.notifier).state = newOrder;
          }

        
        // Refresh providers
        ref.read(incomingOrdersProvider.notifier).loadOrders();
        ref.read(ongoingOrdersProvider.notifier).loadOrders();
        ref.read(readyOrdersProvider.notifier).loadOrders();
        
        if (context.mounted) {
          context.goBack();

        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }





}





// Example Usage:


