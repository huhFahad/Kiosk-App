// lib/system_settings_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:kiosk_app/theme/theme_notifier.dart';
import 'package:kiosk_app/notifiers/settings_notifier.dart'; 
import 'package:kiosk_app/widgets/common_app_bar.dart';
import 'package:kiosk_app/services/data_service.dart';
import 'package:kiosk_app/models/cart_model.dart';
import 'package:kiosk_app/admin_map_picker_page.dart';

class SystemSettingsPage extends StatefulWidget {
  const SystemSettingsPage({Key? key}) : super(key: key);

  @override
  _SystemSettingsPageState createState() => _SystemSettingsPageState();
}

class _SystemSettingsPageState extends State<SystemSettingsPage> {
  final _dataService = DataService();
  String? _currentScreensaverPath;
  String? _currentStoreMapPath;
  String? _currentPrinterName;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  Future<void> _loadCurrentSettings() async {
    final path = await _dataService.getScreensaverImagePath();
    final mapPath = await _dataService.getStoreMapPath(); 
    final printerName = await _dataService.getPrinterName(); 
    if (mounted) {
      setState(() {
        _currentScreensaverPath = path;
        _currentStoreMapPath = mapPath;
        _currentPrinterName = printerName;
      });
    }
  }

  

  // --- DIALOG AND ACTION METHODS ---

  void _showChangeTimeoutDialog(SettingsNotifier notifier) {
    final controller = TextEditingController(text: notifier.timeoutDurationSeconds.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Inactivity Timeout'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Seconds until screensaver appears'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newTimeout = int.tryParse(controller.text);
              if (newTimeout != null && newTimeout >= 10) {
                // Call the notifier to update the setting globally
                await notifier.updateTimeoutDuration(newTimeout);
                if (mounted) Navigator.of(context).pop();
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _changeScreensaverImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    
    final newPath = await _dataService.saveImage(File(file.path));
    await _dataService.saveScreensaverImagePath(newPath);
    _loadCurrentSettings(); // Refresh just the local state for the image preview
  }

  Future<void> _removeScreensaverImage() async {
    await _dataService.saveScreensaverImagePath('');
    _loadCurrentSettings();
  }

  Future<void> _changeStoreMap() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    
    // Use the saveImage service we already built to copy it to a safe place
    final newPath = await _dataService.saveImage(File(file.path));
    // Save the new path using our new service method
    await _dataService.saveStoreMapPath(newPath);
    // Refresh the UI to show the new map preview
    _loadCurrentSettings();
  }

  Future<void> _removeStoreMap() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove Custom Map?'),
        content: Text('This will revert the app to using the default placeholder map. Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _dataService.removeStoreMapPath();
      // Refresh the UI to show that the custom map is gone
      _loadCurrentSettings();
    }
  }

  void _showColorPickerDialog() {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    Color currentColor = themeNotifier.currentTheme.primaryColor;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Primary Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (color) => currentColor = color,
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                themeNotifier.updateThemeColor(currentColor);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showChangePinDialog() {
    final formKey = GlobalKey<FormState>();
    final currentPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('CHANGE ADMIN PIN', style: TextStyle(fontWeight: FontWeight.bold),),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentPinController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Current PIN',  constraints: BoxConstraints(minWidth: 400)),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: newPinController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'New PIN'),
                  validator: (v) => (v?.length ?? 0) < 4 ? 'Min 4 digits' : null,
                ),
                SizedBox(height: 7),
                TextFormField(
                  controller: confirmPinController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Confirm New PIN'),
                  validator: (v) => v != newPinController.text ? 'PINs do not match' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final savedPin = await _dataService.getAdminPin();
                  if (currentPinController.text != savedPin) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Current PIN is incorrect.'), backgroundColor: Colors.red));
                    return;
                  }
                  await _dataService.saveAdminPin(newPinController.text);
                  if (mounted) {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PIN updated successfully!'), backgroundColor: Colors.green));
                  }
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _setKioskLocation() async {
    final result = await Navigator.push<Map<String, double>>(
      context,
      MaterialPageRoute(builder: (ctx) => const AdminMapPickerPage()),
    );
    
    // When it returns, we save the coordinates using our new DataService method.
    if (result != null && result.containsKey('x') && result.containsKey('y')) {
      await _dataService.saveKioskLocation(result['x']!, result['y']!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kiosk location saved!'), backgroundColor: Colors.green),
      );
    }
  }

  void _showClearCacheDialog() async {
    // --- First Confirmation Dialog ---
    final bool? didConfirmFirst = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('⚠️ Are you absolutely sure?'),
        content: Text('This will delete all saved orders, and revert any changes made to products, categories, frames, and templates. This action cannot be undone.', softWrap: true,),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Yes, I Understand', style: TextStyle(color: Colors.white,)),
          ),
        ],
      ),
    );

    // If user cancelled the first dialog, do nothing.
    if (didConfirmFirst != true) return;

    // --- Second Confirmation Dialog (PIN Entry) ---
    final pinController = TextEditingController();
    final bool? didConfirmWithPin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Final Confirmation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('To proceed, please enter the Admin PIN.'),
            SizedBox(height: 16),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              autofocus: true,
              decoration: InputDecoration(labelText: 'Admin PIN'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final savedPin = await _dataService.getAdminPin();
              if (pinController.text == savedPin) {
                Navigator.of(ctx).pop(true); // PIN is correct
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Incorrect PIN.'), backgroundColor: Colors.red),
                );
                Navigator.of(ctx).pop(false); // PIN is incorrect
              }
            },
            child: Text('Confirm & Delete'),
          ),
        ],
      ),
    );

    // If user entered correct PIN, proceed with deletion.
    if (didConfirmWithPin == true) {
      await _dataService.clearCache();
      if (mounted) {
        Provider.of<CartModel>(context, listen: false).clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cache cleared. App will now restart.'), backgroundColor: Colors.green),
        );
        await Future.delayed(const Duration(seconds: 2));
        Phoenix.rebirth(context);
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/', // Navigate to the Home page
          (Route<dynamic> route) => false, // This predicate always returns false
        );
      }
    }
  }

  void _showAboutDialog() async {
    final packageInfo = await PackageInfo.fromPlatform();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: Theme.of(context).primaryColorLight, 
                width: 30.0, 
              ),
            ),
            padding: const EdgeInsets.all(24.0), 
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  ('assets/icons/cent_transparent_logo.png'),
                  width: 64,
                  height: 64,
                  // color: Colors.black,
                ),
                const SizedBox(height: 16),
                Text(
                  'Retail Kiosk App',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text('Version: ${packageInfo.version}'),
                const SizedBox(height: 24),
                const Text(
                  'This application is the property of Centelon IT Solutions LLP.\nFor support, please contact the system administrator.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '© ${DateTime.now().year} Centelon IT Solutions LLP\nAuthor: fahad.kareem@centelon.com',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    SizedBox(
                      width: 100,
                      height: 50,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('CLOSE', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );

      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // We use Consumer here to listen to global setting changes
    return Consumer<SettingsNotifier>(
      builder: (context, settingsNotifier, child) {
        return Scaffold(
          appBar: CommonAppBar(context: context, title: 'System Settings', showCartButton: false, showHomeButton: false),
          body: ListView(
            children: [
              _buildSectionHeader('Application'),
              SwitchListTile(
                title: Text('Enable Screensaver'),
                subtitle: Text('Automatically show a screensaver when idle.'),
                value: settingsNotifier.isScreensaverEnabled,
                onChanged: (bool value) {
                  settingsNotifier.updateScreensaverEnabled(value);
                },
                secondary: Icon(Icons.slideshow),
              ),
              if (settingsNotifier.isScreensaverEnabled) ...[
                // const Divider(),
                _buildSettingsTile(
                  icon: Icons.image,
                  title: 'Change Screensaver Image',
                  subtitle: _currentScreensaverPath == null || _currentScreensaverPath!.isEmpty 
                      ? 'Using default screensaver.' 
                      : 'Using custom image.',
                  onTap: _changeScreensaverImage,
                  trailing: _buildScreensaverPreview(),
                ),
                _buildSettingsTile(
                  icon: Icons.timer,
                  title: 'Inactivity Timeout',
                  subtitle: 'Currently: ${settingsNotifier.timeoutDurationSeconds} seconds',
                  onTap: () => _showChangeTimeoutDialog(settingsNotifier),
                ),
              ],
              _buildSettingsTile(
                icon: Icons.color_lens,
                title: 'Appearance',
                subtitle: "Change the app's primary color scheme.",
                onTap: _showColorPickerDialog,
                trailing: Container(
                  width: 64,
                  // height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey),
                  ),
                ),
              ),
              const Divider(),
              _buildSectionHeader('Security'),
              _buildSettingsTile(
                icon: Icons.pin,
                title: 'Change Admin PIN',
                subtitle: 'Update the PIN used to access the admin dashboard.',
                onTap: _showChangePinDialog,
              ),

              const Divider(),

              // --- Device Section ---
              _buildSectionHeader('Device'),
              _buildSettingsTile(
                icon: Icons.map,
                title: 'Upload Store Map',
                subtitle: _currentStoreMapPath != null && _currentStoreMapPath!.isNotEmpty
                  ? 'A custom map is set.'
                  : 'Using the default map.',
                onTap: _changeStoreMap,
                trailing: _buildMapPreview(),
              ),
              _buildSettingsTile(
                icon: Icons.my_location,
                title: 'Set Kiosk Location',
                subtitle: 'Set the "You Are Here" pin on the store map.',
                onTap: _setKioskLocation,
              ),
              _buildSettingsTile(
                icon: Icons.wifi,
                title: 'Wi-Fi Settings',
                subtitle: 'View available networks and connect.',
                onTap: () {
                  Navigator.pushNamed(context, '/admin/wifi');
                },
              ),
              _buildSettingsTile(
                icon: Icons.print,
                title: 'Printer Settings',
                subtitle: 'Current Printer: ${_currentPrinterName ?? 'System Default'}',
                onTap: () {
                  // Navigate and then refresh the settings when we come back
                  Navigator.pushNamed(context, '/admin/printers').then((_) {
                    _loadCurrentSettings();
                  });
                },
              ),

              const Divider(),

              // --- Maintenance Section ---
              _buildSectionHeader('Maintenance'),
              _buildSettingsTile(
                icon: Icons.delete_sweep,
                title: 'Clear Data',
                subtitle: 'Clear all saved orders and product edits.',
                onTap: _showClearCacheDialog,
                isDestructive: true, // Make it red to indicate caution
              ),
              _buildSettingsTile(
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'View application version and support info.',
                onTap: _showAboutDialog,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    bool isDestructive = false,
  }) {
    final destructiveColor = Colors.red.shade700;
    return ListTile(
      leading: Icon(icon, color: isDestructive ? destructiveColor : null),
      title: Text(title, style: TextStyle(color: isDestructive ? destructiveColor : null)),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildScreensaverPreview() {
    if (_currentScreensaverPath == null || _currentScreensaverPath!.isEmpty) {
      return const Icon(Icons.no_photography);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 100, height: 100, child: Image.file(File(_currentScreensaverPath!))),
        IconButton(
          icon: Icon(Icons.delete_forever, color: Colors.red.shade400),
          onPressed: _removeScreensaverImage,
          tooltip: 'Remove custom image',
        )
      ],
    );
  }

  Widget _buildMapPreview() {
    // If there's no custom map, just show a button to add one.
    if (_currentStoreMapPath == null || _currentStoreMapPath!.isEmpty) {
      return ElevatedButton(
        onPressed: _changeStoreMap,
        child: Text('Upload', style: TextStyle(fontSize: 20),),
      );
    }
    
    // If there is a custom map, show the preview and a delete button.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: Image.file(File(_currentStoreMapPath!), fit: BoxFit.cover),
        ),
        IconButton(
          icon: Icon(Icons.delete_forever, color: Colors.red.shade400),
          onPressed: _removeStoreMap,
          tooltip: 'Remove Custom Map',
        )
      ],
    );
  }

}