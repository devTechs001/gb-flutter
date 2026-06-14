import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/zeno_colors.dart';

class AutoReplyRule {
  String trigger;
  String reply;
  bool active;

  AutoReplyRule({
    required this.trigger,
    required this.reply,
    this.active = true,
  });
}

class AutoReplyScreen extends StatefulWidget {
  const AutoReplyScreen({super.key});

  @override
  State<AutoReplyScreen> createState() => _AutoReplyScreenState();
}

class _AutoReplyScreenState extends State<AutoReplyScreen> {
  final List<AutoReplyRule> _rules = [];
  bool _masterEnabled = true;

  void _showNewRuleDialog() {
    final triggerCtrl = TextEditingController();
    final replyCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ZenoColors.surface,
        title: const Text('New Rule',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: triggerCtrl,
              decoration: const InputDecoration(
                labelText: 'Trigger word',
                prefixIcon: Icon(Icons.keyboard),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: replyCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reply message',
                prefixIcon: Icon(Icons.message),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: ZenoColors.primary),
            onPressed: () {
              if (triggerCtrl.text.isNotEmpty &&
                  replyCtrl.text.isNotEmpty) {
                setState(() {
                  _rules.add(AutoReplyRule(
                    trigger: triggerCtrl.text,
                    reply: replyCtrl.text,
                  ));
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditRuleDialog(int index) {
    final rule = _rules[index];
    final triggerCtrl = TextEditingController(text: rule.trigger);
    final replyCtrl = TextEditingController(text: rule.reply);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ZenoColors.surface,
        title: const Text('Edit Rule',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: triggerCtrl,
              decoration: const InputDecoration(
                labelText: 'Trigger word',
                prefixIcon: Icon(Icons.keyboard),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: replyCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reply message',
                prefixIcon: Icon(Icons.message),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: ZenoColors.primary),
            onPressed: () {
              setState(() {
                rule.trigger = triggerCtrl.text;
                rule.reply = replyCtrl.text;
              });
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
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
        title: const Text('Auto Reply'),
        backgroundColor: ZenoColors.primary,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ZenoColors.accent,
        onPressed: _showNewRuleDialog,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Enable Auto Reply',
                style: TextStyle(color: Colors.white)),
            subtitle: const Text('Automatically reply to messages',
                style: TextStyle(color: Colors.white70)),
            value: _masterEnabled,
            onChanged: (v) => setState(() => _masterEnabled = v),
            activeColor: ZenoColors.accent,
          ),
          const Divider(color: Colors.white12),
          Expanded(
            child: _rules.isEmpty
                ? const Center(
                    child: Text('No auto-reply rules',
                        style: TextStyle(
                            color: Colors.white54, fontSize: 16)),
                  )
                : ListView.builder(
                    itemCount: _rules.length,
                    itemBuilder: (context, index) {
                      final rule = _rules[index];
                      return Card(
                        color: ZenoColors.surface,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: ListTile(
                          title: Text(rule.trigger,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          subtitle: Text(rule.reply,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white70)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: rule.active,
                                onChanged: _masterEnabled
                                    ? (v) =>
                                        setState(() => rule.active = v)
                                    : null,
                                activeColor: ZenoColors.accent,
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.white54),
                                onPressed: () =>
                                    _showEditRuleDialog(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () =>
                                    setState(() => _rules.removeAt(index)),
                              ),
                            ],
                          ),
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
