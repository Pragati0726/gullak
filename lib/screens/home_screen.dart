import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gullak/models/coin.dart';
import 'package:gullak/utils/constants.dart';
import 'package:gullak/widgets/coin_tray.dart';
import 'package:gullak/widgets/gullak_target.dart';
import 'package:gullak/widgets/members_panel.dart';
import 'package:gullak/widgets/savings_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import 'auth_gate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int total = 0;
  int count = 0;
  String username = '';
  int _syncTick = 0; // bumps after each Supabase save -> refreshes team panel

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      // 1. Fetch user savings
      final savingsRes = await supabase
          .from('user_savings')
          .select('total_amount, coins_count')
          .eq('user_id', user.id)
          .maybeSingle();

      // 2. Fetch username from profile table or user metadata
      final profileRes = await supabase
          .from('profiles')
          .select('username')
          .eq('id', user.id)
          .maybeSingle();

      if (mounted) {
        setState(() {
          if (savingsRes != null) {
            total = (savingsRes['total_amount'] as num).toInt();
            count = (savingsRes['coins_count'] as num).toInt();
          }
          if (profileRes != null && profileRes['username'] != null) {
            username = profileRes['username'] as String;
          } else {
            // Fallback to metadata if available
            username = user.userMetadata?['username'] ?? '';
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _syncSavingsToSupabase(int updatedAmount, int updatedCoins) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      await supabase.from('user_savings').upsert({
        'user_id': user.id,
        'total_amount': updatedAmount,
        'coins_count': updatedCoins,
        'updated_at': DateTime.now().toIso8601String(),
      });
      if (mounted) setState(() => _syncTick++);
    } catch (e) {
      debugPrint('Supabase sync error: $e');
    }
  }

  Future<void> _editUsername() async {
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => _UsernameDialog(initial: username),
    );
    if (newName == null || newName == username) return;

    final user = supabase.auth.currentUser;
    if (user == null) return;

    String? error;
    try {
      final updated = await supabase
          .from('profiles')
          .update({'username': newName})
          .eq('id', user.id)
          .select();

      if ((updated as List).isEmpty) {
        error = 'Update blocked. Add the update policy in Supabase.';
      } else {
        // keep auth metadata in sync (non-critical)
        try {
          await supabase.auth
              .updateUser(UserAttributes(data: {'username': newName}));
        } catch (e) {
          debugPrint('Metadata update error: $e');
        }
      }
    } on PostgrestException catch (e) {
      debugPrint('Username update error: $e');
      error = e.code == '23505'
          ? 'That username is already taken'
          : 'Could not update username';
    } catch (e) {
      debugPrint('Username update error: $e');
      error = 'Could not update username';
    }

    if (!mounted) return;
    if (error == null) {
      setState(() {
        username = newName;
        _syncTick++; // refresh team panel
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Username updated')),
    );
  }

  void _addCoin(Coin coin) {
    HapticFeedback.lightImpact();
    setState(() {
      total += coin.value;
      count++;
    });
    _syncSavingsToSupabase(total, count);
  }

  void _reset() {
    HapticFeedback.selectionClick();
    setState(() {
      total = 0;
      count = 0;
    });
    _syncSavingsToSupabase(0, 0);
  }

  Future<void> _logOut() async {
    try {
      await supabase.auth.signOut();
      if (mounted) {
        // Reset the navigation route completely back to AuthGate
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthGate()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'Gullak',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            if (username.isNotEmpty)
              Text(
                'Hi, $username',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.brown,
                ),
              ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.brown,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit username',
            onPressed: _editUsername,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log Out',
            onPressed: _logOut,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            children: [
              SavingsCard(total: total, count: count, onReset: _reset),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MembersPanel(
                      currentUserId: supabase.auth.currentUser?.id,
                      refreshKey: _syncTick,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: FittedBox(
                              child: GullakTarget(onCoinDropped: _addCoin),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const _HintPill(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Center(
                      child: SingleChildScrollView(child: CoinTray()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UsernameDialog extends StatefulWidget {
  final String initial;
  const _UsernameDialog({required this.initial});

  @override
  State<_UsernameDialog> createState() => _UsernameDialogState();
}

class _UsernameDialogState extends State<_UsernameDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial);
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, _controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.background,
      title: const Text(
        'Update username',
        style: TextStyle(color: AppColors.brown, fontWeight: FontWeight.w700),
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          maxLength: 20,
          decoration: const InputDecoration(
            labelText: 'Username',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            final text = value?.trim() ?? '';
            if (text.isEmpty) return 'Enter a username';
            if (text.length < 3) return 'At least 3 characters';
            return null;
          },
          onFieldSubmitted: (_) => _save(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}

class _HintPill extends StatelessWidget {
  const _HintPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.peach.withAlpha(140),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.touch_app_outlined, size: 18, color: AppColors.brown),
          SizedBox(width: 6),
          Text(
            'Drag a coin into the gullak',
            style: TextStyle(color: AppColors.brown, fontSize: 13),
          ),
        ],
      ),
    );
  }
}