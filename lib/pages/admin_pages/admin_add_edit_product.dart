import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/product.dart';
import '../../providers/database_providers.dart';

class AdminAddEditProduct extends ConsumerStatefulWidget {
  final Product? product;
  const AdminAddEditProduct({super.key, this.product});
  @override
  ConsumerState<AdminAddEditProduct> createState() =>
      _AdminAddEditProductState();
}

class _AdminAddEditProductState extends ConsumerState<AdminAddEditProduct> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final hppCtrl = TextEditingController();
  final stockCtrl = TextEditingController();
  String? selectedCategory;
  String? selectedBrand;
  XFile? pickedImage;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      nameCtrl.text = widget.product!.name;
      priceCtrl.text = widget.product!.price.toString();
      hppCtrl.text = widget.product!.hpp.toString();
      stockCtrl.text = widget.product!.stock.toString();
      selectedCategory = widget.product!.category;
      selectedBrand = widget.product!.brand;
    }
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate() ||
        selectedCategory == null ||
        selectedBrand == null) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Semua field harus diisi dan Kategori/Merek harus dipilih!',
            ),
          ),
        );
      return;
    }
    setState(() => loading = true);

    String? imageUrl = widget.product?.imageUrl;

    if (pickedImage != null) {
      final file = File(pickedImage!.path);
      final path =
          'product_images/${DateTime.now().millisecondsSinceEpoch}_${pickedImage!.name}';
      try {
        await supabase.storage.from('product_images').upload(path, file);
        imageUrl = supabase.storage.from('product_images').getPublicUrl(path);
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal upload gambar: $e')));
        setState(() => loading = false);
        return;
      }
    }

    final data = {
      'name': nameCtrl.text,
      'price': double.parse(priceCtrl.text),
      'hpp': double.parse(hppCtrl.text),
      'stock': int.parse(stockCtrl.text),
      'category': selectedCategory,
      'brand': selectedBrand,
      if (imageUrl != null) 'image_url': imageUrl,
    };

    if (widget.product != null) {
      await supabase.from('products').update(data).eq('id', widget.product!.id);
    } else {
      await supabase.from('products').insert(data);
    }

    if (mounted) Navigator.pop(context);
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final categoryAsync = ref.watch(categoriesProvider);
    final brandAsync = ref.watch(brandsProvider);

    if (categoryAsync.isLoading || brandAsync.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.product != null ? 'Edit Produk' : 'Tambah Produk'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text('Memuat data Kategori dan Merek...'),
            ],
          ),
        ),
      );
    }

    final categories = categoryAsync.value?.map((e) => e.name).toList() ?? [];
    final brands = brandAsync.value?.map((e) => e.name).toList() ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product != null ? 'Edit Produk' : 'Tambah Produk'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: nameCtrl,
              autofocus: true,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'Nama Produk',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: priceCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Harga Jual',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: hppCtrl,
                    decoration: const InputDecoration(
                      labelText: 'HPP (Modal)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: stockCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Stok Fisik',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Pilih Kategori'),
                    items: categories
                        .map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => selectedCategory = val),
                    validator: (v) => v == null ? 'Pilih Kategori' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedBrand,
              decoration: const InputDecoration(
                labelText: 'Merek Produk',
                border: OutlineInputBorder(),
              ),
              hint: const Text('Pilih Merek'),
              items: brands
                  .map(
                    (brand) =>
                        DropdownMenuItem(value: brand, child: Text(brand)),
                  )
                  .toList(),
              onChanged: (val) => setState(() => selectedBrand = val),
              validator: (v) => v == null ? 'Pilih Merek' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.image),
              label: Text(
                pickedImage == null ? 'Pilih Gambar' : 'Ganti Gambar',
              ),
              onPressed: () async {
                final img = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                );
                setState(() => pickedImage = img);
              },
            ),
            const SizedBox(height: 10),
            if (pickedImage != null)
              Image.file(File(pickedImage!.path), height: 150)
            else if (widget.product?.imageUrl != null)
              Image.network(widget.product!.imageUrl!, height: 150),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00838F),
                  foregroundColor: Colors.white,
                ),
                onPressed: loading ? null : save,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan Produk'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
