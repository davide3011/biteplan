class ShoppingItem {
  final String id;
  final String name;
  final bool checked;

  const ShoppingItem({
    required this.id,
    required this.name,
    this.checked = false,
  });

  ShoppingItem copyWith({String? id, String? name, bool? checked}) =>
      ShoppingItem(
        id: id ?? this.id,
        name: name ?? this.name,
        checked: checked ?? this.checked,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'checked': checked,
      };

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
        id: json['id'] as String,
        name: json['name'] as String,
        checked: json['checked'] as bool? ?? false,
      );
}
