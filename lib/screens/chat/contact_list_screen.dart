import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/colors.dart';
import '../../utils/helpers.dart';
import '../../utils/permissions.dart';
import '../../models/contact_model.dart';
import '../chat/chat_screen.dart';

class ContactListScreen extends StatefulWidget {
  final bool selectMode;
  final ValueChanged<List<String>>? onSelected;
  const ContactListScreen({super.key, this.selectMode = false, this.onSelected});

  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ContactModel> _contacts = [];
  List<ContactModel> _filtered = [];
  final Set<String> _selectedIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    await Permissions.requestContacts();
    final auth = context.read<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();
    final registeredIds = chatProvider.chats
      .expand((c) => c.participants)
      .where((p) => p != auth.userId)
      .toSet();

    _contacts = [
      ContactModel(id: '1', name: 'Alice Johnson', phoneNumber: '+1234567890', isRegistered: true, status: 'Available', isOnline: true),
      ContactModel(id: '2', name: 'Bob Smith', phoneNumber: '+1234567891', isRegistered: true, status: 'At work', lastSeen: DateTime.now().subtract(const Duration(minutes: 5))),
      ContactModel(id: '3', name: 'Charlie Brown', phoneNumber: '+1234567892', isRegistered: false),
      ContactModel(id: '4', name: 'Diana Prince', phoneNumber: '+1234567893', isRegistered: true, status: 'Busy'),
      ContactModel(id: '5', name: 'Eve Wilson', phoneNumber: '+1234567894', isRegistered: true, status: 'Hey there!', isOnline: true),
      ContactModel(id: '6', name: 'Frank Castle', phoneNumber: '+1234567895', isRegistered: false),
      ContactModel(id: '7', name: 'Grace Hopper', phoneNumber: '+1234567896', isRegistered: true, status: 'Coding', isOnline: true),
      ContactModel(id: '8', name: 'Henry Ford', phoneNumber: '+1234567897', isRegistered: true, status: 'Driving'),
      ContactModel(id: '9', name: 'Ivy League', phoneNumber: '+1234567898', isRegistered: false),
      ContactModel(id: '10', name: 'Jack Sparrow', phoneNumber: '+1234567899', isRegistered: true, status: 'On the sea'),
    ];

    final regCount = _contacts.where((c) => c.isRegistered).length;
    _filtered = List.from(_contacts);
    setState(() => _isLoading = false);
  }

  void _filter(String q) {
    setState(() {
      _filtered = _contacts.where((c) =>
        c.name.toLowerCase().contains(q.toLowerCase()) ||
        c.phoneNumber.contains(q),
      ).toList();
    });
  }

  Future<void> _inviteViaSms(String phone, String name) async {
    final uri = Uri.parse('sms:$phone?body=Hey! Join me on ChatWave - the ultimate chat app! Download now.');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not send SMS to $name')));
    }
  }

  void _startChat(ContactModel contact) async {
    if (!contact.isRegistered) return;
    final auth = context.read<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();
    final chatId = await chatProvider.createOrGetChat(auth.userId, contact.id);
    if (mounted) {
      final chat = await chatProvider.chatService.getChat(chatId);
      if (chat != null) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(chat: chat)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final isDark = theme.isDarkMode;
    final accent = theme.accentColor;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : AppColors.background,
      appBar: AppBar(
        title: Text(widget.selectMode ? 'Select Contacts (${_selectedIds.length})' : 'Contacts'),
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : null,
        actions: [
          if (widget.selectMode)
            TextButton(
              onPressed: _selectedIds.isEmpty ? null : () => widget.onSelected?.call(_selectedIds.toList()),
              child: Text('Done', style: TextStyle(color: accent, fontWeight: FontWeight.bold)),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: _filter,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'Search contacts',
                prefixIcon: Icon(Icons.search, color: isDark ? Colors.white38 : Colors.grey),
                filled: true,
                fillColor: isDark ? const Color(0xFF2A2A3E) : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (!widget.selectMode)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: isDark ? const Color(0xFF1E1E32) : Colors.white,
                    child: Row(
                      children: [
                        Icon(Icons.people, color: accent, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '${_contacts.length} contacts · ${_contacts.where((c) => c.isRegistered).length} on ChatWave',
                          style: TextStyle(color: isDark ? Colors.white60 : Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: _filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.contacts_outlined, size: 80, color: isDark ? Colors.white12 : Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text('No contacts found', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey[500])),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filtered.length + (widget.selectMode ? 0 : 1),
                          itemBuilder: (ctx, index) {
                            if (!widget.selectMode && index == 0) {
                              return _buildHeader(accent, isDark);
                            }
                            final contact = _filtered[index - (widget.selectMode ? 0 : 1)];
                            return _buildContactTile(contact, accent, isDark);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader(Color accent, bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF1E1E32) : Colors.white,
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.group_add, color: accent),
            ),
            title: Text('New group', style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87)),
            trailing: Icon(Icons.chevron_right, color: isDark ? Colors.white24 : Colors.grey),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewGroupScreen())),
          ),
          ListTile(
            leading: Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.person_add_alt_1, color: accent),
            ),
            title: Text('Invite friends', style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87)),
            subtitle: Text('Share ChatWave with your contacts', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontSize: 12)),
            trailing: Icon(Icons.chevron_right, color: isDark ? Colors.white24 : Colors.grey),
            onTap: () => _inviteViaSms('', ''),
          ),
          const Divider(indent: 72, height: 1),
        ],
      ),
    );
  }

  Widget _buildContactTile(ContactModel contact, Color accent, bool isDark) {
    final isSelected = _selectedIds.contains(contact.id);
    return Container(
      color: isDark ? const Color(0xFF1E1E32) : Colors.white,
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Helpers.generateAvatarColor(contact.name),
              child: Text(Helpers.getInitials(contact.name), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            if (contact.isOnline)
              Positioned(bottom: 0, right: 0, child: Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green, border: Border.all(color: isDark ? const Color(0xFF1E1E32) : Colors.white, width: 2)))),
          ],
        ),
        title: Row(
          children: [
            Expanded(child: Text(contact.name, style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87))),
            if (contact.isRegistered)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)), child: Text('ChatWave', style: TextStyle(fontSize: 9, color: Colors.green.shade700, fontWeight: FontWeight.w600))),
              ),
          ],
        ),
        subtitle: Text(contact.status ?? contact.phoneNumber, style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.grey[500])),
        trailing: widget.selectMode
            ? Checkbox(value: isSelected, activeColor: accent, onChanged: (v) => setState(() => v == true ? _selectedIds.add(contact.id) : _selectedIds.remove(contact.id)))
            : (contact.isRegistered ? const Icon(Icons.chevron_right, size: 18) : TextButton(
                onPressed: () => _inviteViaSms(contact.phoneNumber, contact.name),
                child: Text('Invite', style: TextStyle(color: accent, fontSize: 12)),
              )),
        onTap: widget.selectMode
            ? () => setState(() => isSelected ? _selectedIds.remove(contact.id) : _selectedIds.add(contact.id))
            : contact.isRegistered ? () => _startChat(contact) : () => _inviteViaSms(contact.phoneNumber, contact.name),
      ),
    );
  }
}

class NewGroupScreen extends StatefulWidget {
  const NewGroupScreen({super.key});
  @override
  State<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _searchController = TextEditingController();
  final Set<String> _selectedIds = {};
  List<ContactModel> _contacts = [];
  List<ContactModel> _filtered = [];
  int _step = 1;

  @override
  void initState() {
    super.initState();
    _contacts = [
      ContactModel(id: '1', name: 'Alice Johnson', phoneNumber: '+1234567890', isRegistered: true, status: 'Available'),
      ContactModel(id: '2', name: 'Bob Smith', phoneNumber: '+1234567891', isRegistered: true, status: 'At work'),
      ContactModel(id: '4', name: 'Diana Prince', phoneNumber: '+1234567893', isRegistered: true, status: 'Busy'),
      ContactModel(id: '5', name: 'Eve Wilson', phoneNumber: '+1234567894', isRegistered: true, status: 'Hey there!'),
      ContactModel(id: '7', name: 'Grace Hopper', phoneNumber: '+1234567896', isRegistered: true, status: 'Coding'),
    ];
    _filtered = List.from(_contacts);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    if (_nameController.text.trim().isEmpty || _selectedIds.length < 2) return;
    final auth = context.read<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();
    await chatProvider.createGroup(
      currentUid: auth.userId,
      groupName: _nameController.text.trim(),
      description: _descController.text.trim(),
      participants: _selectedIds.toList(),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final isDark = theme.isDarkMode;
    final accent = theme.accentColor;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : null,
        title: Text(_step == 1 ? 'New Group' : 'Add Participants (${_selectedIds.length})', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        actions: [if (_step == 2) TextButton(onPressed: _selectedIds.length >= 2 ? _createGroup : null, child: Text('Create', style: TextStyle(color: accent, fontWeight: FontWeight.bold)))],
      ),
      body: _step == 1 ? _buildStep1(accent, isDark) : _buildStep2(accent, isDark),
    );
  }

  Widget _buildStep1(Color accent, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(color: accent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
              child: Icon(Icons.camera_alt, size: 40, color: accent),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(hintText: 'Group name', hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey), filled: true, fillColor: isDark ? const Color(0xFF2A2A3E) : Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descController,
            maxLines: 3,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(hintText: 'Group description (optional)', hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey), filled: true, fillColor: isDark ? const Color(0xFF2A2A3E) : Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nameController.text.trim().isEmpty ? null : () => setState(() => _step = 2),
              style: ElevatedButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2(Color accent, bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            onChanged: (q) => setState(() => _filtered = _contacts.where((c) => c.name.toLowerCase().contains(q.toLowerCase())).toList()),
            decoration: InputDecoration(hintText: 'Search contacts', hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey), prefixIcon: Icon(Icons.search, color: isDark ? Colors.white38 : Colors.grey), filled: true, fillColor: isDark ? const Color(0xFF2A2A3E) : Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none)),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filtered.length,
            itemBuilder: (ctx, i) {
              final c = _filtered[i];
              final sel = _selectedIds.contains(c.id);
              return Container(
                color: isDark ? const Color(0xFF1E1E32) : Colors.white,
                child: CheckboxListTile(
                  value: sel,
                  activeColor: accent,
                  onChanged: (v) => setState(() => v == true ? _selectedIds.add(c.id) : _selectedIds.remove(c.id)),
                  secondary: CircleAvatar(backgroundColor: Helpers.generateAvatarColor(c.name), child: Text(Helpers.getInitials(c.name), style: const TextStyle(color: Colors.white))),
                  title: Text(c.name, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
