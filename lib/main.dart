import 'package:flutter/material.dart';
import 'package:lan_sharing/lan_sharing.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

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

  @override
  void initState() {
    super.initState();
    _requestPermissions();
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
        _status = 'Server started';
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
      setState(() {
        _devices = ['Device 1', 'Device 2']; // Placeholder
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
        _status = 'File selected: ${result.files.single.name}';
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(_status),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startServer,
              child: const Text('Start Server'),
            ),
            ElevatedButton(
              onPressed: _discoverDevices,
              child: const Text('Discover Devices'),
            ),
            ElevatedButton(
              onPressed: _sendFile,
              child: const Text('Send File'),
            ),
            if (_devices.isNotEmpty)
              Column(
                children: _devices.map((device) => ListTile(
                  title: Text(device),
                  onTap: () {
                    setState(() {
                      _selectedDevice = device;
                    });
                  },
                )).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
