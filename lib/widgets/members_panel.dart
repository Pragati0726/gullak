import 'package:flutter/material.dart';
import 'package:gullak/utils/constants.dart';
import '../main.dart';

const List<Color> _avatarColors = [
  Color(0xFFEF9A9A),
  Color(0xFFFFB74D),
  Color(0xFFFFD54F),
  Color(0xFFA5D6A7),
  Color(0xFF90CAF9),
  Color(0xFFCE93D8),
  Color(0xFFF48FB1),
];

class _Member {
  final String id;
  final String username;
  final num savings;
  const _Member({
    required this.id,
    required this.username,
    required this.savings,
  });
}

class MembersPanel extends StatefulWidget {
  /// Auth user id of the logged-in user (gets highlighted).
  final String? currentUserId;

  /// Change this value to make the panel re-fetch.
  final int refreshKey;

  const MembersPanel({super.key, this.currentUserId, this.refreshKey = 0});

  @override
  State<MembersPanel> createState() => _MembersPanelState();
}

class _MembersPanelState extends State<MembersPanel> {
  List<_Member> _members = [];
  bool _loading = true;
  String? _error;
  int _shuffleCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant MembersPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshKey != widget.refreshKey) _load(silent: true);
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final profileRows = (await supabase
              .from('profiles')
              .select('id, username') as List)
          .cast<Map<String, dynamic>>();
      final savingsRows = (await supabase
              .from('user_savings')
              .select('user_id, total_amount') as List)
          .cast<Map<String, dynamic>>();

      final byUser = <String, num>{
        for (final s in savingsRows)
          '${s['user_id']}': (s['total_amount'] as num?) ?? 0,
      };

      final fresh = profileRows.map((p) {
        final id = '${p['id']}';
        return _Member(
          id: id,
          username: '${p['username'] ?? 'Unknown'}',
          savings: byUser[id] ?? 0,
        );
      }).toList();

      // keep the current shuffled order across refreshes
      final order = _members.map((m) => m.id).toList();
      if (order.isNotEmpty) {
        int rank(_Member m) {
          final i = order.indexOf(m.id);
          return i < 0 ? 9999 : i;
        }

        fresh.sort((a, b) => rank(a).compareTo(rank(b)));
      }

      if (!mounted) return;
      setState(() {
        _members = fresh;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      debugPrint('Members load error: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load team';
      });
    }
  }

  void _shuffle() {
    setState(() {
      _members = List.of(_members)..shuffle();
      _shuffleCount++;
    });
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!,
                style: const TextStyle(color: AppColors.brown, fontSize: 12)),
            TextButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_members.isEmpty) {
      return const Center(
        child: Text('No members yet',
            style: TextStyle(color: AppColors.brown, fontSize: 12)),
      );
    }
    return ListView.separated(
      itemCount: _members.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _MemberCard(
        member: _members[i],
        isCurrent: _members[i].id == widget.currentUserId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.peach, width: 1.5),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'TEAM',
                style: TextStyle(
                  color: AppColors.brown,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _members.isEmpty ? null : _shuffle,
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: Icon(Icons.shuffle, size: 16, color: AppColors.brown),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: KeyedSubtree(
                key: ValueKey(_shuffleCount),
                child: _body(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final _Member member;
  final bool isCurrent;
  const _MemberCard({required this.member, required this.isCurrent});

  Color get _color {
    final sum = member.username.codeUnits.fold<int>(0, (a, b) => a + b);
    return _avatarColors[sum % _avatarColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final name = member.username;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final savings = member.savings % 1 == 0
        ? member.savings.toInt().toString()
        : member.savings.toStringAsFixed(2);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color:
            isCurrent ? AppColors.peach.withAlpha(120) : AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrent ? AppColors.brown : AppColors.peach,
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: _color,
            child: isCurrent
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(initial,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                    color: AppColors.brown,
                  ),
                ),
                Text(
                  '₹$savings',
                  style: TextStyle(
                      fontSize: 11, color: AppColors.brown.withAlpha(180)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}