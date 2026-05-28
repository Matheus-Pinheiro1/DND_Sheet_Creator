part of 'encounter_screen.dart';

class _AddPlayerSheet extends StatefulWidget {
  final List<SavedPlayerCharacter> savedPlayers;
  final Set<String> currentPlayerNames;
  final void Function(String name, int initiative) onAdd;
  final void Function(List<SavedPlayerCharacter> players) onAddMany;

  const _AddPlayerSheet({
    required this.savedPlayers,
    required this.currentPlayerNames,
    required this.onAdd,
    required this.onAddMany,
  });

  @override
  State<_AddPlayerSheet> createState() => _AddPlayerSheetState();
}

class _AddPlayerSheetState extends State<_AddPlayerSheet> {
  final _nameCtrl = TextEditingController();
  final _initiativeCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _initiativeCtrl.dispose();
    super.dispose();
  }

  String? _initiativeValidator(String? value) {
    final parsed = int.tryParse(value ?? '');
    if (parsed == null) return 'Required';
    return null;
  }

  List<SavedPlayerCharacter> get _availableSavedPlayers => widget.savedPlayers
      .where(
        (player) => !widget.currentPlayerNames.contains(player.normalizedName),
      )
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bottomInset = media.viewInsets.bottom + media.viewPadding.bottom;

    return Container(
      padding: EdgeInsets.only(
        bottom: bottomInset,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.charcoal,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text('Add Player Character',
                    style: AppTextStyles.cinzel(
                        color: AppTheme.gold,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (widget.savedPlayers.isNotEmpty) ...[
                  _SavedPlayerPicker(
                    savedPlayers: widget.savedPlayers,
                    currentPlayerNames: widget.currentPlayerNames,
                    availablePlayers: _availableSavedPlayers,
                    onAdd: (player) => widget.onAdd(
                      player.name,
                      player.initiative,
                    ),
                    onAddMany: widget.onAddMany,
                  ),
                  const SizedBox(height: 16),
                ],
                TextFormField(
                  controller: _nameCtrl,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _initiativeCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(signed: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
                  ],
                  decoration: const InputDecoration(labelText: 'Initiative'),
                  validator: _initiativeValidator,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) return;
                          widget.onAdd(
                            _nameCtrl.text.trim(),
                            int.parse(_initiativeCtrl.text),
                          );
                        },
                        child: const Text('Add to Encounter'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SavedPlayerPicker extends StatelessWidget {
  final List<SavedPlayerCharacter> savedPlayers;
  final Set<String> currentPlayerNames;
  final List<SavedPlayerCharacter> availablePlayers;
  final ValueChanged<SavedPlayerCharacter> onAdd;
  final ValueChanged<List<SavedPlayerCharacter>> onAddMany;

  const _SavedPlayerPicker({
    required this.savedPlayers,
    required this.currentPlayerNames,
    required this.availablePlayers,
    required this.onAdd,
    required this.onAddMany,
  });

  @override
  Widget build(BuildContext context) {
    return _SheetSection(
      title: 'Saved Players',
      trailing: availablePlayers.length > 1
          ? TextButton.icon(
              onPressed: () => onAddMany(availablePlayers),
              icon: const Icon(Icons.group_add_outlined, size: 16),
              label: const Text('Add all'),
            )
          : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 220),
        child: SingleChildScrollView(
          child: Column(
            children: [
              for (var i = 0; i < savedPlayers.length; i++) ...[
                _SavedPlayerRow(
                  player: savedPlayers[i],
                  alreadyAdded: currentPlayerNames.contains(
                    savedPlayers[i].normalizedName,
                  ),
                  onAdd: () => onAdd(savedPlayers[i]),
                ),
                if (i != savedPlayers.length - 1)
                  const Divider(height: 12, color: Colors.white10),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedPlayerRow extends StatelessWidget {
  final SavedPlayerCharacter player;
  final bool alreadyAdded;
  final VoidCallback onAdd;

  const _SavedPlayerRow({
    required this.player,
    required this.alreadyAdded,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            player.name,
            style: AppTextStyles.cinzel(
              color: alreadyAdded ? Colors.white38 : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        _InitiativeBadge(initiative: player.initiative, isActive: false),
        const SizedBox(width: 8),
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: alreadyAdded ? 'Already added' : 'Add player',
          onPressed: alreadyAdded ? null : onAdd,
          icon: Icon(
            alreadyAdded
                ? Icons.check_circle_outline
                : Icons.add_circle_outline,
            size: 20,
          ),
          color: alreadyAdded ? Colors.white30 : AppTheme.gold,
        ),
      ],
    );
  }
}
