import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../theme/zeno_colors.dart';

class BroadcastScreen extends StatefulWidget {
  const BroadcastScreen({super.key});

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  List<Map<String, dynamic>> _broadcasts = [];

  @override
  void initState() {
    super.initState();
    _loadBroadcasts();
  }

  Future<void> _loadBroadcasts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('broadcast_lists');
    if (data != null) {
      setState(() => _broadcasts = List<Map<String, dynamic>>.from(jsonDecode(data)));
    }
  }

  Future<void> _saveBroadcasts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('broadcast_lists', jsonEncode(_broadcasts));
  }

  void _createBroadcast() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Broadcast List'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter list name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _broadcasts.add({
                    'name': controller.text.trim(),
                    'contacts': <String>[],
                    'createdAt': DateTime.now().millisecondsSinceEpoch,
                  });
                });
                await _saveBroadcasts();
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _openBroadcast(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _BroadcastDetailScreen(
          broadcast: _broadcasts[index],
          onUpdate: (updated) {
            setState(() => _broadcasts[index] = updated);
            _saveBroadcasts();
          },
          onDelete: () {
            setState(() => _broadcasts.removeAt(index));
            _saveBroadcasts();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZenoColors.background,
      appBar: AppBar(
        title: const Text('Broadcast Lists'),
        backgroundColor: ZenoColors.primary,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ZenoColors.accent,
        onPressed: _createBroadcast,
        child: const Icon(Icons.add),
      ),
      body: _broadcasts.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.campaign_outlined, size: 80, color: ZenoColors.textHint),
                    const SizedBox(height: 16),
                    Text('No broadcast lists', style: TextStyle(color: ZenoColors.textSecondary, fontSize: 16)),
                    const SizedBox(height: 16),
                    Text(
                      'Broadcast lists allow you to send a message to multiple contacts at once.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: ZenoColors.textHint, fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _broadcasts.length,
              itemBuilder: (context, index) {
                final broadcast = _broadcasts[index];
                final contacts = List<String>.from(broadcast['contacts'] ?? []);
                return Card(
                  color: ZenoColors.surface,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: ZenoColors.primary,
                      child: const Icon(Icons.campaign_rounded, color: Colors.white),
                    ),
                    title: Text(broadcast['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text('${contacts.length} contacts'),
                    trailing: const Icon(Icons.chevron_right, color: ZenoColors.textHint),
                    onTap: () => _openBroadcast(index),
                  ),
                );
              },
            ),
    );
  }
}

class _BroadcastDetailScreen extends StatefulWidget {
  final Map<String, dynamic> broadcast;
  final ValueChanged<Map<String, dynamic>> onUpdate;
  final VoidCallback onDelete;

  const _BroadcastDetailScreen({
    required this.broadcast,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<_BroadcastDetailScreen> createState() => _BroadcastDetailScreenState();
}

class _BroadcastDetailScreenState extends State<_BroadcastDetailScreen> {
  late List<String> _contacts;

  @override
  void initState() {
    super.initState();
    _contacts = List<String>.from(widget.broadcast['contacts'] ?? []);
  }

  void _addContact() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Contact'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter user ID or phone',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty && !_contacts.contains(controller.text.trim())) {
                setState(() => _contacts.add(controller.text.trim()));
                widget.broadcast['contacts'] = List.from(_contacts);
                widget.onUpdate(widget.broadcast);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _removeContact(String uid) {
    setState(() => _contacts.remove(uid));
    widget.broadcast['contacts'] = List.from(_contacts);
    widget.onUpdate(widget.broadcast);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Broadcast List'),
        content: Text('Delete "${widget.broadcast['name']}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              widget.onDelete();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZenoColors.background,
      appBar: AppBar(
        title: Text(widget.broadcast['name'] ?? 'Broadcast'),
        backgroundColor: ZenoColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ZenoColors.accent,
        onPressed: _addContact,
        child: const Icon(Icons.person_add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Send a message to all ${_contacts.length} recipients at once. Replies come to you individually.',
              style: TextStyle(color: ZenoColors.textSecondary, fontSize: 13),
            ),
          ),
          if (_contacts.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 64, color: ZenoColors.textHint),
                    const SizedBox(height: 12),
                    Text('No contacts added yet', style: TextStyle(color: ZenoColors.textSecondary)),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _contacts.length,
                itemBuilder: (_, i) => Card(
                  color: ZenoColors.surface,
                  margin: const EdgeInsets.only(bottom: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: ZenoColors.primary.withOpacity(0.8),
                      child: Text(
                        _contacts[i].isNotEmpty ? _contacts[i][0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(_contacts[i], style: const TextStyle(fontSize: 14)),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                      onPressed: () => _removeContact(_contacts[i]),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
