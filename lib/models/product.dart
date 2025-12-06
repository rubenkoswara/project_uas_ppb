class Product {
  final int id;
  final String name;
  final double price;
  final double hpp;
  final int stock;
  final String category;
  final String brand;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.hpp,
    required this.stock,
    required this.category,
    required this.brand,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      hpp: (json['hpp'] as num).toDouble(),
      stock: json['stock'],
      category: json['category'],
      brand: json['brand'] ?? 'Lain-lain',
      imageUrl: json['image_url'],
    );
  }
}
