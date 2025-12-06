import 'package:flutter/material.dart';
import 'admin_pages/admin_product_list.dart';
import 'admin_pages/admin_order_list.dart';
import 'admin_pages/admin_category_brand_page.dart';
import 'admin_pages/admin_bank_account_page.dart';
import 'admin_pages/admin_report_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  static const List<Widget> _pages = <Widget>[
    AdminProductList(),
    AdminOrderList(),
    AdminCategoryBrandPage(),
    AdminBankAccountPage(),
    AdminReportPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Produk'),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.label), label: 'Kat/Merek'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: 'Bank',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Laporan',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF00838F),
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
