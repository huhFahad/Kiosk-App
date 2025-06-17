// lib/widgets/product_list_item.dart

import 'package:flutter/material.dart';
import 'package:kiosk_app/admin_product_list_page.dart'; // For ProductImageView
import 'package:kiosk_app/models/product_model.dart';
import 'package:kiosk_app/widgets/quantity_control_widget.dart';

class ProductListItem extends StatelessWidget {
  final Product product;
  // We can add a flag to show/hide admin controls if needed in the future,
  // but for now, we'll focus on the customer view.

  const ProductListItem({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // We use the theme to ensure consistent sizing and styling
    final textTheme = Theme.of(context).textTheme;

    return Card(
      // The global CardTheme in kiosk_theme.dart will handle margin, shape, etc.
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // --- Image ---
            ProductImageView(
              imagePath: product.image,
              width: 240,
              height: 240,
            ),
            const SizedBox(width: 16),
            
            // --- Text Details (Name, Price) ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '₹${product.price.toStringAsFixed(2)} ${product.unit}',
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16, height: 100),

            // --- Action Controls (Map, Quantity) in a Row ---
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.map_outlined),
                  tooltip: 'Find on Map',
                  onPressed: () {
                    Navigator.pushNamed(context, '/map', arguments: product);
                  },
                ),
                const SizedBox(width: 4),
                QuantityControlWidget(product: product),
              ],
            ),
          ],
        ),
      ),
    );
  }
}