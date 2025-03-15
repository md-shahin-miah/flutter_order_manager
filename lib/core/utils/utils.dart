import 'dart:math';

import 'package:flutter_order_manager/domain/entities/item.dart';
import 'package:flutter_order_manager/domain/entities/sub_item.dart';

String getTimeString(DateTime dateTime) {
  // Format the time part of the DateTime object.
  return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}

// Add this method to generate random items
List<Item> generateRandomItems(int count) {
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


