part of 'encounter_screen.dart';

class _EncounterListSheet extends ConsumerStatefulWidget {
  const _EncounterListSheet();

  @override
  ConsumerState<_EncounterListSheet> createState() =>
      _EncounterListSheetState();
}

class _EncounterListSheetState extends ConsumerState<_EncounterListSheet> {
  final _renameCtrl = TextEditingController();
  final _renameFocus = FocusNode();
  String? _editingEncounterId;

  @override
  void dispose() {
    _renameFocus.dispose();
    _renameCtrl.dispose();
    super.dispose();
  }

  void _startRename(EncounterModel encounter) {
    setState(() {
      _editingEncounterId = encounter.id;
      _renameCtrl.text = encounter.name;
      _renameCtrl.selection = TextSelection(
        baseOffset: 0,
        extentOffset: encounter.name.length,
      );
    });
    _renameFocus.requestFocus();
  }

  void _cancelRename() {
    setState(() {
      _editingEncounterId = null;
      _renameCtrl.clear();
    });
    _renameFocus.unfocus();
  }

  void _saveRename(EncounterNotifier notifier) {
    final id = _editingEncounterId;
    if (id == null) return;
    notifier.renameEncounter(id, _renameCtrl.text);
    _cancelRename();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final keyboardHeight = media.viewInsets.bottom;
    final availableHeight =
        (media.size.height - keyboardHeight - media.padding.top)
            .clamp(0.0, media.size.height);
    final maxSheetHeight =
        keyboardHeight > 0 ? availableHeight : media.size.height * 0.72;
    final activeEncounter = ref.watch(encounterProvider);
    final notifier = ref.read(encounterProvider.notifier);
    final activeId = activeEncounter.id;
    final encounters = notifier.encounters
        .map(
          (encounter) => encounter.id == activeId ? activeEncounter : encounter,
        )
        .toList(growable: false);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Container(
        decoration: const BoxDecoration(
          color: AppTheme.charcoal,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: maxSheetHeight,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Encounters',
                          style: AppTextStyles.cinzel(
                            color: AppTheme.gold,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          notifier.createEncounter();
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('New'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.only(
                        bottom: keyboardHeight > 0 ? 12 : 0,
                      ),
                      itemCount: encounters.length,
                      itemBuilder: (context, index) {
                        final encounter = encounters[index];
                        if (_editingEncounterId == encounter.id) {
                          return _EncounterRenameTile(
                            controller: _renameCtrl,
                            focusNode: _renameFocus,
                            onCancel: _cancelRename,
                            onSave: () => _saveRename(notifier),
                          );
                        }

                        return _EncounterListTile(
                          encounter: encounter,
                          isActive: encounter.id == activeId,
                          canDelete: encounters.length > 1,
                          onTap: () {
                            notifier.selectEncounter(encounter.id);
                            Navigator.of(context).pop();
                          },
                          onRename: () => _startRename(encounter),
                          onColor: () => _showEncounterColorSheet(
                            context,
                            notifier,
                            encounter,
                          ),
                          onDelete: () => _confirmDeleteEncounter(
                            context,
                            notifier,
                            encounter,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEncounterColorSheet(
    BuildContext context,
    EncounterNotifier notifier,
    EncounterModel encounter,
  ) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EncounterColorSheet(
        encounter: encounter,
        onSelected: (colorTag) {
          notifier.setEncounterColor(encounter.id, colorTag);
        },
      ),
    );
  }

  void _confirmDeleteEncounter(
    BuildContext context,
    EncounterNotifier notifier,
    EncounterModel encounter,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.ashGray,
        title: Text(
          'Delete ${encounter.name}?',
          style: AppTextStyles.cinzel(color: AppTheme.gold),
        ),
        content: Text(
          'This removes only this encounter.',
          style: AppTextStyles.lato(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.crimson),
            onPressed: () {
              notifier.deleteEncounter(encounter.id);
              Navigator.of(dialogContext).pop();
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _EncounterListTile extends StatelessWidget {
  final EncounterModel encounter;
  final bool isActive;
  final bool canDelete;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onColor;
  final VoidCallback onDelete;

  const _EncounterListTile({
    required this.encounter,
    required this.isActive,
    required this.canDelete,
    required this.onTap,
    required this.onRename,
    required this.onColor,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final participantCount = encounter.participants.length;
    final current = encounter.currentParticipant;
    final encounterColor = encounterColorForTag(encounter.colorTag);
    final subtitle = encounter.isEmpty
        ? 'Empty'
        : 'Round ${encounter.currentRound} - $participantCount participant${participantCount == 1 ? '' : 's'}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.darkBrown.withValues(alpha: 0.9)
            : AppTheme.ashGray,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive
              ? encounterColor.withValues(alpha: 0.75)
              : encounter.colorTag == 0
                  ? Colors.white10
                  : encounterColor.withValues(alpha: 0.45),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: _EncounterColorIndicator(
          colorTag: encounter.colorTag,
          isActive: isActive,
        ),
        title: Text(
          encounter.name,
          style: AppTextStyles.cinzel(
            color: isActive ? encounterColor : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          current == null ? subtitle : '$subtitle - ${current.name} turn',
          style: AppTextStyles.lato(color: Colors.white54, fontSize: 12),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white54),
          onSelected: (value) {
            if (value == 'rename') onRename();
            if (value == 'color') onColor();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'rename', child: Text('Rename')),
            const PopupMenuItem(value: 'color', child: Text('Color')),
            PopupMenuItem(
              value: 'delete',
              enabled: canDelete,
              child: Text(
                canDelete ? 'Delete' : 'Delete (last)',
                style: TextStyle(
                  color: canDelete ? Colors.redAccent : Colors.white38,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
