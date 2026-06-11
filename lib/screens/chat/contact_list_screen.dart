import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../theme/colors.dart';
import '../../utils/helpers.dart';
import '../../utils/permissions.dart';
import '../chat/chat_screen.dart';

class ContactListScreen extends StatefulWidget {
  const ContactListScreen({super.key});

  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _contacts = [];
  List<Map<String, dynamic>> _filteredContacts = [];
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
    final hasPermission = await Permissions.requestContacts();
    if (!hasPermission) {
      setState(() => _isLoading = false);
      return;
    }

    // Simulate contacts - in real app use contacts_service package
    _contacts = [
      {'id': '1', 'name': 'Alice Johnson', 'phone': '+1234567890', 'isRegistered': true, 'status': 'Available'},
      {'id': '2', 'name': 'Bob Smith', 'phone': '+1234567891', 'isRegistered': true, 'status': 'At work'},
      {'id': '3', 'name': 'Charlie Brown', 'phone': '+1234567892', 'isRegistered': false},
      {'id': '4', 'name': 'Diana Prince', 'phone': '+1234567893', 'isRegistered': true, 'status': 'Busy'},
      {'id': '5', 'name': 'Eve Wilson', 'phone': '+1234567894', 'isRegistered': true, 'status': 'Hey there!'},
      {'id': '6', 'name': 'Frank Castle', 'phone': '+1234567895', 'isRegistered': false},
      {'id': '7', 'name': 'Grace Hopper', 'phone': '+1234567896', 'isRegistered': true, 'status': 'Coding'},
      {'id': '8', 'name': 'Henry Ford', 'phone': '+1234567897', 'isRegistered': true, 'status': 'Driving'},
    ];

    _filteredContacts = List.from(_contacts);
    setState(() => _isLoading = false);
  }

  void _filterContacts(String query) {
    setState(() {
      _filteredContacts = _contacts.where((c) =>
        c['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
        c['phone'].toString().contains(query),
      ).toList();
    });
  }

  void _startChat(Map<String, dynamic> contact) async {
    if (!(contact['isRegistered'] ?? false)) return;
    final auth = context.read<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();
    final chatId = await chatProvider.createOrGetChat(auth.userId, contact['id']);
    if (mounted) {
      final chat = await chatProvider.chatService.getChat(chatId);
      if (chat != null) {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => ChatScreen(chat: chat),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Select Contact'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: _filterContacts,
              decoration: InputDecoration(
                hintText: 'Search contacts',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredContacts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.contacts_outlined, size: 80, color: AppColors.textHint),
                      const SizedBox(height: 16),
                      Text('No contacts found', style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredContacts.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildNewGroupTile();
                    }
                    final contact = _filteredContacts[index - 1];
                    return _buildContactTile(contact);
                  },
                ),
    );
  }

  Widget _buildNewGroupTile() {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.accentLight.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.group_add, color: AppColors.accentLight),
        ),
        title: const Text('New group'),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => const NewGroupScreen(),
          ));
        },
      ),
    );
  }

  Widget _buildContactTile(Map<String, dynamic> contact) {
    final isRegistered = contact['isRegistered'] ?? false;
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: Helpers.generateAvatarColor(contact['name']),
          child: Text(
            Helpers.getInitials(contact['name']),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Row(
          children: [
            Text(contact['name'], style: const TextStyle(fontWeight: FontWeight.w500)),
            if (isRegistered)
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Icon(Icons.check_circle, size: 14, color: AppColors.accent),
              ),
          ],
        ),
        subtitle: Text(
          contact['status'] ?? contact['phone'],
          style: TextStyle(fontSize: 12, color: AppColors.textHint),
        ),
        trailing: isRegistered
            ? null
            : TextButton(
                onPressed: () {},
                child: const Text('Invite', style: TextStyle(color: AppColors.accent)),
              ),
        onTap: isRegistered ? () => _startChat(contact) : null,
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
  List<Map<String, dynamic>> _contacts = [];
  List<Map<String, dynamic>> _filteredContacts = [];
  int _step = 1;

  @override
  void initState() {
    super.initState();
    _contacts = [
      {'id': '1', 'name': 'Alice Johnson'},
      {'id': '2', 'name': 'Bob Smith'},
      {'id': '4', 'name': 'Diana Prince'},
      {'id': '5', 'name': 'Eve Wilson'},
      {'id': '7', 'name': 'Grace Hopper'},
    ];
    _filteredContacts = List.from(_contacts);
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_step == 1 ? 'New Group' : 'Add Participants (${_selectedIds.length})'),
        actions: [
          if (_step == 2)
            TextButton(
              onPressed: _selectedIds.length >= 2 ? _createGroup : null,
              child: const Text('Create', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: _step == 1 ? _buildStep1() : _buildStep2(),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.camera_alt, size: 40, color: AppColors.primaryLight),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Group name',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Group description (optional)',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nameController.text.trim().isEmpty
                  ? null
                  : () => setState(() => _step = 2),
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            onChanged: (q) {
              setState(() {
                _filteredContacts = _contacts.where((c) =>
                  c['name'].toString().toLowerCase().contains(q.toLowerCase()),
                ).toList();
              });
            },
            decoration: InputDecoration(
              hintText: 'Search contacts',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredContacts.length,
            itemBuilder: (context, index) {
              final contact = _filteredContacts[index];
              final isSelected = _selectedIds.contains(contact['id']);
              return Container(
                color: Colors.white,
                child: CheckboxListTile(
                  value: isSelected,
                  onChanged: (v) {
                    setState(() {
                      if (v == true) _selectedIds.add(contact['id']);
                      else _selectedIds.remove(contact['id']);
                    });
                  },
                  secondary: CircleAvatar(
                    backgroundColor: Helpers.generateAvatarColor(contact['name']),
                    child: Text(
                      Helpers.getInitials(contact['name']),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(contact['name']),
                  activeColor: AppColors.accent,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
