import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../providers/database_providers.dart';
import 'payment_proof_page.dart';

class CustomerOrderList extends StatelessWidget {
  const CustomerOrderList({super.key});

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pesanan Saya')),
        body: const Center(
          child: Text('Anda harus login untuk melihat pesanan.'),
        ),
      );
    }

    final currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Pesanan Saya')),
      body: StreamBuilder(
        stream: supabase
            .from('orders')
            .stream(primaryKey: ['id'])
            .eq('user_id', user.id)
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final orders = snapshot.data!;

          if (orders.isEmpty)
            return const Center(child: Text('Anda belum memiliki pesanan.'));

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderDate = DateTime.parse(order['created_at']);

              return Card(
                elevation: 2,
                margin: const EdgeInsets.all(8),
                child: ExpansionTile(
                  title: Text(
                    'Order #${order['id']} - ${order['status']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          order['status'] == 'Pending' ||
                              order['status'] == 'Menunggu Pembayaran'
                          ? Colors.orange
                          : Colors.green.shade700,
                    ),
                  ),
                  subtitle: Text(
                    'Total: ${currencyFormatter.format(order['total_price'])} | ${DateFormat('dd/MM HH:mm').format(orderDate)}',
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (order['payment_proof_url'] != null) ...[
                            const Text(
                              'Bukti Pembayaran:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 200,
                              child: Center(
                                child: Image.network(
                                  order['payment_proof_url'],
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const Divider(),
                          ] else if (order['status'] == 'Menunggu Pembayaran')
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PaymentProofPage(
                                      orderId: order['id'],
                                      totalAmount: (order['total_price'] as num)
                                          .toDouble(),
                                    ),
                                  ),
                                ),
                                child: const Text('Unggah Bukti Pembayaran'),
                              ),
                            ),
                          const Text(
                            'Detail Barang:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          FutureBuilder(
                            future: supabase
                                .from('order_items')
                                .select()
                                .eq('order_id', order['id']),
                            builder: (context, itemSnap) {
                              if (!itemSnap.hasData)
                                return const LinearProgressIndicator();
                              final items = itemSnap.data as List;
                              return Column(
                                children: items
                                    .map(
                                      (i) => ListTile(
                                        dense: true,
                                        title: Text(i['product_name']),
                                        trailing: Text(
                                          '${i['quantity']}x ${currencyFormatter.format(i['price'])}',
                                        ),
                                      ),
                                    )
                                    .toList(),
                              );
                            },
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
    );
  }
}
