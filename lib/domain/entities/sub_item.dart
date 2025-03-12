class SubItem {
  final String name;
  final int quantity;

  SubItem({
    required this.name,
    required this.quantity,
  });

  // Convert SubItem to Map for JSON serialization
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
    };
  }

  // Create SubItem from Map (JSON deserialization)
  factory SubItem.fromMap(Map<String, dynamic> map) {
    return SubItem(
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? 0,
    );
  }

  @override
  String toString() {
    return '$name (x$quantity)';
  }
}

