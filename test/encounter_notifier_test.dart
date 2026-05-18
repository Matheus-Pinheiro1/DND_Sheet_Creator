import 'package:dnd_character_sheet/data/models/encounter_model.dart';
import 'package:dnd_character_sheet/data/models/encounter_participant.dart';
import 'package:dnd_character_sheet/data/repositories/encounter_repository.dart';
import 'package:dnd_character_sheet/providers/encounter_providers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EncounterNotifier', () {
    test('starts combat on the first sorted participant without skipping', () {
      final rogue = _monster(id: 'rogue', name: 'Rogue', initiative: 18);
      final zombie = _monster(id: 'zombie', name: 'Zombie', initiative: 6);
      final notifier = _notifier(
        participants: [zombie, rogue],
        currentTurnIndex: -1,
      );

      expect(notifier.state.isStarted, isFalse);
      expect(notifier.state.currentParticipant, isNull);

      notifier.nextTurn();

      expect(notifier.state.isStarted, isTrue);
      expect(notifier.state.currentRound, 1);
      expect(notifier.state.currentTurnIndex, 0);
      expect(notifier.state.currentParticipant?.id, rogue.id);
    });

    test('changing initiative before start does not start combat', () {
      final rogue = _monster(id: 'rogue', name: 'Rogue', initiative: 8);
      final zombie = _monster(id: 'zombie', name: 'Zombie', initiative: 6);
      final notifier = _notifier(
        participants: [rogue, zombie],
        currentTurnIndex: -1,
      );

      notifier.setInitiative(zombie.id, 20);

      expect(notifier.state.isStarted, isFalse);
      expect(notifier.state.currentParticipant, isNull);

      notifier.nextTurn();

      expect(notifier.state.currentParticipant?.id, zombie.id);
    });

    test('reuses the first available participant suffix without collisions',
        () {
      final notifier = _notifier();

      notifier.addParticipant(_monster(id: 'goblin-1', name: 'Goblin'));
      notifier.addParticipant(_monster(id: 'goblin-2', name: 'Goblin'));
      notifier.addParticipant(_monster(id: 'goblin-3', name: 'Goblin'));

      final secondGoblin = notifier.state.participants
          .firstWhere((participant) => participant.name == 'Goblin #2');
      notifier.removeParticipant(secondGoblin.id);
      notifier.addParticipant(_monster(id: 'goblin-4', name: 'Goblin'));

      final names = notifier.state.participants
          .map((participant) => participant.name)
          .toList();

      expect(names, containsAll(['Goblin', 'Goblin #2', 'Goblin #3']));
      expect(names.toSet(), hasLength(names.length));
    });

    test('preserves the visible original monster name when numbering copies',
        () {
      final notifier = _notifier();

      notifier.addParticipant(_monster(id: 'goblin-1', name: 'Goblin'));
      notifier.addParticipant(_monster(id: 'goblin-2', name: 'Goblin'));

      final secondGoblin = notifier.state.participants
          .firstWhere((participant) => participant.name == 'Goblin #2');

      expect(secondGoblin.originalName, 'Goblin');
      expect(secondGoblin.visibleOriginalName, 'Goblin');
    });

    test('manual HP can be tracked below zero', () {
      final participant = _monster(id: 'ogre', name: 'Ogre', hp: 30);
      final notifier = _notifier(participants: [participant]);

      notifier.setHp(participant.id, -5);

      expect(notifier.state.participants.single.currentHp, -5);
    });

    test('invalid armor class edits are ignored', () {
      final participant = _monster(id: 'ogre', name: 'Ogre');
      final notifier = _notifier(participants: [participant]);

      notifier.setAc(participant.id, 0);

      expect(_participant(notifier, participant.id).armorClass, 12);
    });

    test('exhaustion level is clamped between zero and six', () {
      final participant = _monster(id: 'ogre', name: 'Ogre');
      final notifier = _notifier(participants: [participant]);

      notifier.setExhaustionLevel(participant.id, 8);
      expect(_participant(notifier, participant.id).exhaustionLevel, 6);

      notifier.decrementExhaustion(participant.id);
      expect(_participant(notifier, participant.id).exhaustionLevel, 5);

      notifier.setExhaustionLevel(participant.id, -2);
      expect(_participant(notifier, participant.id).exhaustionLevel, 0);
    });

    test('legacy Exhaustion condition migrates to exhaustion level one', () {
      final participant = EncounterParticipant.fromJson({
        'id': 'fighter',
        'monsterIndex': '',
        'name': 'Fighter',
        'type': 'Player Character',
        'crLabel': '-',
        'isPlayer': true,
        'maxHp': 12,
        'currentHp': 12,
        'armorClass': 16,
        'initiative': 0,
        'conditions': ['Exhaustion', 'Poisoned'],
      });

      expect(participant.exhaustionLevel, 1);
      expect(participant.conditions, ['Poisoned']);
    });

    test('save errors are exposed to the UI', () async {
      final notifier = EncounterNotifier(
        _FailingEncounterRepository(
          EncounterModel(
            id: 'encounter-1',
            name: 'Encounter 1',
            participants: [_monster(id: 'ogre', name: 'Ogre')],
          ),
        ),
      );
      addTearDown(notifier.dispose);

      final errorFuture = notifier.saveErrors.first;
      notifier.setHp(notifier.state.participants.single.id, 3);

      expect(await errorFuture, isA<StateError>());
    });

    test('previousTurn restores round resources reset by nextTurn', () {
      final dragon = _monster(
        id: 'dragon',
        name: 'Dragon',
        initiative: 20,
        legendaryActionsMax: 3,
        legendaryActionsUsed: 2,
        reactionUsed: true,
      );
      final goblin = _monster(id: 'goblin', name: 'Goblin', initiative: 10);
      final notifier = _notifier(
        participants: [dragon, goblin],
        currentTurnIndex: 1,
      );

      notifier.nextTurn();

      expect(notifier.state.currentRound, 2);
      expect(_participant(notifier, dragon.id).legendaryActionsUsed, 0);
      expect(_participant(notifier, dragon.id).reactionUsed, isFalse);

      notifier.previousTurn();

      expect(notifier.state.currentRound, 1);
      expect(notifier.state.currentTurnIndex, 1);
      expect(_participant(notifier, dragon.id).legendaryActionsUsed, 2);
      expect(_participant(notifier, dragon.id).reactionUsed, isTrue);
    });

    test('saving the same legendary action max preserves used actions', () {
      final dragon = _monster(
        id: 'dragon',
        name: 'Dragon',
        legendaryActionsMax: 3,
        legendaryActionsUsed: 2,
      );
      final notifier = _notifier(participants: [dragon]);

      notifier.setLegendaryActionsMax(dragon.id, 3);

      expect(_participant(notifier, dragon.id).legendaryActionsUsed, 2);
    });
  });
}

EncounterNotifier _notifier({
  List<EncounterParticipant> participants = const [],
  int currentTurnIndex = -1,
}) {
  final encounter = EncounterModel(
    id: 'encounter-1',
    name: 'Encounter 1',
    participants: participants,
    currentTurnIndex: currentTurnIndex,
  );
  return EncounterNotifier(_FakeEncounterRepository(encounter));
}

EncounterParticipant _participant(EncounterNotifier notifier, String id) {
  return notifier.state.participants
      .firstWhere((participant) => participant.id == id);
}

EncounterParticipant _monster({
  required String id,
  required String name,
  int hp = 7,
  int initiative = 0,
  int legendaryActionsMax = 0,
  int legendaryActionsUsed = 0,
  bool reactionUsed = false,
  int exhaustionLevel = 0,
}) {
  return EncounterParticipant(
    id: id,
    monsterIndex: name.toLowerCase(),
    name: name,
    originalName: name,
    type: 'humanoid',
    crLabel: '1/4',
    isPlayer: false,
    maxHp: hp,
    currentHp: hp,
    armorClass: 12,
    initiative: initiative,
    legendaryActionsMax: legendaryActionsMax,
    legendaryActionsUsed: legendaryActionsUsed,
    reactionUsed: reactionUsed,
    exhaustionLevel: exhaustionLevel,
  );
}

class _FakeEncounterRepository extends EncounterRepository {
  EncounterRepositoryState _state;

  _FakeEncounterRepository(EncounterModel encounter)
      : _state = EncounterRepositoryState(
          encounters: [encounter],
          activeEncounterId: encounter.id,
        );

  @override
  EncounterRepositoryState loadAll() => _state;

  @override
  Future<void> saveAll(
    List<EncounterModel> encounters,
    String activeEncounterId,
  ) async {
    _state = EncounterRepositoryState(
      encounters: encounters,
      activeEncounterId: activeEncounterId,
    );
  }
}

class _FailingEncounterRepository extends EncounterRepository {
  final EncounterModel encounter;

  _FailingEncounterRepository(this.encounter);

  @override
  EncounterRepositoryState loadAll() => EncounterRepositoryState(
        encounters: [encounter],
        activeEncounterId: encounter.id,
      );

  @override
  Future<void> saveAll(
    List<EncounterModel> encounters,
    String activeEncounterId,
  ) async {
    throw StateError('save failed');
  }
}
