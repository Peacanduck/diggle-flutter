/// save_slots_screen.dart
/// Save slot selection screen for New Game and Load Game flows.
///
/// Shows 3 save slots with:
/// - Slot summary (depth, playtime, date)
/// - New Game: picks an empty slot or overwrites
/// - Load Game: loads an existing save
/// - Delete: clears a save slot

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/world_save_service.dart';
import '../services/game_lifecycle_manager.dart';

enum SaveSlotMode { newGame, loadGame }

class SaveSlotsScreen extends StatefulWidget {
  final SaveSlotMode mode;
  final void Function(int slot, int? seed) onSlotSelected;
  final VoidCallback onBack;

  const SaveSlotsScreen({
    super.key,
    required this.mode,
    required this.onSlotSelected,
    required this.onBack,
  });

  @override
  State<SaveSlotsScreen> createState() => _SaveSlotsScreenState();
}

class _SaveSlotsScreenState extends State<SaveSlotsScreen>
    with SingleTickerProviderStateMixin {
  List<WorldSaveSummary?> _slots = [null, null, null];
  bool _loading = true;
  int? _confirmDeleteSlot;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _loadSaves();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadSaves() async {
    setState(() => _loading = true);
    try {
      final lifecycle = context.read<GameLifecycleManager>();
      final summaries = await lifecycle.getSaveSummaries();

      final slots = <WorldSaveSummary?>[null, null, null];
      for (final s in summaries) {
        if (s.slot >= 0 && s.slot < 3) {
          slots[s.slot] = s;
        }
      }
      setState(() {
        _slots = slots;
        _loading = false;
      });
      _animController.forward();
    } catch (e) {
      debugPrint('SaveSlotsScreen: error loading saves: $e');
      setState(() => _loading = false);
      _animController.forward();
    }
  }

  Future<void> _deleteSlot(int slot) async {
    try {
      final worldSaveService = context.read<WorldSaveService>();
      await worldSaveService.deleteSave(slot: slot);
      setState(() {
        _slots[slot] = null;
        _confirmDeleteSlot = null;
      });
    } catch (e) {
      debugPrint('SaveSlotsScreen: delete error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.mode == SaveSlotMode.newGame;
    final title = isNew ? 'NEW GAME' : 'LOAD GAME';
    final subtitle = isNew
        ? 'Choose a save slot for your new adventure'
        : 'Select a save to continue your journey';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: widget.onBack,
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white70, size: 28),
                    ),
                    const SizedBox(width: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: isNew
                                ? Colors.amber.shade300
                                : Colors.cyan.shade300,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Slots
              Expanded(
                child: _loading
                    ? const Center(
                  child: CircularProgressIndicator(color: Colors.amber),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return _buildSlotCard(index, _slots[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlotCard(int slot, WorldSaveSummary? save) {
    final isNew = widget.mode == SaveSlotMode.newGame;
    final isEmpty = save == null;
    final isDeleting = _confirmDeleteSlot == slot;

    // In load mode, empty slots are disabled
    final isDisabled = !isNew && isEmpty;

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final delay = slot * 0.15;
        final t = _animController.value;
        final progress = ((t - delay) / (1.0 - delay)).clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(0, 30 * (1 - progress)),
          child: Opacity(opacity: progress, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDisabled
                ? [
              Colors.grey.shade900.withOpacity(0.4),
              Colors.grey.shade900.withOpacity(0.2),
            ]
                : isEmpty
                ? [
              const Color(0xFF1e3a5f).withOpacity(0.6),
              const Color(0xFF16213e).withOpacity(0.4),
            ]
                : [
              Colors.amber.shade900.withOpacity(0.3),
              Colors.brown.shade900.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDisabled
                ? Colors.grey.shade800
                : isEmpty
                ? Colors.cyan.shade800.withOpacity(0.5)
                : Colors.amber.shade700.withOpacity(0.6),
            width: 1.5,
          ),
        ),
        child: isDeleting
            ? _buildDeleteConfirmation(slot, save)
            : _buildSlotContent(slot, save, isNew, isEmpty, isDisabled),
      ),
    );
  }

  Widget _buildSlotContent(
      int slot, WorldSaveSummary? save, bool isNew, bool isEmpty, bool isDisabled) {
    return InkWell(
      onTap: isDisabled
          ? null
          : () {
        if (isEmpty) {
          widget.onSlotSelected(
              slot, DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF);
        } else if (isNew) {
          _showOverwriteConfirm(slot);
        } else {
          widget.onSlotSelected(slot, save!.seed);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Slot number badge
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isEmpty
                    ? Colors.grey.shade800
                    : Colors.amber.shade900.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isEmpty
                      ? Colors.grey.shade700
                      : Colors.amber.shade700,
                ),
              ),
              child: Center(
                child: isEmpty
                    ? Icon(Icons.add_rounded,
                    color: Colors.white.withOpacity(0.4), size: 28)
                    : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.save_rounded,
                        color: Colors.amber, size: 20),
                    Text(
                      '${slot + 1}',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Slot info
            Expanded(
              child: isEmpty
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Slot ${slot + 1} — Empty',
                    style: TextStyle(
                      color: Colors.white.withOpacity(isDisabled ? 0.3 : 0.7),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isNew
                        ? 'Tap to start a new adventure'
                        : 'No save data',
                    style: TextStyle(
                      color: Colors.white.withOpacity(isDisabled ? 0.2 : 0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Slot ${slot + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildMiniStat(
                          Icons.height, '${save!.depthReached}m'),
                      const SizedBox(width: 12),
                      _buildMiniStat(Icons.timer,
                          _formatPlaytime(save.playtimeSeconds)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Saved ${_formatDate(save.savedAt)}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            // Delete button
            if (!isEmpty)
              IconButton(
                onPressed: () =>
                    setState(() => _confirmDeleteSlot = slot),
                icon: Icon(Icons.delete_outline,
                    color: Colors.red.shade300.withOpacity(0.6), size: 22),
                tooltip: 'Delete save',
              ),

            // Arrow indicator
            if (!isDisabled)
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.3),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteConfirmation(int slot, WorldSaveSummary? save) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Colors.red, size: 36),
          const SizedBox(height: 8),
          Text(
            'Delete Slot ${slot + 1}?',
            style: const TextStyle(
              color: Colors.red,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (save != null) ...[
            const SizedBox(height: 4),
            Text(
              'Depth: ${save.depthReached}m • ${_formatPlaytime(save.playtimeSeconds)} played',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
          const SizedBox(height: 4),
          const Text(
            'This cannot be undone.',
            style: TextStyle(color: Colors.red, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () =>
                    setState(() => _confirmDeleteSlot = null),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white24),
                ),
                child: const Text('CANCEL'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => _deleteSlot(slot),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                ),
                child: const Text('DELETE'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showOverwriteConfirm(int slot) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        title: const Text('Overwrite Save?',
            style: TextStyle(color: Colors.amber)),
        content: Text(
          'Slot ${slot + 1} already has a save. Starting a new game here will overwrite it.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteSlot(slot).then((_) {
                widget.onSlotSelected(
                    slot, DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF);
              });
            },
            style:
            ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade700),
            child: const Text('OVERWRITE'),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white54, size: 14),
        const SizedBox(width: 3),
        Text(
          value,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  String _formatPlaytime(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    if (m < 60) return '${m}m';
    final h = m ~/ 60;
    return '${h}h ${m % 60}m';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.month}/${date.day}/${date.year}';
  }
}