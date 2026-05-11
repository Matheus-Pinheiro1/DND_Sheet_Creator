part of 'character_creation_provider.dart';

extension CreationNotifierWarlockRogueArtificerChoices on CreationNotifier {
  void setWarlockInvocations(List<String> invocationIds) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) => entry.startsWith(WarlockChoiceService.invocationEntryPrefix),
    );

    final uniqueInvocations = <String>[];
    for (final invocationId in invocationIds) {
      final normalized = invocationId.trim();
      if (!WarlockChoiceService.invocationIds.contains(normalized)) {
        continue;
      }
      if (uniqueInvocations.contains(normalized)) {
        continue;
      }
      if (!WarlockChoiceService.qualifiesForInvocation(
        invocationId: normalized,
        level: _notifierState.level,
        selectedInvocationIds: uniqueInvocations,
      )) {
        continue;
      }
      uniqueInvocations.add(normalized);
      if (uniqueInvocations.length >=
          WarlockChoiceService.invocationCountForLevel(_notifierState.level)) {
        break;
      }
    }

    for (final invocationId in uniqueInvocations) {
      current.add('${WarlockChoiceService.invocationEntryPrefix}$invocationId');
    }

    if (!uniqueInvocations.contains(WarlockChoiceService.pactOfTheTome)) {
      current.removeWhere(
        (entry) =>
            entry.startsWith(WarlockChoiceService.pactTomeCantripEntryPrefix) ||
            entry.startsWith(WarlockChoiceService.pactTomeRitualEntryPrefix),
      );
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setRogueArcaneTricksterCantrips(List<String> spellIndices) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) => entry.startsWith(
        RogueChoiceService.arcaneTricksterCantripEntryPrefix,
      ),
    );

    final uniqueSpells = <String>[];
    for (final spell in spellIndices) {
      final normalized = spell.trim();
      if (normalized.isEmpty ||
          normalized == RogueChoiceService.mageHandSpellId ||
          uniqueSpells.contains(normalized)) {
        continue;
      }
      uniqueSpells.add(normalized);
      if (uniqueSpells.length >=
          RogueChoiceService.arcaneTricksterCantripCount(
              _notifierState.level)) {
        break;
      }
    }

    for (final spell in uniqueSpells) {
      current.add(
        '${RogueChoiceService.arcaneTricksterCantripEntryPrefix}$spell',
      );
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setClericKnowledgeSkills(List<String> skillIndices) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) => entry.startsWith(ClericChoiceService.knowledgeSkillPrefix),
    );

    final uniqueSkills = <String>[];
    for (final skill in skillIndices) {
      final normalized = skill.trim();
      if (!ClericChoiceService.knowledgeSkillOptions.contains(normalized) ||
          uniqueSkills.contains(normalized)) {
        continue;
      }
      uniqueSkills.add(normalized);
      if (uniqueSkills.length >= ClericChoiceService.knowledgeSkillCount) {
        break;
      }
    }

    for (final skill in uniqueSkills) {
      current.add('${ClericChoiceService.knowledgeSkillPrefix}$skill');
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setClericKnowledgeTool(String tool) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) => entry.startsWith(ClericChoiceService.knowledgeToolPrefix),
    );

    final normalized = tool.trim();
    if (ClericChoiceService.artisanToolOptions.contains(normalized)) {
      current.add('${ClericChoiceService.knowledgeToolPrefix}$normalized');
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setArtificerSkillChoices(List<String> skillIndices) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) => entry.startsWith(ArtificerChoiceService.skillEntryPrefix),
    );

    final uniqueSkills = <String>[];
    for (final skill in skillIndices) {
      final normalized = skill.trim();
      if (normalized.isEmpty ||
          uniqueSkills.contains(normalized) ||
          !ArtificerChoiceService.skillOptions.contains(normalized)) {
        continue;
      }
      uniqueSkills.add(normalized);
      if (uniqueSkills.length >= ArtificerChoiceService.skillSelectionCount) {
        break;
      }
    }

    for (final skill in uniqueSkills) {
      current.add('${ArtificerChoiceService.skillEntryPrefix}$skill');
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setArtificerArtisanTool(String tool) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) => entry.startsWith(
        ArtificerChoiceService.artisanToolEntryPrefix,
      ),
    );

    final normalized = tool.trim();
    if (ArtificerChoiceService.selectableArtisanToolOptions
        .contains(normalized)) {
      current.add(
        '${ArtificerChoiceService.artisanToolEntryPrefix}$normalized',
      );
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setRogueArcaneTricksterSpells(List<String> spellIndices) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) => entry.startsWith(
        RogueChoiceService.arcaneTricksterSpellEntryPrefix,
      ),
    );

    final uniqueSpells = <String>[];
    for (final spell in spellIndices) {
      final normalized = spell.trim();
      if (normalized.isEmpty || uniqueSpells.contains(normalized)) {
        continue;
      }
      uniqueSpells.add(normalized);
      if (uniqueSpells.length >=
          RogueChoiceService.arcaneTricksterPreparedSpellCount(
              _notifierState.level)) {
        break;
      }
    }

    for (final spell in uniqueSpells) {
      current.add(
        '${RogueChoiceService.arcaneTricksterSpellEntryPrefix}$spell',
      );
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setRogueScionDreadAllegiance(String allegianceId) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) => entry.startsWith(
        RogueChoiceService.scionDreadAllegianceEntryPrefix,
      ),
    );

    final normalized = allegianceId.trim().toLowerCase();
    if (RogueChoiceService.isScionAllegianceId(normalized)) {
      current.add(
        '${RogueChoiceService.scionDreadAllegianceEntryPrefix}$normalized',
      );
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setWarlockMysticArcanum({
    required int spellLevel,
    required String spellIndex,
  }) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    final prefix =
        '${WarlockChoiceService.mysticArcanumEntryPrefix}$spellLevel:';
    current.removeWhere((entry) => entry.startsWith(prefix));

    final normalized = spellIndex.trim();
    if (normalized.isNotEmpty &&
        WarlockChoiceService.mysticArcanumSpellLevels(_notifierState.level)
            .contains(spellLevel)) {
      current.add('$prefix$normalized');
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setWarlockPactTomeCantrips(List<String> spellIndices) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) =>
          entry.startsWith(WarlockChoiceService.pactTomeCantripEntryPrefix),
    );

    final uniqueSpells = <String>[];
    for (final spell in spellIndices) {
      final normalized = spell.trim();
      if (normalized.isEmpty || uniqueSpells.contains(normalized)) {
        continue;
      }
      uniqueSpells.add(normalized);
      if (uniqueSpells.length >= WarlockChoiceService.pactTomeCantripCount) {
        break;
      }
    }

    for (final spell in uniqueSpells) {
      current.add('${WarlockChoiceService.pactTomeCantripEntryPrefix}$spell');
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }

  void setWarlockPactTomeRituals(List<String> spellIndices) {
    final current = List<String>.from(_notifierState.levelAdvancements);
    current.removeWhere(
      (entry) =>
          entry.startsWith(WarlockChoiceService.pactTomeRitualEntryPrefix),
    );

    final uniqueSpells = <String>[];
    for (final spell in spellIndices) {
      final normalized = spell.trim();
      if (normalized.isEmpty || uniqueSpells.contains(normalized)) {
        continue;
      }
      uniqueSpells.add(normalized);
      if (uniqueSpells.length >= WarlockChoiceService.pactTomeRitualCount) {
        break;
      }
    }

    for (final spell in uniqueSpells) {
      current.add('${WarlockChoiceService.pactTomeRitualEntryPrefix}$spell');
    }

    _notifierState = _notifierState.copyWith(levelAdvancements: current);
  }
}
