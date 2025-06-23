// lib/system_settings_page.dart
import 'package:flutter/material.dart';
import 'package:kiosk_app/widgets/common_app_bar.dart';
import 'package:kiosk_app/services/data_service.dart';

class SystemSettingsPage extends StatefulWidget {
  const SystemSettingsPage({Key? key}) : super(key: key);

  @override
  _SystemSettingsPageState createState() => _SystemSettingsPageState();
}

class _SystemSettingsPageState extends State<SystemSettingsPage> {
  // We can add state variables here later, e.g., for the timeout duration
  // double _inactivityTimeout = 90;
  
  final _dataService = DataService();

  void _showChangePinDialog() {
    final currentPinController = TextEditingController();
    final newPinController = TextEditingController();
    final confirmPinController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Change Admin PIN'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentPinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Current PIN',
                    labelStyle: TextStyle(fontSize: 18),
                    constraints: BoxConstraints(minWidth: 400),
                  ),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: newPinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'New PIN',
                    labelStyle: TextStyle(fontSize: 18),
                    constraints: BoxConstraints(minWidth: 400),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    if (value.length < 4) return 'PIN must be at least 4 digits';
                    return null;
                  },
                ),
                SizedBox(height: 7),
                TextFormField(
                  controller: confirmPinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm New PIN',
                    labelStyle: TextStyle(fontSize: 18),
                    constraints: BoxConstraints(minWidth: 400),
                  ),
                  validator: (value) {
                    if (value != newPinController.text) return 'PINs do not match';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  // Check if current PIN is correct
                  final savedPin = await _dataService.getAdminPin();
                  if (currentPinController.text != savedPin) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Current PIN is incorrect.'), backgroundColor: Colors.red),
                    );
                    return;
                  }

                  // Save the new PIN
                  await _dataService.saveAdminPin(newPinController.text);

                  if (mounted) {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('PIN updated successfully!'), backgroundColor: Colors.green),
                    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        context: context, 
        title: 'System Settings',
        showCartButton: false,
        showHomeButton: false,
      ),
      body: ListView(
        children: [
          // --- App Settings Section ---
          _buildSectionHeader('Application'),
          _buildSettingsTile(
            icon: Icons.color_lens,
            title: 'Appearance',
            subtitle: 'Change the app\'s primary color scheme.',
            onTap: () {
              // TODO: Open a color picker dialog
              print('Tapped Change Appearance');
            },
          ),
          _buildSettingsTile(
            icon: Icons.timer,
            title: 'Inactivity Timeout',
            subtitle: 'Set time before app resets to home screen (e.g., 90 seconds).',
            onTap: () {
              // TODO: Open a dialog with a slider or text input
              print('Tapped Inactivity Timeout');
            },
          ),
          
          const Divider(),

          // --- Security Section ---
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
            icon: Icons.wifi,
            title: 'Wi-Fi Settings',
            subtitle: 'View available networks and connect.',
            onTap: () {
              // TODO: Open a new page to list Wi-Fi networks
              print('Tapped Wi-Fi Settings');
            },
          ),
          _buildSettingsTile(
            icon: Icons.print,
            title: 'Printer Settings',
            subtitle: 'Manage the connected photo printer.',
            onTap: () {
              // TODO: Open printer management page
              print('Tapped Printer Settings');
            },
          ),

          const Divider(),

          // --- Maintenance Section ---
          _buildSectionHeader('Maintenance'),
          _buildSettingsTile(
            icon: Icons.delete_sweep,
            title: 'Clear Cache',
            subtitle: 'Clear all saved orders and product edits.',
            onTap: () {
              // TODO: Show a confirmation dialog before clearing
              print('Tapped Clear Cache');
            },
            isDestructive: true, // Make it red to indicate caution
          ),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'View application version and support info.',
            onTap: () {
              // TODO: Show an "About" dialog
              print('Tapped About');
            },
          ),
        ],
      ),
    );
  }

  // Helper widget to create consistent section headers
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  // Helper widget to create consistent settings tiles
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red.shade700 : Theme.of(context).textTheme.bodyLarge?.color;
    final iconColor = isDestructive ? Colors.red.shade700 : Colors.grey.shade700;

    return ListTile(
      leading: Icon(icon, color: iconColor, size: 32),
      title: Text(title, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
      onTap: onTap,
    );
  }


}