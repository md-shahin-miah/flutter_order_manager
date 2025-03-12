import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_order_manager/domain/entities/order.dart';
import 'package:flutter_order_manager/domain/entities/item.dart';
import 'package:flutter_order_manager/domain/entities/sub_item.dart';
import 'package:flutter_order_manager/presentation/providers/order_providers.dart';
import 'package:flutter_order_manager/presentation/widgets/new_order_banner.dart';
import 'package:flutter_order_manager/core/di/service_locator.dart';
import 'package:flutter_order_manager/domain/usecases/order_usecases.dart';
import 'package:flutter_order_manager/core/services/sound_service.dart';
import 'package:flutter_order_manager/core/router/navigation_extension.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class OrderFormPage extends ConsumerStatefulWidget {
  final Order? order;

  const OrderFormPage({super.key, this.order});

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
    if (widget.order != null) {
      _customerNoteController.text = widget.order!.customerNote;
      _customerMobileController.text = widget.order!.customerMobile;
      _createdTime = widget.order!.createdTime;
      _pickupTime = widget.order!.pickupTime;
      _deliveryTime = widget.order!.deliveryTime;
      _status = widget.order!.status;
      _readyStatus = widget.order!.readyStatus;
    } else {
      // Set default times for new orders
      _createdTime = DateTime.now();
      _pickupTime = _createdTime.add(const Duration(minutes: 30));
      _deliveryTime = _pickupTime.add(const Duration(minutes: 30));
    }
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
          widget.order == null ? 'Add Order' : 'Edit Order #${widget.order!.id}',
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
                      _buildInfoRow('Created Time', dateFormat.format(_createdTime), theme),
                      _buildInfoRow('Pickup Time', dateFormat.format(_pickupTime), theme),
                      _buildInfoRow('Delivery Time', dateFormat.format(_deliveryTime), theme),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (widget.order != null) _buildStatusDropdown(theme),
              if (widget.order != null && _status == 'ready') 
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: _buildReadyStatusDropdown(theme),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _saveOrder,
                  child: Text(
                    widget.order == null ? 'Add Order' : 'Update Order',
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
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

  Widget _buildStatusDropdown(ThemeData theme) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(),
      ),
      value: _status,
      style: theme.textTheme.bodyLarge,
      items: const [
        DropdownMenuItem(value: 'incoming', child: Text('Incoming')),
        DropdownMenuItem(value: 'ongoing', child: Text('Ongoing')),
        DropdownMenuItem(value: 'ready', child: Text('Ready')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _status = value;
          });
        }
      },
    );
  }

  Widget _buildReadyStatusDropdown(ThemeData theme) {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Ready Status',
        border: OutlineInputBorder(),
      ),
      value: _readyStatus,
      style: theme.textTheme.bodyLarge,
      items: const [
        DropdownMenuItem(value: 'Pickup in', child: Text('Pickup in')),
        DropdownMenuItem(value: 'In Delivery', child: Text('In Delivery')),
        DropdownMenuItem(value: 'Delivered', child: Text('Delivered')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _readyStatus = value;
          });
        }
      },
    );
  }

  void _saveOrder() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Generate random items or use existing ones
        final List<Item> items = widget.order?.items ?? _generateRandomItems(3);
        
        final order = Order(
          id: widget.order?.id,
          items: items,
          createdTime: _createdTime,
          deliveryTime: _deliveryTime,
          customerNote: _customerNoteController.text,
          pickupTime: _pickupTime,
          status: _status,
          readyStatus: _readyStatus,
          customerMobile:   RandomMobileNumberGenerator.generateUKMobileNumber(),
          customerName: RandomNameGenerator.generateRandomName()
          ,
        );
        
        bool isNewOrder = widget.order == null;
        int orderId = 0;
        
        if (isNewOrder) {
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
        } else {
          // Update existing order
          final updateOrder = getIt<UpdateOrderUseCase>();
          await updateOrder.execute(order);
        }
        
        // Refresh providers
        ref.read(incomingOrdersProvider.notifier).loadOrders();
        ref.read(ongoingOrdersProvider.notifier).loadOrders();
        ref.read(readyOrdersProvider.notifier).loadOrders();
        
        if (context.mounted) {
          context.gotoHomePage();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isNewOrder ? 'Order added successfully' : 'Order updated successfully',
              ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  List<Item> _generateRandomItems(int count) {
    final foodNames = ['Pizza', 'Burger', 'Pasta', 'Salad', 'Sandwich', 'Taco', 'Sushi', 'Soup'];
    final ingredients = ['Cheese', 'Tomato', 'Lettuce', 'Onion', 'Mushroom', 'Pepperoni', 'Chicken', 'Beef', 'Bacon'];
    
    final random = Random();
    final items = <Item>[];
    
    for (int i = 0; i < count; i++) {
      // Generate random subitems (ingredients)
      final subItemCount = random.nextInt(4) + 1; // 1-4 ingredients
      final subItems = <SubItem>[];
      
      for (int j = 0; j < subItemCount; j++) {
        final ingredient = ingredients[random.nextInt(ingredients.length)];
        final quantity = random.nextInt(10) + 1; // 1-10 quantity
        
        subItems.add(SubItem(
          name: ingredient,
          quantity: quantity,
        ));
      }
      
      // Create the item
      final foodName = foodNames[random.nextInt(foodNames.length)];
      final quantity = random.nextInt(3) + 1; // 1-3 quantity
      final price = (random.nextInt(1500) + 500) / 100; // $5.00-$20.00
      
      items.add(Item(
        name: foodName,
        quantity: quantity,
        price: price,
        subItems: subItems,
      ));
    }
    
    return items;
  }




}

class RandomNameGenerator {
  static const List<String> _firstNames = [
    'Alice', 'Bob', 'Charlie', 'David', 'Eve', 'Frank', 'Grace', 'Henry', 'Ivy',
    'Jack', 'Katie', 'Liam', 'Mia', 'Noah', 'Olivia', 'Peter', 'Quinn', 'Ryan',
    'Sophia', 'Thomas', 'Uma', 'Victor', 'Willow', 'Xavier', 'Yara', 'Zane',
    'Aisha', 'Omar', 'Fatima', 'Karim', 'Layla', 'Nadia', 'Salim', 'Zara',
    'Akira', 'Kenji', 'Sakura', 'Hiroshi', 'Yumi', 'Ren', 'Ayumi', 'Daiki',
    'Isabella', 'William', 'James', 'Benjamin', 'Lucas', 'Mason', 'Ethan', 'Daniel',
    'Matthew', 'Joseph', 'Christopher', 'Andrew', 'Samuel', 'Anthony', 'Alexander',
    'Michael', 'Emily', 'Elizabeth', 'Abigail', 'Madison', 'Charlotte', 'Harper',
    'Amelia', 'Evelyn', 'Hannah', 'Scarlett', 'Victoria', 'Avery', 'Sofia',
  ];

  static const List<String> _lastNames = [
    'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis',
    'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson',
    'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin', 'Lee', 'Perez', 'Thompson',
    'White', 'Harris', 'Sanchez', 'Clark', 'Ramirez', 'Lewis', 'Robinson', 'Walker',
    'Young', 'Allen', 'King', 'Wright', 'Scott', 'Torres', 'Nguyen', 'Hill',
    'Flores', 'Green', 'Adams', 'Nelson', 'Baker', 'Hall', 'Rivera', 'Campbell',
    'Mitchell', 'Carter', 'Roberts', 'Gomez', 'Phillips', 'Evans', 'Turner',
    'Diaz', 'Parker', 'Cruz', 'Edwards', 'Collins', 'Reyes', 'Stewart', 'Morris',
    'Morales', 'Murphy', 'Cook', 'Rogers', 'Gutierrez', 'Ortiz', 'Morgan', 'Cooper',
    'Peterson', 'Bailey', 'Reed', 'Kelly', 'Howard', 'Ward', 'Cox', 'Richardson',
    'Watson', 'Brooks', 'Wood', 'James', 'Bennett', 'Gray', 'Mendoza', 'Ruiz',
    'Hughes', 'Price', 'Alvarez', 'Castillo', 'Sanders', 'Patel', 'Myers', 'Long',
    'Ross', 'Foster', 'Jimenez',
  ];

  static String generateRandomName() {
    final random = Random();
    final firstName = _firstNames[random.nextInt(_firstNames.length)];
    final lastName = _lastNames[random.nextInt(_lastNames.length)];
    return '$firstName $lastName';
  }

  static String generateRandomFirstName() {
    final random = Random();
    return _firstNames[random.nextInt(_firstNames.length)];
  }

  static String generateRandomLastName() {
    final random = Random();
    return _lastNames[random.nextInt(_lastNames.length)];
  }
}


class RandomMobileNumberGenerator {
  static String generateMobileNumber({String countryCode = '1', int length = 10}) {
    final random = Random();
    String number = countryCode;

    // Ensure the length is valid.
    if (length < 1) {
      return ''; // Or throw an exception
    }
    //Ensure the length of the generated number does not exceed the provided length.
    for (int i = 0; i < length - countryCode.length; i++) {
      number += random.nextInt(10).toString();
    }

    return number;
  }


  static String generateUKMobileNumber() {
    // UK mobile numbers typically follow the format +44-XXXXXXXXX
    return generateMobileNumber(countryCode: '44', length: 10);
  }
}

// Example Usage:


