import 'package:flutter/material.dart';
import '../../widgets/category_brand_widgets.dart';

class AdminCategoryBrandPage extends StatelessWidget {
  const AdminCategoryBrandPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manajemen Kategori & Merek'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Kategori', icon: Icon(Icons.category)),
              Tab(text: 'Merek', icon: Icon(Icons.business_center)),
            ],
            indicatorColor: Colors.white,
          ),
        ),
        body: const TabBarView(
          children: [CategoryListWidget(), BrandListWidget()],
        ),
        floatingActionButton: Builder(
          builder: (context) {
            final tabController = DefaultTabController.of(context);

            return FloatingActionButton(
              backgroundColor: const Color(0xFF00838F),
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                final String table = tabController.index == 0
                    ? 'categories'
                    : 'brands';
                showUpsertDialog(context, table, null);
              },
            );
          },
        ),
      ),
    );
  }
}
