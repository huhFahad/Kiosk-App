// lib/print_confirmation_page.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:kiosk_app/widgets/common_app_bar.dart';

class PrintConfirmationPage extends StatefulWidget {
  const PrintConfirmationPage({Key? key}) : super(key: key);

  @override
  State<PrintConfirmationPage> createState() => _PrintConfirmationPageState();
}

class _PrintConfirmationPageState extends State<PrintConfirmationPage> {
  Uint8List? _imageBytes;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only set the bytes once
    if (_imageBytes == null) {
      _imageBytes = ModalRoute.of(context)!.settings.arguments as Uint8List?;
    }
  }

  Future<void> _printImage(BuildContext context, Uint8List imageBytes) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final success = await Printing.layoutPdf(onLayout: (format) async => imageBytes);
      if (context.mounted) {
        Navigator.of(context).pop();
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Print job sent successfully!')),
          );
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Print job cancelled.')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Printing failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(context: context, title: 'Confirm Your Print'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Final Preview', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Container(
              color: Colors.grey.shade200,
              padding: const EdgeInsets.all(32.0),
              child: _imageBytes != null
                  ? InteractiveViewer(child: Image.memory(_imageBytes!))
                  : const Center(child: Text('No preview available.')),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: Column(
              children: [
                Text('Price: ₹150.00', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.print, size: 40, color: Colors.white),
                    label: const Text('Pay at Counter & Print', style: TextStyle(fontSize: 40, color: Colors.white)),
                    onPressed: _imageBytes == null ? null : () => _printImage(context, _imageBytes!),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}