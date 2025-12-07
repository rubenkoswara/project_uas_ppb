import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/product.dart';
import '../../providers/database_providers.dart';
import '../../providers/formatting_providers.dart';
import '../auth_page.dart'; // Import AuthPage
import 'admin_add_edit_product.dart';

class AdminProductList extends ConsumerStatefulWidget {
  const AdminProductList({super.key});
  @override
  ConsumerState<AdminProductList> createState() => _AdminProductListState();
}

class _AdminProductListState extends ConsumerState<AdminProductList> {
  String? selectedCategory;
  String? selectedBrand;
  String sortBy = 'name_asc';

  List<Product> sortProducts(List<Product> products) {
    products.sort((a, b) {
      switch (sortBy) {
        case 'name_asc':
          return a.name.compareTo(b.name);
        case 'name_desc':
          return b.name.compareTo(a.name);
        case 'stock_asc':
          return a.stock.compareTo(b.stock);
        case 'stock_desc':
          return b.stock.compareTo(a.stock);
        case 'price_asc':
          return a.price.compareTo(b.price);
        case 'price_desc':
          return b.price.compareTo(a.price);
        default:
          return a.name.compareTo(b.name);
      }
    });
    return products;
  }

  @override
  Widget build(BuildContext context) {
    final categoryAsync = ref.watch(categoriesProvider);
    final brandAsync = ref.watch(brandsProvider);
    final currencyFormatter = ref.watch(currencyFormatterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              supabase.auth.signOut();
              if (mounted)
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) {
                      return const AuthPage();
                    },
                  ),
                );
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: supabase.from('products').stream(primaryKey: ['id']),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final allProducts = (snapshot.data! as List)
              .map((e) => Product.fromJson(e))
              .toList();

          final filteredProducts = allProducts.where((p) {
            final categoryMatch =
                selectedCategory == null || p.category == selectedCategory;
            final brandMatch =
                selectedBrand == null || p.brand == selectedBrand;
            return categoryMatch && brandMatch;
          }).toList();

          final sortedFilteredProducts = sortProducts(filteredProducts);

          final lowStockProducts = sortedFilteredProducts
              .where((p) => p.stock < 5 && p.stock > 0)
              .toList();
          final outOfStockProducts = sortedFilteredProducts
              .where((p) => p.stock == 0)
              .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Urutkan Berdasarkan:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF00838F),
                              ),
                            ),
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 0,
                                ),
                                isDense: true,
                              ),
                              value: sortBy,
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(
                                  value: 'name_asc',
                                  child: Text('Nama Produk (A-Z)'),
                                ),
                                DropdownMenuItem(
                                  value: 'name_desc',
                                  child: Text('Nama Produk (Z-A)'),
                                ),
                                DropdownMenuItem(
                                  value: 'stock_asc',
                                  child: Text('Stok (Terendah)'),
                                ),
                                DropdownMenuItem(
                                  value: 'stock_desc',
                                  child: Text('Stok (Tertinggi)'),
                                ),
                                DropdownMenuItem(
                                  value: 'price_asc',
                                  child: Text('Harga (Termurah)'),
                                ),
                                DropdownMenuItem(
                                  value: 'price_desc',
                                  child: Text('Harga (Termahal)'),
                                ),
                              ],
                              onChanged: (val) => setState(() => sortBy = val!),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Kategori:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFF00838F),
                                    ),
                                  ),
                                  categoryAsync.when(
                                    loading: () => const Center(
                                      child: Text('Memuat Kategori...'),
                                    ),
                                    error: (err, stack) =>
                                        Center(child: Text('Error: $err')),
                                    data: (data) {
                                      final categories = [
                                        'Semua',
                                        ...data.map((e) => e.name).toList(),
                                      ];
                                      return Wrap(
                                        spacing: 6.0,
                                        runSpacing: 4.0,
                                        children: categories.map((cat) {
                                          final isAll = cat == 'Semua';
                                          final isSelected = isAll
                                              ? selectedCategory == null
                                              : selectedCategory == cat;
                                          return ChoiceChip(
                                            label: Text(cat),
                                            selected: isSelected,
                                            selectedColor: const Color(
                                              0xFF00838F,
                                            ).withOpacity(0.8),
                                            backgroundColor:
                                                Colors.grey.shade100,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            labelStyle: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                            onSelected: (selected) {
                                              setState(
                                                () => selectedCategory =
                                                    selected && !isAll
                                                    ? cat
                                                    : null,
                                              );
                                            },
                                          );
                                        }).toList(),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Merek:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFF00838F),
                                    ),
                                  ),
                                  brandAsync.when(
                                    loading: () => const Center(
                                      child: Text('Memuat Merek...'),
                                    ),
                                    error: (err, stack) =>
                                        Center(child: Text('Error: $err')),
                                    data: (data) {
                                      final brands = [
                                        'Semua',
                                        ...data.map((e) => e.name).toList(),
                                      ];
                                      return Wrap(
                                        spacing: 6.0,
                                        runSpacing: 4.0,
                                        children: brands.map((brand) {
                                          final isAll = brand == 'Semua';
                                          final isSelected = isAll
                                              ? selectedBrand == null
                                              : selectedBrand == brand;
                                          return ChoiceChip(
                                            label: Text(brand),
                                            selected: isSelected,
                                            selectedColor: const Color(
                                              0xFF00838F,
                                            ).withOpacity(0.8),
                                            backgroundColor:
                                                Colors.grey.shade100,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            labelStyle: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                            onSelected: (selected) {
                                              setState(
                                                () => selectedBrand =
                                                    selected && !isAll
                                                    ? brand
                                                    : null,
                                              );
                                            },
                                          );
                                        }).toList(),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (outOfStockProducts.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.red.shade100,
                  child: ListTile(
                    leading: const Icon(Icons.warning_amber, color: Colors.red),
                    title: Text(
                      '${outOfStockProducts.length} Produk Habis Total!',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      outOfStockProducts.map((p) => p.name).join(', '),
                    ),
                  ),
                )
              else if (lowStockProducts.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.orange.shade100,
                  child: ListTile(
                    leading: const Icon(
                      Icons.notification_important,
                      color: Colors.orange,
                    ),
                    title: Text(
                      '${lowStockProducts.length} Produk Stok Hampir Habis ( < 5)',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: sortedFilteredProducts.length,
                  itemBuilder: (context, index) {
                    final item = sortedFilteredProducts[index];
                    final isLowStock = item.stock < 5;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 4,
                      ),
                      color: isLowStock ? Colors.yellow.shade50 : null,
                      child: ListTile(
                        leading: item.imageUrl != null
                            ? Image.network(
                                item.imageUrl!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (c, o, s) => Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported),
                                ),
                              )
                            : Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image),
                              ),
                        title: Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Stok: ${item.stock}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isLowStock
                                    ? Colors.red
                                    : Colors.grey.shade700,
                              ),
                            ),
                            Text(
                              'Kat: ${item.category} | Merek: ${item.brand}',
                            ),
                            Text(
                              'HPP: ${currencyFormatter.format(item.hpp)} | Jual: ${currencyFormatter.format(item.price)}',
                              style: const TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AdminAddEditProduct(product: item),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await supabase
                                    .from('products')
                                    .delete()
                                    .eq('id', item.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00838F),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminAddEditProduct()),
        ),
      ),
    );
  }
}
