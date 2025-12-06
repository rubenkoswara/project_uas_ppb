import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_brand.dart';
import '../providers/database_providers.dart';

class CategoryListWidget extends ConsumerWidget {
  const CategoryListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncCategories = ref.watch(categoriesProvider);

    return asyncCategories.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (categories) {
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final item = categories[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () =>
                          showUpsertDialog(context, 'categories', item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          deleteItem(context, 'categories', item.id, item.name),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class BrandListWidget extends ConsumerWidget {
  const BrandListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncBrands = ref.watch(brandsProvider);

    return asyncBrands.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (brands) {
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: brands.length,
          itemBuilder: (context, index) {
            final item = brands[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () =>
                          showUpsertDialog(context, 'brands', item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          deleteItem(context, 'brands', item.id, item.name),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

void showUpsertDialog(BuildContext context, String table, CategoryBrand? item) {
  final isEdit = item != null;
  final titleController = TextEditingController(text: item?.name);
  final type = table == 'categories' ? 'Kategori' : 'Merek';

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(isEdit ? 'Edit $type' : 'Tambah $type Baru'),
        content: TextField(
          controller: titleController,
          decoration: InputDecoration(
            labelText: 'Nama $type',
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty) return;

              if (isEdit) {
                await supabase
                    .from(table)
                    .update({'name': titleController.text.trim()})
                    .eq('id', item.id)
                    .select();
              } else {
                await supabase.from(table).insert({
                  'name': titleController.text.trim(),
                }).select();
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(isEdit ? 'Simpan' : 'Tambah'),
          ),
        ],
      );
    },
  );
}

void deleteItem(BuildContext context, String table, int id, String name) {
  final type = table == 'categories' ? 'Kategori' : 'Merek';
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Hapus $type'),
        content: Text(
          'Anda yakin ingin menghapus $type "$name"?\n(Produk yang menggunakan $type ini mungkin perlu diperbarui)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await supabase.from(table).delete().eq('id', id).select();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}
