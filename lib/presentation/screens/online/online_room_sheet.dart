import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import 'package:dnd_character_sheet/core/theme/app_theme.dart';
import 'package:dnd_character_sheet/data/models/character_model.dart';
import 'package:dnd_character_sheet/data/models/online_room_model.dart';
import 'package:dnd_character_sheet/providers/online_providers.dart';

OnlineCharacter _buildOnlineCharacterFromCharacter(CharacterModel character) {
  return OnlineCharacter(
    name: character.name,
    characterClass: character.classDisplayName.isNotEmpty
        ? character.classDisplayName
        : character.className,
    level: character.level,
    passivePerception: 10,
    passiveInvestigation: 10,
    passiveInsight: 10,
  );
}

Future<void> showOnlineRoomBottomSheet(
  BuildContext context,
  WidgetRef ref, {
  CharacterModel? entryCharacter,
}) {
  final codeController = TextEditingController();
  var isJoinMode = entryCharacter != null;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.ashGray,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20,
                  MediaQuery.of(sheetContext).viewInsets.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  if (isJoinMode) ...[
                    Text(
                      entryCharacter == null
                          ? 'Entrar em sala'
                          : 'Entrar em sala como ${entryCharacter.name}',
                      style: AppTextStyles.cinzel(
                        color: AppTheme.gold,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      entryCharacter == null
                          ? 'Digite o código da sala para entrar como jogador.'
                          : 'Digite o código da sala para entrar como ${entryCharacter.name}.',
                      style: AppTextStyles.lato(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: codeController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Código da sala',
                        filled: true,
                        fillColor: Colors.black12,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => isJoinMode = false),
                            child: const Text('Voltar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final code = codeController.text.trim();
                              if (code.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Digite um código válido')),
                                );
                                return;
                              }
                              final room = ref
                                  .read(onlineRoomProvider.notifier)
                                  .joinRoom(
                                    code,
                                    playerName:
                                        entryCharacter?.name ?? 'Jogador',
                                    character: entryCharacter != null
                                        ? _buildOnlineCharacterFromCharacter(
                                            entryCharacter)
                                        : null,
                                  );
                              if (room == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Sala não encontrada')),
                                );
                                return;
                              }
                              Navigator.of(sheetContext).pop();
                              context.push('/online-room/${room.id}');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.crimson,
                            ),
                            child: Text(entryCharacter == null
                                ? 'Entrar'
                                : 'Entrar como ${entryCharacter.name}'),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      'Online',
                      style: AppTextStyles.cinzel(
                        color: AppTheme.gold,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Escolha o modo de sala. Você pode criar uma sala e virar mestre, ou entrar em uma sala existente com um código.',
                      style: AppTextStyles.lato(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (entryCharacter == null) {
                          final room = ref
                              .read(onlineRoomProvider.notifier)
                              .createRoom(masterName: 'Mestre');
                          Navigator.of(sheetContext).pop();
                          context.push('/online-room/${room.id}');
                          return;
                        }

                        final room = ref
                            .read(onlineRoomProvider.notifier)
                            .createRoom(masterName: 'Mestre');
                        final joined =
                            ref.read(onlineRoomProvider.notifier).joinRoom(
                                  room.code,
                                  playerName: entryCharacter.name,
                                  character: _buildOnlineCharacterFromCharacter(
                                      entryCharacter),
                                );
                        if (joined == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Não foi possível criar a sala.')),
                          );
                          return;
                        }
                        Navigator.of(sheetContext).pop();
                        context.push('/online-room/${joined.id}');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.crimson,
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: Text(entryCharacter == null
                          ? 'Criar sala'
                          : 'Criar sala e entrar como ${entryCharacter.name}'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => setState(() => isJoinMode = true),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const Text('Entrar em sala'),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
