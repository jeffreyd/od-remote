import 'package:flutter/material.dart';
import '../models/radio_device.dart';
import '../services/radio_storage.dart';
import 'now_playing_screen.dart';

class RadioListScreen extends StatefulWidget {
  const RadioListScreen({super.key});

  @override
  State<RadioListScreen> createState() => _RadioListScreenState();
}

class _RadioListScreenState extends State<RadioListScreen> {
  final _storage = RadioStorageService();
  List<RadioDevice> _radios = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRadios();
  }

  Future<void> _loadRadios() async {
    final radios = await _storage.loadRadios();
    setState(() {
      _radios = radios;
      _loading = false;
    });
  }

  Future<void> _saveRadios() async {
    await _storage.saveRadios(_radios);
  }

  void _showRadioDialog({RadioDevice? existing}) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final hostController = TextEditingController(text: existing?.host ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Add Radio' : 'Edit Radio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: hostController,
              decoration: const InputDecoration(
                labelText: 'Host',
                hintText: '192.168.1.100',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              final host = hostController.text.trim();
              if (name.isEmpty || host.isEmpty) return;

              setState(() {
                if (existing != null) {
                  final idx = _radios.indexWhere((r) => r.id == existing.id);
                  if (idx >= 0) {
                    _radios[idx] = existing.copyWith(name: name, host: host);
                  }
                } else {
                  _radios.add(RadioDevice(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    host: host,
                  ));
                }
              });
              _saveRadios();
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteRadio(RadioDevice radio) {
    setState(() {
      _radios.removeWhere((r) => r.id == radio.id);
    });
    _saveRadios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OD Remote')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _radios.isEmpty
              ? const Center(child: Text('No radios added.\nTap + to add one.', textAlign: TextAlign.center))
              : ListView.builder(
                  itemCount: _radios.length,
                  itemBuilder: (ctx, i) {
                    final radio = _radios[i];
                    return ListTile(
                      title: Text(radio.name),
                      subtitle: Text(radio.host),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') _showRadioDialog(existing: radio);
                          if (value == 'delete') _deleteRadio(radio);
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          const PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NowPlayingScreen(radio: radio),
                          ),
                        );
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRadioDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
