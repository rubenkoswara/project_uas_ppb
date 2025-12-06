import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/product.dart';
import '../../providers/database_providers.dart';
import '../../providers/cart_provider.dart';
import '../../providers/formatting_providers.dart';
import 'customer_order_list.dart';
import 'cart_page.dart';

class CustomerDashboard extends ConsumerStatefulWidget {
  CustomerDashboard({super.key});
  @override
  ConsumerState<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends ConsumerState<CustomerDashboard> {
  String searchQuery = '';
  String? selectedCategory;
  String? selectedBrand;

  @override
  Widget build(BuildContext context) {
    final cartCount = ref
        .watch(cartProvider)
        .fold<int>(0, (sum, item) => sum + item.quantity);
    final categoryAsync = ref.watch(categoriesProvider);
    final brandAsync = ref.watch(brandsProvider);
    final currencyFormatter = ref.watch(currencyFormatterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog MyRenesca'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartPage()),
                ),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 5,
                  top: 5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$cartCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Profil & Pesanan'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.receipt_long,
                        color: Color(0xFF00838F),
                      ),
                      title: const Text('Daftar Pesanan Saya'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CustomerOrderList(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('Keluar'),
                      onTap: () {
                        supabase.auth.signOut();
                        if (mounted)
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) {
                                return const Placeholder(); // akan diganti dengan AuthPage
                              },
                            ),
                            (route) => false,
                          );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    hintText: 'Cari peralatan aquarium...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 10,
                    ),
                  ),
                  onChanged: (val) => setState(() => searchQuery = val),
                ),
                const SizedBox(height: 10),
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
                                loading: () => const Text('Memuat...'),
                                error: (err, stack) => const Text('Error'),
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
                                        backgroundColor: Colors.grey.shade100,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        labelStyle: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                        onSelected: (selected) {
                                          setState(
                                            () => selectedCategory =
                                                selected && !isAll ? cat : null,
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
                                loading: () => const Text('Memuat...'),
                                error: (err, stack) => const Text('Error'),
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
                                        backgroundColor: Colors.grey.shade100,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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
          Expanded(
            child: StreamBuilder(
              stream: supabase.from('products').stream(primaryKey: ['id']),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                final allProducts = (snapshot.data! as List)
                    .map((e) => Product.fromJson(e))
                    .toList();

                final filteredProducts = allProducts.where((p) {
                  final nameMatch = p.name.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  );
                  final categoryMatch =
                      selectedCategory == null ||
                      p.category == selectedCategory;
                  final brandMatch =
                      selectedBrand == null || p.brand == selectedBrand;
                  return nameMatch && categoryMatch && brandMatch;
                }).toList();

                if (filteredProducts.isEmpty)
                  return const Center(child: Text('Produk tidak ditemukan'));

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    final isOutOfStock = product.stock <= 0;

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                image: product.imageUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(product.imageUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: product.imageUrl == null
                                  ? const Icon(
                                      Icons.image,
                                      size: 50,
                                      color: Colors.grey,
                                    )
                                  : null,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  currencyFormatter.format(product.price),
                                  style: const TextStyle(
                                    color: Color(0xFF00838F),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Stok: ${product.stock}',
                                  style: TextStyle(
                                    color: isOutOfStock
                                        ? Colors.red
                                        : Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isOutOfStock
                                          ? Colors.grey
                                          : const Color(0xFF00838F),
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    onPressed: isOutOfStock
                                        ? null
                                        : () {
                                            ref
                                                .read(cartProvider.notifier)
                                                .add(product);
                                            if (mounted)
                                              ScaffoldMessenger.of(
                                                context,
                                              ).hideCurrentSnackBar();
                                            if (mounted)
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Masuk Keranjang!',
                                                  ),
                                                  duration: Duration(
                                                    milliseconds: 500,
                                                  ),
                                                ),
                                              );
                                          },
                                    child: Text(
                                      isOutOfStock ? 'Habis' : 'Beli',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
