// lib/widgets/product_list_item.dart

import 'package:flutter/material.dart';
import 'package:kiosk_app/admin_product_list_page.dart';
import 'package:kiosk_app/models/product_model.dart';
import 'package:kiosk_app/theme/kiosk_theme.dart';
import 'package:kiosk_app/widgets/quantity_control_widget.dart';

class ProductListItem extends StatelessWidget {
  final Product product;

  const ProductListItem({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scale = KioskTheme.scale;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(8.0 * scale),
        child: Row(
          children: [
            // --- Image ---
            ProductImageView(
              imagePath: product.image,
              width: 200 * scale,
              height: 200 * scale,
            ),
            SizedBox(width: 15 * scale),
            
            // --- Text Details (Name, Price) ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 22 * scale,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5 * scale),
                  Text(
                    '₹${product.price.toStringAsFixed(2)} ${product.unit}',
                    style: TextStyle(
                      fontSize: 18 * scale,
                      color: Colors.black54,
                    )
                  ),
                ],
              ),
            ),
            SizedBox(width: 16 * scale, height: 100 * scale),

            // --- Action Controls (Map, Quantity) in a Row ---
            Column(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.map_outlined, size: 35 * scale,),
                  tooltip: 'Find on Map',
                  onPressed: () {
                    final product = this.product;
                    Navigator.pushNamed(context, '/map', arguments: product);
                  },
                ),
                SizedBox(height: 4 * scale),
                QuantityControlWidget(product: product),
              ],
            ),
          ],
        ),
      ),
    );
  }
}