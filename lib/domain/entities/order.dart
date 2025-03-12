import 'dart:convert';
import 'package:flutter_order_manager/domain/entities/item.dart';

class Order {
  final int? id;
  final List<Item> items;
  final DateTime createdTime; // Added created time
  final DateTime deliveryTime;
  final String customerNote;
  final DateTime pickupTime;
  final String status; // "incoming", "ongoing", "ready", "rejected"
  final String readyStatus; // "Pickup in", "In Delivery", "Delivered" (only for ready orders)
  final String customerMobile; // Added customer mobile number
  final String customerName; // Added customer mobile number

  Order({
    this.id,
    required this.items,
    required this.createdTime, // Added created time
    required this.deliveryTime,
    required this.customerNote,
    required this.pickupTime,
    required this.status,
    this.readyStatus = "Pickup in", // Default value
    required this.customerMobile,
    required this.customerName,
  });

  Order copyWith({
    int? id,
    List<Item>? items,
    DateTime? createdTime, // Added created time
    DateTime? deliveryTime,
    String? customerNote,
    DateTime? pickupTime,
    String? status,
    String? readyStatus,
    String? customerMobile,
    String? customerName,
  }) {
    return Order(
      id: id ?? this.id,
      items: items ?? this.items,
      createdTime: createdTime ?? this.createdTime, // Added created time
      deliveryTime: deliveryTime ?? this.deliveryTime,
      customerNote: customerNote ?? this.customerNote,
      pickupTime: pickupTime ?? this.pickupTime,
      status: status ?? this.status,
      readyStatus: readyStatus ?? this.readyStatus,
      customerMobile: customerMobile ?? this.customerMobile,
      customerName: customerName ?? this.customerName,
    );
  }

  // Convert items to JSON string for database storage
  String get itemsJson => jsonEncode(items.map((item) => item.toMap()).toList());

  // Parse items from JSON string from database
  static List<Item> parseItems(String itemsJson) {
    try {
      final List<dynamic> parsed = jsonDecode(itemsJson);
      return parsed.map((item) => Item.fromMap(item)).toList();
    } catch (e) {
      print('Error parsing items: $e');
      return [];
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'items': itemsJson,
      'createdTime': createdTime.toIso8601String(), // Added created time
      'deliveryTime': deliveryTime.toIso8601String(),
      'customerNote': customerNote,
      'pickupTime': pickupTime.toIso8601String(),
      'status': status,
      'readyStatus': readyStatus,
      'customerMobile': customerMobile,
      'customerName': customerName,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      items: parseItems(map['items']),
      createdTime: map['createdTime'] != null 
          ? DateTime.parse(map['createdTime']) 
          : DateTime.now(), // Added created time with fallback
      deliveryTime: DateTime.parse(map['deliveryTime']),
      customerNote: map['customerNote'],
      pickupTime: DateTime.parse(map['pickupTime']),
      status: map['status'],
      readyStatus: map['readyStatus'] ?? 'Pickup in',
      customerMobile: map['customerMobile'] ?? '',
      customerName: map['customerName'] ?? '',
    );
  }
}

