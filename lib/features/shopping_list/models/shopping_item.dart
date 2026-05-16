class ShoppingItem {
  final String id;
  final String name;
  final bool checked;
  final int quantity;

  const ShoppingItem({
    required this.id,
    required this.name,
    this.checked = false,
    this.quantity = 1,
  });

  ShoppingItem copyWith({String? id, String? name, bool? checked, int? quantity}) =>
      ShoppingItem(
        id: id ?? this.id,
        name: name ?? this.name,
        checked: checked ?? this.checked,
        quantity: quantity ?? this.quantity,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'checked': checked,
        'quantity': quantity,
      };

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
        id: json['id'] as String,
        name: json['name'] as String,
        checked: json['checked'] as bool? ?? false,
        quantity: json['quantity'] as int? ?? 1,
      );
}
