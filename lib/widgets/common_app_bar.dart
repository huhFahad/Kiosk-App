// lib/widgets/common_app_bar.dart
import 'package:flutter/material.dart';

typedef VoidCallback = void Function();

PreferredSizeWidget CommonAppBar({
  required BuildContext context,
  required String title,
  bool showHomeButton = true, 
  bool showCartButton = true, 
  bool showSaveButton = false,
  VoidCallback? onSavePressed,
  List<Widget>? extraActions,
}) {
  final canPop = Navigator.of(context).canPop();
  
  const double actionZoneWidth = 237.2;

  return AppBar(
    leadingWidth: actionZoneWidth, 
    automaticallyImplyLeading: false,
    leading: canPop
      ? Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded, color: Theme.of(context).primaryColor,),
            iconSize: 70, 
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Back',
          ),
        )
      : const SizedBox.shrink(),
    
    centerTitle: true,
    titleSpacing: 0.0,
    title: Text(
      title,
      overflow: TextOverflow.ellipsis,
    ),

    actions: [
      Container(
        width: actionZoneWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [

            if (showHomeButton)
              IconButton(
                icon: Icon(Icons.home_outlined, color: Theme.of(context).primaryColor,),
                iconSize: 70,
                tooltip: 'Go to Home',
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                },
              ),

            if (showCartButton)
              IconButton(
                icon: Icon(Icons.shopping_cart_outlined, color: Theme.of(context).primaryColor,),
                iconSize: 70,
                tooltip: 'View Cart',
                onPressed: () {
                  Navigator.of(context).pushNamed('/cart');
                },
              ),

            if (showSaveButton)
              IconButton(
                icon: Icon(Icons.save_outlined, color: Theme.of(context).primaryColor,),
                iconSize: 70,
                tooltip: 'Save',
                onPressed: onSavePressed,
              ),
            
            if (extraActions != null) ...extraActions!,

            const SizedBox(width: 30),
          ],
        ),
      ),
    ],
  );
}