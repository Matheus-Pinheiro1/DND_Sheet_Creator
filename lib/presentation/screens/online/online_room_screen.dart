import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dnd_character_sheet/core/theme/app_text_styles.dart';
import 'package:dnd_character_sheet/core/theme/app_theme.dart';
import 'package:dnd_character_sheet/data/models/online_room_model.dart';
import 'package:dnd_character_sheet/providers/online_providers.dart';
import 'package:go_router/go_router.dart';

class OnlineRoomScreen extends ConsumerWidget {
  final String roomId;

  const OnlineRoomScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoom = ref.watch(onlineRoomProvider);
    final room = currentRoom?.id == roomId
        ? currentRoom
        : ref.read(onlineRepositoryProvider).getRoomById(roomId);

    if (room == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sala online')),
        body: Center(
          child: Text(
            'Sala não encontrada.',
            style: AppTextStyles.lato(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }

    final isMaster = currentRoom?.id == room.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sala online'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair da sala',
            onPressed: () {
              ref.read(onlineRoomProvider.notifier).clearLastRoom();
              context.go('/');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              room.name,
              style: AppTextStyles.cinzel(
                color: AppTheme.gold,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Código da sala',
                    style:
                        AppTextStyles.lato(color: Colors.white70, fontSize: 14),
                  ),
                ),
                Text(
                  isMaster ? 'Mestre' : 'Jogador',
                  style: AppTextStyles.lato(color: AppTheme.gold, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Card(
              color: AppTheme.darkBrown,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppTheme.gold.withValues(alpha: 0.4)),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        room.code,
                        style: AppTextStyles.cinzel(
                          color: AppTheme.gold,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.copy, color: AppTheme.gold),
                      tooltip: 'Copiar código',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: room.code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Código copiado para a área de transferência')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Mestre',
              style: AppTextStyles.cinzel(color: AppTheme.gold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            _OnlinePlayerCard(player: room.master),
            const SizedBox(height: 20),
            Text(
              'Jogadores',
              style: AppTextStyles.cinzel(color: AppTheme.gold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (room.players.isEmpty)
              Text(
                'Nenhum jogador entrou ainda.',
                style: AppTextStyles.lato(color: Colors.white70, fontSize: 14),
              )
            else
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: room.players.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, index) =>
                      _OnlinePlayerCard(player: room.players[index]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OnlinePlayerCard extends StatelessWidget {
  final OnlinePlayer player;

  const _OnlinePlayerCard({required this.player});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.darkBrown,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.gold.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    player.name,
                    style: AppTextStyles.cinzel(
                      color: AppTheme.gold,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (player.isMaster)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Mestre',
                      style: AppTextStyles.lato(
                        color: AppTheme.gold,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${player.character.name} • ${player.character.characterClass} • Nível ${player.character.level}',
              style: AppTextStyles.lato(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              'Percepção passiva ${player.character.passivePerception} • Investigação passiva ${player.character.passiveInvestigation} • Intuição passiva ${player.character.passiveInsight}',
              style: AppTextStyles.lato(color: Colors.white60, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Text(
              'Condições: ${player.conditions.isEmpty ? 'Nenhuma' : player.conditions.join(', ')}',
              style: AppTextStyles.lato(color: Colors.white60, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Text(
              'Encontros: ${player.encounters.isEmpty ? 'nenhum' : player.encounters.join(', ')}',
              style: AppTextStyles.lato(color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
