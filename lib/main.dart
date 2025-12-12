import 'package:flutter/material.dart';
import 'package:lan_sharing/lan_sharing.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LeeShare',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'LeeShare - WiFi File Sharing'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  LanServer? _server;
  LanClient? _client;
  String _status = 'Ready';
  List<String> _devices = [];
  String _selectedDevice = '';
  String _deviceName = 'Unknown';
  final TextEditingController _nameController = TextEditingController();
  bool _isEditingName = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _loadDeviceName();
  }

  Future<void> _loadDeviceName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _deviceName = prefs.getString('device_name') ?? 'My Device';
    });
  }

  Future<void> _saveDeviceName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('device_name', name);
    setState(() {
      _deviceName = name;
      _isEditingName = false;
    });
  }

  Future<void> _requestPermissions() async {
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
    await Permission.nearbyWifiDevices.request();
  }

  Future<void> _startServer() async {
    try {
      _server = LanServer()..start();
      setState(() {
        _status = 'Server started as "$_deviceName"';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to start server: $e';
      });
    }
  }

  Future<void> _discoverDevices() async {
    if (_client == null) {
      _client = LanClient(
        onData: (data) {
          // Handle incoming data
        },
      );
    }
    try {
      await _client!.findServer();
      // Simulate discovered devices for now
      setState(() {
        _devices = ['Laptop-01', 'Phone-02', 'Tablet-03'];
        _status = 'Found ${_devices.length} devices';
      });
    } catch (e) {
      setState(() {
        _status = 'Discovery failed: $e';
      });
    }
  }

  Future<void> _sendFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      // Implement file sending logic using lan_sharing
      setState(() {
        _status = 'Ready to send: ${result.files.single.name} to $_selectedDevice';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.devices, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Device Name: $_deviceName',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_isEditingName)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                hintText: 'Enter device name',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _saveDeviceName(_nameController.text.trim()),
                            child: const Text('Save'),
                          ),
                        ],
                      )
                    else
                      ElevatedButton(
                        onPressed: () {
                          _nameController.text = _deviceName;
                          setState(() => _isEditingName = true);
                        },
                        child: const Text('Change Device Name'),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Network Status',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(_status),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _startServer,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start Server'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _discoverDevices,
                          icon: const Icon(Icons.search),
                          label: const Text('Discover Devices'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _sendFile,
                          icon: const Icon(Icons.attach_file),
                          label: const Text('Send File'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_devices.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.devices_other, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Discovered Devices (${_devices.length})',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._devices.map((device) => ListTile(
                        leading: const Icon(Icons.computer),
                        title: Text(device),
                        subtitle: Text('Tap to select for file transfer'),
                        tileColor: _selectedDevice == device
                            ? Colors.deepPurple.withOpacity(0.1)
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedDevice = device;
                          });
                        },
                      )).toList(),
                      if (_selectedDevice.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Text(
                            'Selected: $_selectedDevice',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How to use',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text('1. Set your device name above.'),
                    const Text('2. Start a server to allow others to connect.'),
                    const Text('3. Discover devices on the same WiFi network.'),
                    const Text('4. Select a device and send a file.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
