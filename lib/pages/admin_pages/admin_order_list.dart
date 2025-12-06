import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../providers/database_providers.dart';

class AdminOrderList extends StatelessWidget {
  const AdminOrderList({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Pesanan Masuk')),
      body: StreamBuilder(
        stream: supabase
            .from('orders')
            .stream(primaryKey: ['id'])
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final orders = snapshot.data!;

          if (orders.isEmpty)
            return const Center(child: Text('Belum ada pesanan'));

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
                          ? Colors.red
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
                          Text(
                            'Pelanggan: ${order['user_email'] ?? 'Unknown'}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const Divider(),

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
                                  errorBuilder: (c, o, s) =>
                                      const Text('Gagal memuat bukti bayar'),
                                ),
                              ),
                            ),
                            const Divider(),
                          ] else if (order['status'] ==
                              'Menunggu Pembayaran') ...[
                            const Text(
                              'Bukti Pembayaran: Belum diunggah oleh pelanggan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.orange,
                              ),
                            ),
                            const Divider(),
                          ],

                          const Text(
                            'Ubah Status:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Wrap(
                            spacing: 8,
                            children:
                                [
                                  'Menunggu Pembayaran',
                                  'Pending',
                                  'Proses',
                                  'Dikirim',
                                  'Selesai',
                                ].map((status) {
                                  return ChoiceChip(
                                    label: Text(status),
                                    selected: order['status'] == status,
                                    selectedColor: const Color(0xFF00838F),
                                    labelStyle: TextStyle(
                                      color: order['status'] == status
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    onSelected: (selected) async {
                                      if (selected) {
                                        await supabase
                                            .from('orders')
                                            .update({'status': status})
                                            .eq('id', order['id']);
                                      }
                                    },
                                  );
                                }).toList(),
                          ),
                          const Divider(),
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
