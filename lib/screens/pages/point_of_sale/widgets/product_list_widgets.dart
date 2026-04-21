import 'package:flutter/material.dart';
import 'package:pos/domain/responses/products/product_response.dart';

class ProductListHeader extends StatelessWidget {
  const ProductListHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text('Product', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87)),
          ),
          SizedBox(width: 60, child: Text('Stock Qty', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87))),
          SizedBox(width: 50, child: Text('Price', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87))),
          SizedBox(width: 60, child: Text('Category', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87))),
          SizedBox(width: 50, child: Text('Actions', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87))),
        ],
      ),
    );
  }
}

class ProductListView extends StatelessWidget {
  final List<ProductItem> products;
  final ScrollController scrollController;
  final bool hasMore;
  final bool isLoadingProducts;
  final bool isLoadingMore;
  final String? productsError;
  final String searchQuery;
  final Function(ProductItem) onAddToCart;
  final VoidCallback onRetry;

  const ProductListView({
    super.key,
    required this.products,
    required this.scrollController,
    required this.hasMore,
    required this.isLoadingProducts,
    required this.isLoadingMore,
    this.productsError,
    required this.searchQuery,
    required this.onAddToCart,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoadingProducts && products.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Colors.blue));
    }

    if (productsError != null) {
      return ProductEmptyState(
        isError: true,
        message: 'Failed to load products',
        subMessage: 'Retry please, to fetch new products',
        onAction: onRetry,
      );
    }

    if (products.isEmpty) {
      return ProductEmptyState(
        isError: false,
        message: searchQuery.isEmpty ? 'No products available' : 'No products found',
        subMessage: searchQuery.isNotEmpty ? 'Try a different search term' : null,
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: products.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == products.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue)),
          );
        }
        return ProductCard(product: products[index], onAdd: () => onAddToCart(products[index]));
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final ProductItem product;
  final VoidCallback onAdd;

  const ProductCard({super.key, required this.product, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(6)),
            child: Center(child: Text(product.image ?? "📦", style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.itemName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(product.itemCode, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
              ],
            ),
          ),
          SizedBox(width: 60, child: Text(product.stockQty.toStringAsFixed(2), style: TextStyle(fontSize: 12, color: Colors.grey.shade700))),
          SizedBox(width: 50, child: Text(product.price.toStringAsFixed(2), style: TextStyle(fontSize: 12, color: Colors.grey.shade700))),
          SizedBox(width: 60, child: Text(product.itemGroup, style: TextStyle(fontSize: 10, color: Colors.grey.shade700), maxLines: 1, overflow: TextOverflow.ellipsis)),
          SizedBox(
            width: 50,
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.blue, size: 24),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onAdd,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductEmptyState extends StatelessWidget {
  final bool isError;
  final String message;
  final String? subMessage;
  final VoidCallback? onAction;

  const ProductEmptyState({
    super.key,
    required this.isError,
    required this.message,
    this.subMessage,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isError ? Icons.error_outline : Icons.search_off, color: isError ? Colors.red : Colors.grey.shade400, size: 48),
            const SizedBox(height: 16),
            Text(message, style: TextStyle(color: isError ? Colors.red : Colors.grey.shade600, fontWeight: FontWeight.w500)),
            if (subMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(subMessage!, style: TextStyle(color: Colors.grey.shade500, fontSize: 12), textAlign: TextAlign.center),
              ),
            if (isError && onAction != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onAction, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}
