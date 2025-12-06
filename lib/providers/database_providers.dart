import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import '../models/category_brand.dart';
import '../services/supabase_service.dart';

// Shortcut for backward compatibility
final supabase = SupabaseService.client;

// Lazy provider for Supabase client
final supabaseProvider = Provider((ref) {
  return Supabase.instance.client;
});

final categoriesProvider = StreamProvider<List<CategoryBrand>>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase
      .from('categories')
      .stream(primaryKey: ['id'])
      .order('name')
      .map((data) {
        return data.map((json) => CategoryBrand.fromJson(json)).toList();
      });
});

final brandsProvider = StreamProvider<List<CategoryBrand>>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.from('brands').stream(primaryKey: ['id']).order('name').map((
    data,
  ) {
    return data.map((json) => CategoryBrand.fromJson(json)).toList();
  });
});

final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.from('products').stream(primaryKey: ['id']).map((data) {
    return data.map((json) => Product.fromJson(json)).toList();
  });
});
