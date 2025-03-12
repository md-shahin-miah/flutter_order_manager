import 'package:flutter_order_manager/domain/entities/sub_item.dart';

class Item {
  final String name;
  final int quantity;
  final double price;
  final List<SubItem> subItems;

  Item({
    required this.name,
    required this.quantity,
    required this.price,
    required this.subItems,
  });

  // Convert Item to Map for JSON serialization
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
      'subItems': subItems.map((subItem) => subItem.toMap()).toList(),
    };
  }

  // Create Item from Map (JSON deserialization)
  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: map['price'] ?? 0.0,
      subItems: map['subItems'] != null
          ? List<SubItem>.from(
              (map['subItems'] as List).map((x) => SubItem.fromMap(x)))
          : [],
    );
  }

  @override
  String toString() {
    return '$name (x$quantity) - \$${price.toStringAsFixed(2)}';
  }
}

