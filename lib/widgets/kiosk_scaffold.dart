// lib/widgets/kiosk_scaffold.dart
import 'package:flutter/material.dart';
import 'package:virtual_keyboard_multi_language/virtual_keyboard_multi_language.dart';

class KioskScaffold extends StatefulWidget {
  final Widget body;
  final TextEditingController? keyboardController;
  final FocusNode? keyboardFocusNode;
  final VirtualKeyboardType keyboardType; // Allow customization of keyboard type

  const KioskScaffold({
    Key? key,
    required this.body,
    this.keyboardController,
    this.keyboardFocusNode,
    this.keyboardType = VirtualKeyboardType.Alphanumeric, // Default to Alphanumeric
  }) : super(key: key);

  @override
  _KioskScaffoldState createState() => _KioskScaffoldState();
}

class _KioskScaffoldState extends State<KioskScaffold> {
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    widget.keyboardFocusNode?.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.keyboardFocusNode?.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  void didUpdateWidget(KioskScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.keyboardFocusNode != oldWidget.keyboardFocusNode) {
      oldWidget.keyboardFocusNode?.removeListener(_onFocusChange);
      widget.keyboardFocusNode?.addListener(_onFocusChange);
    }
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _isKeyboardVisible = widget.keyboardFocusNode?.hasFocus ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body is a Column, NOT wrapped in a GestureDetector
      body: Column(
        children: [
          // The main page content provided by the parent
          Expanded(
            // --- THIS IS THE CRITICAL FIX ---
            // The GestureDetector now ONLY wraps the main content area (widget.body)
            child: GestureDetector(
              onTap: () {
                // Tapping on the content area dismisses the keyboard
                FocusScope.of(context).unfocus();
              },
              // A transparent color ensures the detector covers the whole area,
              // even empty spaces.
              child: Container(
                color: Colors.transparent,
                child: widget.body,
              ),
            ),
          ),
          
          // The keyboard, which appears conditionally.
          // It is a sibling to the Expanded content, NOT a child of the GestureDetector.
          if (_isKeyboardVisible && widget.keyboardController != null)
            Container(
              color: const Color(0xFFCCCCCC),
              child: VirtualKeyboard(
                height: 350,
                textColor: Colors.black,
                fontSize: 28,
                type: widget.keyboardType, // Use the passed-in keyboard type
                textController: widget.keyboardController!,
                
              ),
            ),
        ],
      ),
    );
  }
}