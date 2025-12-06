class CategoryBrand {
  final int id;
  final String name;

  CategoryBrand({required this.id, required this.name});

  factory CategoryBrand.fromJson(Map<String, dynamic> json) {
    return CategoryBrand(id: json['id'], name: json['name']);
  }
}
