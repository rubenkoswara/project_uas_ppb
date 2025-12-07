import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../providers/database_providers.dart';
import '../auth_page.dart'; // Import AuthPage

class AdminReportPage extends StatefulWidget {
  const AdminReportPage({super.key});

  @override
  State<AdminReportPage> createState() => _AdminReportPageState();
}

class _AdminReportPageState extends State<AdminReportPage> {
  DateTime? startDate;
  DateTime? endDate;
  String selectedPeriod = 'this_month';

  @override
  void initState() {
    super.initState();
    _setPeriod('this_month');
  }

  void _setPeriod(String period) {
    setState(() {
      selectedPeriod = period;
      final now = DateTime.now();
      startDate = null;
      endDate = null;

      if (period == 'today') {
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
      } else if (period == 'last_7_days') {
        startDate = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 6));
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
      } else if (period == 'this_month') {
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      } else if (period == 'custom') {
      } else if (period == 'all') {
        startDate = null;
        endDate = null;
      }
    });
  }

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(
        start: startDate ?? DateTime.now().subtract(const Duration(days: 7)),
        end: endDate ?? DateTime.now(),
      ),
    );
    if (picked != null) {
      setState(() {
        selectedPeriod = 'custom';
        endDate = picked.end.add(
          const Duration(hours: 23, minutes: 59, seconds: 59),
        );
        startDate = picked.start;
      });
    }
  }

  Future<Map<String, dynamic>> fetchReportData() async {
    var query = supabase
        .from('orders')
        .select('total_price, status, created_at')
        .eq('status', 'Selesai');

    if (startDate != null && endDate != null) {
      query = query
          .gte('created_at', startDate!.toIso8601String())
          .lte('created_at', endDate!.toIso8601String());
    }

    final orders = await query;

    double totalRevenue = 0;
    int completedOrders = 0;

    for (var order in orders) {
      totalRevenue += (order['total_price'] as num).toDouble();
      completedOrders++;
    }

    return {'totalRevenue': totalRevenue, 'completedOrders': completedOrders};
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    String dateRangeText = (startDate != null && endDate != null)
        ? '${DateFormat('dd/MM/yyyy').format(startDate!)} - ${DateFormat('dd/MM/yyyy').format(endDate!)}'
        : 'Semua Periode';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Penjualan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              supabase.auth.signOut();
              if (context.mounted)
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthPage()),
                  (route) => false,
                );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        [
                          'today',
                          'last_7_days',
                          'this_month',
                          'custom',
                          'all',
                        ].map((period) {
                          String label;
                          if (period == 'today')
                            label = 'Hari Ini';
                          else if (period == 'last_7_days')
                            label = '7 Hari Terakhir';
                          else if (period == 'this_month')
                            label = 'Bulan Ini';
                          else if (period == 'all')
                            label = 'Semua';
                          else
                            label = 'Rentang Kustom';

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
                            child: ChoiceChip(
                              label: Text(label),
                              selected: selectedPeriod == period,
                              selectedColor: const Color(0xFF00838F),
                              labelStyle: TextStyle(
                                color: selectedPeriod == period
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  if (period == 'custom') {
                                    _pickDateRange();
                                  } else {
                                    _setPeriod(period);
                                  }
                                }
                              },
                            ),
                          );
                        }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Periode Laporan: $dateRangeText',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Divider(),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: fetchReportData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData)
                  return const Center(
                    child: Text('Gagal memuat data laporan.'),
                  );

                final data = snapshot.data!;

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      elevation: 4,
                      child: ListTile(
                        leading: const Icon(
                          Icons.monetization_on,
                          color: Colors.green,
                          size: 40,
                        ),
                        title: const Text('Total Omset (Order Selesai)'),
                        subtitle: Text(
                          currencyFormatter.format(data['totalRevenue']),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00838F),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Card(
                      elevation: 4,
                      child: ListTile(
                        leading: const Icon(
                          Icons.receipt,
                          color: Colors.blue,
                          size: 40,
                        ),
                        title: const Text('Jumlah Transaksi Selesai'),
                        subtitle: Text(
                          '${data['completedOrders']} Transaksi',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00838F),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
