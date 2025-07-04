// lib/wifi_settings_page.dart
import 'package:flutter/material.dart';
import 'package:kiosk_app/services/data_service.dart';
import 'package:process_run/shell.dart';
import 'package:kiosk_app/widgets/common_app_bar.dart';

class WifiInfo {
  final String ssid;
  final String signal;
  final bool inUse;
  WifiInfo({required this.ssid, required this.signal, this.inUse = false});
}

class WifiSettingsPage extends StatefulWidget {
  const WifiSettingsPage({Key? key}) : super(key: key);

  @override
  _WifiSettingsPageState createState() => _WifiSettingsPageState();
}

class _WifiSettingsPageState extends State<WifiSettingsPage> {
  final DataService _dataService = DataService();
  List<WifiInfo> _scannedNetworks = [];
  bool _isScanning = false;
  String _statusMessage = 'Tap "Refresh" to find networks.';

  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _networkKeys = {};

  @override
  void initState() {
    super.initState();
    _scanForNetworks(scrollToConnected: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Icon getWifiIcon(String signalStrength) {
    final strength = int.tryParse(signalStrength) ?? 0;
    if (strength >= 85) return const Icon(Icons.signal_wifi_4_bar , color: Color.fromARGB(255, 15, 255, 23));
    if (strength >= 50) return const Icon(Icons.network_wifi_3_bar , color: Color.fromARGB(255, 222, 238, 0));
    if (strength >= 20) return const Icon(Icons.network_wifi_2_bar, color: Color.fromARGB(255, 255, 170, 0));
    if (strength >= 1) return const Icon(Icons.network_wifi_1_bar, color: Colors.red);
    return const Icon(Icons.signal_wifi_off, color: Colors.grey);
  }

  Future<String?> _getConnectedSSID() async {
    try {
      var shell = Shell();
      var result = await shell.run("nmcli -t -f active,ssid dev wifi");
      for (var line in result.first.stdout.toString().trim().split('\n')) {
        final parts = line.split(':');
        if (parts.length >= 2 && parts[0] == 'yes') {
          return parts[1].trim();
        }
      }
    } catch (e) {
      print("Failed to get connected SSID: $e");
    }
    return null;
  }

  Future<void> _scanForNetworks({bool scrollToConnected = false}) async {
    setState(() {
      _isScanning = true;
      _statusMessage = 'Scanning...';
    });

    try {
      final connectedSSID = await _getConnectedSSID();

      var shell = Shell();
      var result = await shell.run('nmcli -t -f SSID,SIGNAL device wifi list');
      final output = result.first.stdout.toString();
      final lines = output.trim().split('\n');

      final List<WifiInfo> networks = [];
      for (final line in lines) {
        final parts = line.split(':');
        if (parts.length >= 2) {
          final ssid = parts[0].replaceAll('\\:', ':').trim();
          if (ssid.isEmpty) continue;
          final isConnected = (connectedSSID != null && ssid == connectedSSID);
          networks.add(WifiInfo(ssid: ssid, signal: parts[1], inUse: isConnected));
        }
      }

      final uniqueNetworks = <String, WifiInfo>{};
      for (final network in networks) {
        if (!uniqueNetworks.containsKey(network.ssid) ||
            int.parse(network.signal) > int.parse(uniqueNetworks[network.ssid]!.signal)) {
          uniqueNetworks[network.ssid] = network;
        }
      }

      var sortedNetworks = uniqueNetworks.values.toList();
      sortedNetworks.sort((a, b) {
        if (a.inUse) return -1;
        if (b.inUse) return 1;
        return int.parse(b.signal).compareTo(int.parse(a.signal));
      });

      _networkKeys.clear();
      for (var network in sortedNetworks) {
        _networkKeys[network.ssid] = GlobalKey();
      }

      setState(() {
        _scannedNetworks = sortedNetworks;
        _statusMessage = _scannedNetworks.isEmpty ? 'No networks found.' : 'Scan complete.';
      });

      if (scrollToConnected) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final connectedNetwork = _scannedNetworks.where((n) => n.inUse).firstOrNull;
          if (connectedNetwork != null) {
            final key = _networkKeys[connectedNetwork.ssid];
            final context = key?.currentContext;
            if (context != null) {
              Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 500));
            }
          }
        });
      }

    } catch (e) {
      print("Error while scanning networks: $e");
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  Future<void> _disconnectNetwork(String ssid) async {
    try {
      var shell = Shell();
      await shell.run('nmcli connection down "$ssid"');
    } catch (e) {
      print("Error disconnecting from $ssid: $e");
    } finally {
      _scanForNetworks(scrollToConnected: true);
    }
  }

  Future<void> _forgetNetwork(WifiInfo network) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Forget Network?'),
        content: Text('Do you want to disconnect from and forget "${network.ssid}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Forget', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      var shell = Shell();
      await shell.run('nmcli connection delete "${network.ssid}"');
      await _dataService.forgetWifiPassword(network.ssid);
    } catch (e) {
      print('Could not forget network ${network.ssid}: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to forget ${network.ssid}.'), backgroundColor: Colors.red),
      );
    } finally {
      _scanForNetworks(scrollToConnected: true);
    }
  }

  void _tryToConnect(WifiInfo network) async {
    final savedPassword = await _dataService.getWifiPassword(network.ssid);

    if (savedPassword != null) {
      _connectToNetwork(network.ssid, savedPassword, savePassword: false);
    } else {
      _showPasswordDialog(network);
    }
  }

  void _showPasswordDialog(WifiInfo network) {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Connect to "${network.ssid}"'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _connectToNetwork(network.ssid, passwordController.text, savePassword: true);
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  Future<void> _connectToNetwork(String ssid, String password, {required bool savePassword}) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const PopScope(
        canPop: false,
        child: Dialog(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              CircularProgressIndicator(),
              SizedBox(width: 24),
              Text('Connecting...'),
            ]),
          ),
        ),
      ),
    );

    bool success = false;
    try {
      var shell = Shell();
      var result = await shell.runExecutableArguments(
        'nmcli', ['device', 'wifi', 'connect', ssid, 'password', password]
      );

      if (result.exitCode == 0) {
        success = true;
        if (savePassword) {
          await _dataService.saveWifiPassword(ssid, password);
        }
        await Future.delayed(const Duration(seconds: 5));
      }
    } catch (e) {
      print("Error connecting with nmcli: $e");
    } finally {
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Connection successful!' : 'Connection failed. Please check password.'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }

      _scanForNetworks(scrollToConnected: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentNetwork = _scannedNetworks.where((n) => n.inUse).firstOrNull;

    return Scaffold(
      appBar: CommonAppBar(context: context, title: 'Wi-Fi Settings', showCartButton: false, showHomeButton: false),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Current Status', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    if (currentNetwork != null)
                      Text('Connected to: ${currentNetwork.ssid}', style: TextStyle(color: Colors.green.shade800, fontSize: 18, fontWeight: FontWeight.bold))
                    else
                      const Text('Not Connected', style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              icon: _isScanning
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                  : const Icon(Icons.refresh, size: 35),
              label: Text(_isScanning ? 'Please Wait...' : 'Refresh'),
              onPressed: _isScanning ? null : () => _scanForNetworks(scrollToConnected: true),
            ),
          ),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('AVAILABLE NETWORKS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _scannedNetworks.isEmpty
                ? Center(child: Text(_statusMessage))
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _scannedNetworks.length,
                    itemBuilder: (context, index) {
                      final network = _scannedNetworks[index];
                      return Card(
                        key: _networkKeys[network.ssid],
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        color: network.inUse ? Colors.green.shade50 : null,
                        child: ListTile(
                          leading: getWifiIcon(network.signal),
                          title: Row(
                            children: [
                              Text(network.ssid),
                              const SizedBox(width: 8),
                              if (network.inUse)
                                Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.green, size: 18),
                                    const SizedBox(width: 4),
                                    Text('Connected', style: TextStyle(color: Colors.green.withOpacity(0.8), fontSize: 18)),
                                  ],
                                ),
                            ],
                          ),
                          subtitle: Text('Signal: ${network.signal}%'),
                          onTap: network.inUse ? null : () => _tryToConnect(network),
                          trailing: network.inUse
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton(
                                      onPressed: () => _disconnectNetwork(network.ssid),
                                      child: Text('DISCONNECT', style: TextStyle(color: Colors.black, fontSize: 20)),
                                    ),
                                    TextButton(
                                      onPressed: () => _forgetNetwork(network),
                                      child: Text('FORGET', style: TextStyle(color: Colors.red, fontSize: 20)),
                                    ),
                                  ],
                                )
                              : const Icon(Icons.keyboard_arrow_right),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
