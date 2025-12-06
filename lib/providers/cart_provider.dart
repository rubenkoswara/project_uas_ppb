import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  void add(Product product) {
    final index = state.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      if (state[index].quantity < product.stock) {
        state[index].quantity++;
        state = [...state];
      }
    } else {
      if (product.stock > 0) {
        state = [...state, CartItem(product: product)];
      }
    }
  }

  void remove(int productId) {
    final index = state.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      if (state[index].quantity > 1) {
        state[index].quantity--;
        state = [...state];
      } else {
        delete(productId);
      }
    }
  }

  void delete(int productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void clear() {
    state = [];
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);
