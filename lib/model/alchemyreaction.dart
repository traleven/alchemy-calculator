import 'dart:collection';
//import 'dart:async';

import 'package:flutter/material.dart';

import 'alchemyoperations.dart';
import 'workbench.dart';
import 'reactant.dart';
import 'shelf.dart';

class AlchemyReaction extends ChangeNotifier {
  factory AlchemyReaction({required Shelf shelf}) {
    if (!_cache.containsKey(shelf.title)) {
      _cache[shelf.title] = AlchemyReaction._create(shelf: shelf);
    }
    return _cache[shelf.title]!;
  }

  AlchemyReaction._create({required Shelf shelf}) : _shelf = shelf;

  static final Map<String, AlchemyReaction> _cache = {};

  final Shelf _shelf;

  final List<String> _log = [];

  Iterable<String> get log => _log;

  void call(Workbench workbench, Shelf shelf) {
    var chain = workbench.blocks;
    if (chain.isEmpty || !chain.first.hasOperation) return;
    var log = "";

    try {
      Iterable<CatalystChain>? reactionPath;

      for (int i = 0, n = chain.length; i < n && chain[i].hasOperation; ++i) {
        final substance = chain[i].base!;
        final catalyst = chain[i].catalyst!;
        final operation = chain[i].operation!;
        log += '(${substance.displayName}) + (${catalyst.displayName}) =[${operation.displayName}]=> ';

        // Natural reaction
        if (operation.stage < 0) {
          final child = _directReaction(substance: substance, catalyst: catalyst, operation: operation, shelf: shelf);
          log += '${child.displayName}\n';
          chain = _progress(workbench, i + 1, child);
          // Concoct brewing
        } else if (substance.stage == 0 && substance.potion != null) {
          final child = _concoctReaction(substance: substance, catalyst: catalyst, operation: operation);
          log += '${child.displayName}\n';
          chain = _progress(workbench, i + 1, child);
          // Reverse reaction
        } else if (operation.fullStage == substance.fullStage) {
          reactionPath = _filterReactionPaths(reactionPath,
              substance: substance, catalyst: catalyst, operation: operation, shelf: shelf);

          if (null == reactionPath || reactionPath.isEmpty) {
            chain = _progress(workbench, i + 1, const Reactant.shit());
            log += '${const Reactant.shit().displayName}\n';
          } else {
            var result = _reverseReaction(substance: substance, catalyst: catalyst, operation: operation, shelf: shelf);
            bool toPater = reactionPath.first.toPater;
            reactionPath = _resetPath(path: reactionPath, substance: result);
            result = _transmute(substance: result, toPater: toPater);
            log += result.displayName;
            if (result.isPotion) {
              log += ' ${Shelf.buildPotionEffect(result)}';
            }
            log += '\n';
            chain = _progress(workbench, i + 1, result);
          }
        } else {
          chain = _progress(workbench, i + 1, const Reactant.shit());
          log += '${const Reactant.shit().displayName}\n';
        }
      }
    } finally {
      _log.insert(0, log);
      notifyListeners();
    }
  }

  Reactant _directReaction({
    required Reactant substance,
    required Reactant catalyst,
    required AlchemyOperation operation,
    required Shelf shelf,
  }) {
    if (operation.regnum.isNotEmpty && operation.regnum != substance.regnum) return const Reactant.shit();
    if (!operation.acceptSubstance(substance, shelf) || !operation.acceptCatalyst(catalyst, shelf)) {
      return const Reactant.shit();
    }

    final child = _shelf.findReactantWhere((reactant) => reactant.isChildOf(substance.nomen, catalyst.nomen)) ??
        const Reactant.shit();
    return child;
  }

  Reactant _concoctReaction({
    required Reactant substance,
    required Reactant catalyst,
    required AlchemyOperation operation,
  }) {
    if (substance.potion == null || catalyst.potion == null) return const Reactant.shit();

    return substance;
  }

  Iterable<CatalystChain>? _filterReactionPaths(
    Iterable<CatalystChain>? reactionPath, {
    required Reactant substance,
    required Reactant catalyst,
    required AlchemyOperation operation,
    required Shelf shelf,
  }) {
    if (substance.stage == 0 && null == reactionPath) {
      reactionPath = _shelf.findAllCatalystChains((chain) => chain.initial.includes(substance.group));
    }
    return reactionPath?.where((chain) => chain.stages[operation.fullStage].includes(catalyst.group));
  }

  Reactant _reverseReaction({
    required Reactant substance,
    required Reactant catalyst,
    required AlchemyOperation operation,
    required Shelf shelf,
  }) {
    if (substance.color != catalyst.color) return const Reactant.shit();

    if (Shelf.checkSupport(regnum: catalyst.regnum, supports: substance.regnum)) return const Reactant.shit();
    if (!operation.acceptSubstance(substance, shelf) || !operation.acceptCatalyst(catalyst, shelf)) {
      return const Reactant.shit();
    }

    if (!Shelf.sameRegnum([substance.regnum, catalyst.regnum]) && substance.stage == 0 && substance.potion == null) {
      substance = substance.withValues(potion: Potion(regnum: operation.regnum), solid: operation.resultState);
    }
    if (substance.potion == null) {
      // Not a potiohn
      if (!Shelf.sameRegnum([substance.regnum, catalyst.regnum, operation.regnum])) return const Reactant.shit();
      return substance.withValues(stage: substance.stage + 2, solid: operation.resultState);
    } else {
      // Potion
      if (Shelf.sameRegnum([substance.regnum, catalyst.regnum])) return const Reactant.shit();
      return substance.withValues(stage: substance.stage + 2, regnum: catalyst.regnum, solid: operation.resultState);
    }
  }

  Iterable<CatalystChain>? _resetPath({required Iterable<CatalystChain>? path, required Reactant substance}) {
    return substance.stage < 6 ? path : null;
  }

  Reactant _transmute({required Reactant substance, required bool toPater}) {
    return (substance.stage < 6
            ? substance
            : substance.potion != null
                ? substance.withValues(stage: 0, elixir: toPater)
                : _shelf.findReactant(toPater ? substance.pater : substance.mater)) ??
        const Reactant.shit();
  }

  UnmodifiableListView<Block> _progress(Workbench workbench, int i, Reactant? substance) {
    while (workbench.blocks.length <= i) {
      workbench.pushBlock();
    }
    workbench[i]?.base = substance;
    return workbench.blocks;
  }

  void clearLog() {
    _log.clear();
    notifyListeners();
  }
}
