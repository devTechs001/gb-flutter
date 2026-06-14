import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import '../../theme/zeno_colors.dart';
import '../../services/preferences_service.dart';

class ScheduledMessage {
  final String id;
  final String recipient;
  final String message;
  final DateTime scheduledAt;
  final String repeat;
  String status;

  ScheduledMessage({
    required this.id,
    required this.recipient,
    required this.message,
    required this.scheduledAt,
    this.repeat = 'None',
    this.status = 'pending',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'recipient': recipient,
    'message': message,
    'scheduledAt': scheduledAt.toIso8601String(),
    'repeat': repeat,
    'status': status,
  };

  factory ScheduledMessage.fromJson(Map<String, dynamic> json) =>
      ScheduledMessage(
        id: json['id'],
        recipient: json['recipient'],
        message: json['message'],
        scheduledAt: DateTime.parse(json['scheduledAt']),
        repeat: json['repeat'] ?? 'None',
        status: json['status'] ?? 'pending',
      );
}

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final List<ScheduledMessage> _messages = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final raw = await PreferencesService.getScheduledMessages();
    setState(() {
      _messages.clear();
      for (final jsonStr in raw) {
        try {
          _messages.add(ScheduledMessage.fromJson(jsonDecode(jsonStr)));
        } catch (_) {}
      }
      _checkPending();
    });
  }

  void _checkPending() {
    for (final msg in _messages) {
      if (msg.status == 'pending' && DateTime.now().isAfter(msg.scheduledAt)) {
        msg.status = 'sent';
        _saveAll();
      }
    }
  }

  Future<void> _saveAll() async {
    for (final msg in _messages) {
      await PreferencesService.saveScheduledMessage(jsonEncode(msg.toJson()));
    }
  }

  void _showNewScheduleSheet() {
    final recipientCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    DateTime date = DateTime.now().add(const Duration(hours: 1));
    TimeOfDay time = TimeOfDay.fromDateTime(date);
    String repeat = 'None';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ZenoColors.surface,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 16, right: 16, top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('New Schedule',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 12),
                TextField(
                  controller: recipientCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Recipient',
                    prefixIcon: Icon(Icons.person),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: messageCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    prefixIcon: Icon(Icons.message),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.white70),
                  title: Text('${date.day}/${date.month}/${date.year}',
                      style: const TextStyle(color: Colors.white)),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: date,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setSheetState(() => date = picked);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.access_time, color: Colors.white70),
                  title: Text(time.format(ctx),
                      style: const TextStyle(color: Colors.white)),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: ctx,
                      initialTime: time,
                    );
                    if (picked != null) setSheetState(() => time = picked);
                  },
                ),
                DropdownButtonFormField<String>(
                  value: repeat,
                  dropdownColor: ZenoColors.surface,
                  items: const ['None', 'Daily', 'Weekly', 'Monthly']
                      .map((r) => DropdownMenuItem(
                            value: r,
                            child: Text(r, style: const TextStyle(color: Colors.white)),
                          ))
                      .toList(),
                  onChanged: (v) => setSheetState(() => repeat = v ?? 'None'),
                  decoration: const InputDecoration(labelText: 'Repeat'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ZenoColors.primary,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: () {
                    final scheduledAt = DateTime(
                      date.year, date.month, date.day, time.hour, time.minute,
                    );
                    final msg = ScheduledMessage(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      recipient: recipientCtrl.text,
                      message: messageCtrl.text,
                      scheduledAt: scheduledAt,
                      repeat: repeat,
                    );
                    PreferencesService.saveScheduledMessage(
                        jsonEncode(msg.toJson()));
                    setState(() => _messages.add(msg));
                    Navigator.pop(ctx);
                  },
                  child: const Text('Schedule'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  String _timeLeft(ScheduledMessage msg) {
    final diff = msg.scheduledAt.difference(DateTime.now());
    if (diff.isNegative) return 'Overdue';
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    final secs = diff.inSeconds % 60;
    return '${days}d ${hours}h ${minutes}m ${secs}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZenoColors.background,
      appBar: AppBar(
        title: const Text('Schedule Messages'),
        backgroundColor: ZenoColors.primary,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ZenoColors.accent,
        onPressed: _showNewScheduleSheet,
        child: const Icon(Icons.add),
      ),
      body: _messages.isEmpty
          ? const Center(
              child: Text('No scheduled messages',
                  style: TextStyle(color: Colors.white54, fontSize: 16)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Dismissible(
                  key: Key(msg.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    setState(() => _messages.removeAt(index));
                    _saveAll();
                  },
                  child: Card(
                    color: ZenoColors.surface,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(msg.recipient,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(msg.message,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(color: Colors.white70)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${msg.scheduledAt.day}/${msg.scheduledAt.month}/${msg.scheduledAt.year} '
                                '${msg.scheduledAt.hour}:${msg.scheduledAt.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 12),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: msg.status == 'sent'
                                      ? Colors.green
                                      : Colors.orange,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  msg.status == 'sent' ? 'Sent' : _timeLeft(msg),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.edit, color: Colors.white54),
                      onTap: () {
                        // Edit placeholder
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
