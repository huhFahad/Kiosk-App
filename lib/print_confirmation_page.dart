// lib/print_confirmation_page.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
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
    if (_imageBytes == null) {
      _imageBytes = ModalRoute.of(context)!.settings.arguments as Uint8List?;
    }
  }

  Future<void> _directPrintImage(BuildContext context, Uint8List imageBytes) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Dialog(child: Padding(padding: EdgeInsets.all(20), child: Row(children: [CircularProgressIndicator(), SizedBox(width: 20), Text("Preparing Print...")]))),
    );

    try {
      // --- PDF CREATION LOGIC ---
      // 1. Create a new PDF Document
      final doc = pw.Document();
      // 2. Create a PDF-compatible image from our raw image bytes
      final image = pw.MemoryImage(imageBytes);
      // 3. Add a page to the document and place the image on it
      doc.addPage(pw.Page(
        // We can add page format options here if needed later
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(image),
          );
        },
      ));
      // 4. Get the raw byte data of the generated PDF
      final Uint8List pdfData = await doc.save();
      // --- END OF PDF CREATION ---

      // 5. Pass the VALID PDF data to the printing package
      final success = await Printing.layoutPdf(
        onLayout: (format) async => pdfData, // Use the new pdfData
      );
      
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        if (success) {
          Navigator.of(context).pushNamedAndRemoveUntil('/thank_you', (route) => false);
        }
      }
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop();
      print("Printing failed: $e");
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
            decoration: BoxDecoration( /* ... box decoration ... */ ),
            child: Column(
              children: [
                Text('Price: ₹150.00', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.print),
                    label: const Text('Pay at Counter & Print', style: TextStyle(color: Colors.white,)),
                    // Call our new direct print method
                    onPressed: _imageBytes == null ? null : () => _directPrintImage(context, _imageBytes!),
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