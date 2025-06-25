// lib/printer_settings_page.dart
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:kiosk_app/services/data_service.dart';
import 'package:kiosk_app/widgets/common_app_bar.dart';

class PrinterSettingsPage extends StatefulWidget {
  const PrinterSettingsPage({Key? key}) : super(key: key);

  @override
  _PrinterSettingsPageState createState() => _PrinterSettingsPageState();
}

class _PrinterSettingsPageState extends State<PrinterSettingsPage> {
  final DataService _dataService = DataService();
  
  // This will hold the list of printers found on the system
  late Future<List<Printer>> _printersFuture;
  // This will hold the name of the printer we've saved in our app
  String? _selectedPrinterName;

  @override
  void initState() {
    super.initState();
    _loadPrinters();
    _loadSelectedPrinter();
  }

  // Get the list of all printers from the OS
  void _loadPrinters() {
    setState(() {
      _printersFuture = Printing.listPrinters();
    });
  }

  // Get the name of the printer we've chosen to use for our app
  Future<void> _loadSelectedPrinter() async {
    final name = await _dataService.getPrinterName();
    if (mounted) {
      setState(() {
        _selectedPrinterName = name;
      });
    }
  }

  // Save the selected printer and update the UI
  Future<void> _selectPrinter(Printer printer) async {
    await _dataService.savePrinterName(printer.name);
    _loadSelectedPrinter(); // Refresh the state to show the new selection
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(context: context, title: 'Select Kiosk Printer'),
      body: FutureBuilder<List<Printer>>(
        future: _printersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading printers: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No printers found on this device.\nPlease ensure printers are configured in the operating system.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final printers = snapshot.data!;
          return ListView.builder(
            itemCount: printers.length,
            itemBuilder: (context, index) {
              final printer = printers[index];
              final bool isSelected = printer.name == _selectedPrinterName;

              return Card(
                color: isSelected ? Colors.green.shade50 : null,
                child: ListTile(
                  leading: const Icon(Icons.print),
                  title: Text(printer.name, style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(printer.isDefault ? 'System Default' : 'URL: ${printer.url}'),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  onTap: () => _selectPrinter(printer),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadPrinters,
        tooltip: 'Refresh Printer List',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}