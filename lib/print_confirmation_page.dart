// lib/print_confirmation_page.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:kiosk_app/services/data_service.dart';
import 'package:kiosk_app/widgets/common_app_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:process_run/shell.dart';

class PrintConfirmationPage extends StatefulWidget {
  const PrintConfirmationPage({Key? key}) : super(key: key);

  @override
  State<PrintConfirmationPage> createState() => _PrintConfirmationPageState();
}

class _PrintConfirmationPageState extends State<PrintConfirmationPage> {
  final DataService _dataService = DataService();
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
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    bool success = false;
    String errorMessage = 'An unknown error occurred.';

    try {
      // 1. Get the saved printer name
      final String? printerName = await _dataService.getPrinterName();
      if (printerName == null || printerName.isEmpty) {
        throw Exception('No printer configured in settings.');
      }
      
      // --- STEP 2: GENERATE A PDF IN MEMORY ---
      // This uses the printing package's strength without showing a dialog.
      final doc = pw.Document();
      final image = pw.MemoryImage(imageBytes);
      
      doc.addPage(pw.Page(
        // We can control page orientation and format here if needed
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(image),
          );
        },
      ));
      
      // This gives us the raw bytes of the generated PDF file
      final Uint8List pdfBytes = await doc.save();

      // --- STEP 3: SAVE THE PDF TO A TEMPORARY FILE ---
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/to_print.pdf'); // Save as .pdf
      await tempFile.writeAsBytes(pdfBytes);

      // --- STEP 4: SEND THE PDF FILE TO THE PRINTER USING LP ---
      var shell = Shell();
      var result = await shell.run('lp -d "$printerName" "${tempFile.path}"');

      if (result.first.exitCode == 0) {
        success = true;
      } else {
        errorMessage = result.first.stderr as String;
      }

      // 5. Clean up the temporary file
      await tempFile.delete();

    } catch (e) {
      errorMessage = e.toString();
      print("Printing failed: $e");
    } finally {
      if (mounted) Navigator.of(context).pop();

      if (success) {
        if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/thank_you', (route) => false);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Printing Failed: $errorMessage'), backgroundColor: Colors.red),
          );
        }
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