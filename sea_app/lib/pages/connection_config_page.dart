import 'package:flutter/material.dart';
import 'package:sea_app/services/api_service.dart';
import 'page_choice_user.dart';

class ConnectionConfigPage extends StatefulWidget {
  final VoidCallback onConfigured;
  const ConnectionConfigPage({super.key, required this.onConfigured});

  @override
  State<ConnectionConfigPage> createState() => _ConnectionConfigPageState();
}

class _ConnectionConfigPageState extends State<ConnectionConfigPage> {
  final _hostCtrl = TextEditingController(text: ApiService.host);
  final _portCtrl = TextEditingController(text: ApiService.port);
  bool _checking = false;
  bool? _ok;
  String? _message;
  bool _noPort = ApiService.port.isEmpty;
  String _scheme = ApiService.scheme;

  Future<void> _check() async {
    setState(() { _checking = true; _ok = null; _message = null; });
  final effectivePort = _noPort ? '' : _portCtrl.text;
  await ApiService.setConfig(host: _hostCtrl.text, port: effectivePort, scheme: _scheme);
    final ok = await ApiService.checkConnection();
    setState(() { _checking = false; _ok = ok; _message = ok ? 'Connected' : 'Failed to connect'; });
  }

  Future<void> _saveAndContinue() async {
    final effectivePort = _noPort ? '' : _portCtrl.text;
    await ApiService.setConfig(host: _hostCtrl.text, port: effectivePort, scheme: _scheme);
    if (!mounted) return;
    // Navigate directly to role selection page after saving
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ChoiceUserPage()),
    );
  }

  void _quitWithoutSaving() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ChoiceUserPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configure Backend Connection')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Enter backend host and port. Example: 127.0.0.1 and 8000'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    DropdownButton<String>(
                      value: _scheme,
                      onChanged: (val) {
                        if (val == null) return;
                        setState(() { _scheme = val; });
                      },
                      items: const [
                        DropdownMenuItem(value: 'http', child: Text('http')),
                        DropdownMenuItem(value: 'https', child: Text('https')),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _hostCtrl,
                        decoration: const InputDecoration(labelText: 'Host', hintText: 'e.g., 127.0.0.1'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Don\'t use port (default HTTP)'),
                  value: _noPort,
                  onChanged: (v) {
                    setState(() {
                      _noPort = v ?? false;
                      if (_noPort) _portCtrl.text = '';
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: _portCtrl,
                  enabled: !_noPort,
                  decoration: const InputDecoration(labelText: 'Port (leave empty if unchecked)', hintText: 'e.g., 8000'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _checking ? null : _check,
                      icon: const Icon(Icons.wifi_tethering),
                      label: Text(_checking ? 'Checking...' : 'Check Connection'),
                    ),
                    const SizedBox(width: 12),
                    if (_ok != null)
                      Icon(_ok! ? Icons.check_circle : Icons.error, color: _ok! ? Colors.green : Colors.red),
                    if (_message != null) ...[
                      const SizedBox(width: 8),
                      Text(_message!),
                    ]
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: _saveAndContinue,
                        child: const Text('Save & Continue'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: _quitWithoutSaving,
                      child: const Text('Quit'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
