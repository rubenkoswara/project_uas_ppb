import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/cart_provider.dart';
import '../../providers/database_providers.dart';
import '../../providers/formatting_providers.dart';
import 'payment_proof_page.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});
  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  bool processing = false;

  Future<void> checkout() async {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) return;

    setState(() => processing = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw 'Login diperlukan';

      double total = cart.fold(
        0,
        (sum, item) => sum + (item.product.price * item.quantity),
      );

      final orderRes = await supabase
          .from('orders')
          .insert({
            'user_id': user.id,
            'user_email': user.email,
            'total_price': total,
            'status': 'Menunggu Pembayaran',
          })
          .select()
          .single();

      final orderId = orderRes['id'];

      final itemsData = cart
          .map(
            (item) => {
              'order_id': orderId,
              'product_id': item.product.id,
              'product_name': item.product.name,
              'quantity': item.quantity,
              'price': item.product.price,
            },
          )
          .toList();

      await supabase.from('order_items').insert(itemsData);

      ref.read(cartProvider.notifier).clear();

      if (mounted) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                PaymentProofPage(orderId: orderId, totalAmount: total),
          ),
        );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal Checkout: $e')));
    }
    setState(() => processing = false);
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final currencyFormatter = ref.watch(currencyFormatterProvider);

    double total = cart.fold(
      0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang Belanja')),
      body: cart.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  Text('Keranjang masih kosong'),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      final isStockLimited =
                          item.quantity >= item.product.stock;

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              item.product.imageUrl != null
                                  ? Image.network(
                                      item.product.imageUrl!,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[300],
                                    ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      currencyFormatter.format(
                                        item.product.price,
                                      ),
                                      style: const TextStyle(
                                        color: Color(0xFF00838F),
                                      ),
                                    ),
                                    if (isStockLimited)
                                      Text(
                                        'Stok limit (${item.product.stock})',
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                    ),
                                    onPressed: () => ref
                                        .read(cartProvider.notifier)
                                        .remove(item.product.id),
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: isStockLimited
                                        ? null
                                        : () {
                                            ref
                                                .read(cartProvider.notifier)
                                                .add(item.product);
                                          },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => ref
                                        .read(cartProvider.notifier)
                                        .delete(item.product.id),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Belanja:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            currencyFormatter.format(total),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00838F),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00838F),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: processing ? null : checkout,
                          child: processing
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Checkout dan Bayar Sekarang',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
