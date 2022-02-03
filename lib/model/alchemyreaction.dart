/// Alchemy Calculator provides interactive insight into the playable alchemy
/// model developed by traleven and satharis.
/// Copyright (C) 2022  traleven
///
/// This program is free software: you can redistribute it and/or modify
/// it under the terms of the GNU General Public License as published by
/// the Free Software Foundation, either version 3 of the License, or
/// (at your option) any later version.
///
/// This program is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program.  If not, see <https://www.gnu.org/licenses/>.

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

  void call(Workbench workbench) {
    var chain = workbench.blocks;
    if (chain.isEmpty || !chain.first.hasOperation) return;
    var log = '';

    try {
      Iterable<CatalystChain>? reactionPath;

      for (int i = 0, n = chain.length; i < n && chain[i].hasOperation; ++i) {
        final substance = chain[i].base!;
        final catalyst = chain[i].catalyst!;
        final operation = chain[i].operation!;
        log += '${operation.regnum.regnumSymbol} ';
        log += '(${substance.displayName}) + (${catalyst.displayName}) =[${operation.displayName}]=> ';

        // Natural reaction
        if (operation.stage < 0) {
          final child = _directReaction(substance: substance, catalyst: catalyst, operation: operation);
          log += '${child.displayName}\n';
          chain = _progress(workbench, i + 1, child);
          // Concoct brewing
        } else if (substance.isPotion) {
          final result = _concoctReaction(substance: substance, catalyst: catalyst, operation: operation);
          log += result.displayName;
          if (result.isPotion) {
            log += '\n';
            log += result.fullPotionEffect.replaceAll('\n\n', '\t').replaceAll('\n', '; ').replaceAll('\t', '\n');
            _shelf.registerPotion(result);
          }
          log += '\n';
          chain = _progress(workbench, i + 1, result);
          // Reverse reaction
        } else if (operation.fullStage == substance.fullStage) {
          reactionPath =
              _filterReactionPaths(reactionPath, substance: substance, catalyst: catalyst, operation: operation);

          if (null == reactionPath || reactionPath.isEmpty || catalyst.potion != null) {
            log += '${const Reactant.shit().displayName}\n';
            chain = _progress(workbench, i + 1, const Reactant.shit());
          } else if (substance.stage % 2 == 0 ||
              catalyst.colorDescription == substance.colorDescription ||
              chain[i - 1].catalyst?.colorDescription == substance.colorDescription) {
            var result = _reverseReaction(substance: substance, catalyst: catalyst, operation: operation);
            bool toPater = reactionPath.first.toPater;
            reactionPath = _resetPath(path: reactionPath, substance: result);
            result = _transmute(substance: result, toPater: toPater);
            log += result.displayName;
            if (result.isPotion) {
              log += '\n';
              log += result.fullPotionEffect.replaceAll('\n', '; ');
              _shelf.registerPotion(result);
            }
            log += '\n';
            chain = _progress(workbench, i + 1, result);
          } else {
            log += '${const Reactant.shit().displayName}\n';
            chain = _progress(workbench, i + 1, const Reactant.shit());
          }
        } else {
          log += '${const Reactant.shit().displayName}\n';
          chain = _progress(workbench, i + 1, const Reactant.shit());
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
  }) {
    if (operation.regnum.isNotEmpty && operation.regnum != substance.regnum) return const Reactant.shit();

    final child = _shelf.findReactantWhere((reactant) => reactant.isChildOf(substance.nomen, catalyst.nomen));
    if (child == null) return const Reactant.shit();

    Reactant? pater = _shelf.findReactant(child.pater);
    Reactant? mater = _shelf.findReactant(child.mater);
    if (pater == null || mater == null) return const Reactant.shit();

    if (!operation.acceptSubstance(pater, _shelf) || !operation.acceptCatalyst(mater, _shelf)) {
      return const Reactant.shit();
    }
    return child;
  }

  Reactant _concoctReaction({
    required Reactant substance,
    required Reactant catalyst,
    required AlchemyOperation operation,
  }) {
    if (!substance.isPotion || !catalyst.isPotion || catalyst is Concoct) return const Reactant.shit();
    if (!operation.acceptSubstance(substance, _shelf) || !operation.acceptCatalyst(catalyst, _shelf)) {
      return const Reactant.shit();
    }

    final concoct = substance.concoct().withValues(solid: operation.resultState);
    if (!Shelf.sameRegnum([concoct.regnum, catalyst.potion!.regnum, operation.regnum])) return const Reactant.shit();
    if (!Shelf.checkSupport(regnum: catalyst.regnum, supports: concoct.potions.last.regnum)) {
      return const Reactant.shit();
    }
    final result = concoct.merge(catalyst);
    if (result.potions.length > 3) return const Reactant.shit();
    final principles = result.potions.map((e) => e.potion!.principle).toSet();
    if (result.potions.length != principles.length) return const Reactant.shit();
    final aspects = result.potions.map((e) => '${e.colorDescription?.symbol}${e.groupId}');
    if (result.potions.length != aspects.length) return const Reactant.shit();

    return result;
  }

  Iterable<CatalystChain>? _filterReactionPaths(
    Iterable<CatalystChain>? reactionPath, {
    required Reactant substance,
    required Reactant catalyst,
    required AlchemyOperation operation,
  }) {
    if (substance.stage == 0 && null == reactionPath) {
      reactionPath = _shelf.findAllCatalystChains((chain) => chain.initial.includes(substance.group));
    }
    reactionPath = reactionPath?.where((chain) => chain.stages[operation.fullStage].includes(catalyst.group));
    final step = evaluateStep(substance: substance, catalyst: catalyst);
    if (step == 0) return null;
    if (step == 2) return (substance.stage % 2 == 0) ? reactionPath : null;

    return reactionPath?.where((chain) => ((step > 0) == chain.toPater) ^ (substance.stage % 2 != 0));
  }

  Reactant _reverseReaction({
    required Reactant substance,
    required Reactant catalyst,
    required AlchemyOperation operation,
  }) {
    final step = evaluateStep(substance: substance, catalyst: catalyst).abs();
    if (0 == step) return const Reactant.shit();

    if (Shelf.checkSupport(regnum: catalyst.regnum, supports: substance.regnum)) return const Reactant.shit();
    if (!operation.acceptSubstance(substance, _shelf) || !operation.acceptCatalyst(catalyst, _shelf)) {
      return const Reactant.shit();
    }

    if (!Shelf.sameRegnum([substance.regnum, catalyst.regnum]) && substance.stage == 0 && substance.potion == null) {
      substance = substance.withValues(potion: Potion(regnum: operation.regnum), solid: operation.resultState);
    }
    if (substance.potion == null) {
      // Not a potion
      if (!Shelf.sameRegnum([substance.regnum, catalyst.regnum, operation.regnum])) return const Reactant.shit();
      return substance.withValues(
        stage: substance.stage + step,
        solid: operation.resultState,
      );
    } else {
      // Potion
      if (Shelf.sameRegnum([substance.regnum, catalyst.regnum])) return const Reactant.shit();
      return substance.withValues(
        stage: substance.stage + step,
        regnum: ((substance.stage + step) % 2 == 0) ? catalyst.regnum : null,
        solid: operation.resultState,
      );
    }
  }

  int evaluateStep({required Reactant substance, required Reactant catalyst}) {
    if (null == catalyst.colorDescription) return 0;
    if (null == substance.colorDescription) return 0;

    var pater = catalyst.getPater(_shelf);
    var mater = catalyst.getMater(_shelf);

    if (null == pater?.colorDescription && null == mater?.colorDescription) {
      if (substance.colorDescription != catalyst.colorDescription) return 0;
      return 2;
    } else if (null != pater?.colorDescription && null != mater?.colorDescription) {
      if (pater?.colorDescription == mater?.colorDescription) {
        if (catalyst.colorDescription != substance.colorDescription) return 0;
        return 2;
      } else if (pater?.colorDescription == substance.colorDescription) {
        return 1; // to pater
      } else if (mater?.colorDescription == substance.colorDescription) {
        return -1; // to mater
      } else {
        return 0;
      }
    } else if (null != pater?.quality && null != mater?.colorDescription) {
      if (mater?.colorDescription == catalyst.colorDescription &&
          catalyst.colorDescription!.paterQuality == pater?.quality) {
        if (catalyst.colorDescription != substance.colorDescription) return 0;
        return 2;
      } else if (mater?.colorDescription == substance.colorDescription) {
        return -1; // to mater
      } else if (substance.colorDescription!.paterQuality == pater?.quality) {
        return 1; // to pater
      } else {
        return 0;
      }
    }
    return 0;
  }

  Iterable<CatalystChain>? _resetPath({required Iterable<CatalystChain>? path, required Reactant substance}) {
    return substance.stage < 6 ? path : null;
  }

  Reactant _transmute({required Reactant substance, required bool toPater}) {
    return (substance.stage < 6
            ? substance
            : substance.potion != null
                ? substance.withValues(
                    stage: 0,
                    elixir: toPater,
                    principle: _shelf.findPotionPrinciple(potion: substance, elixir: toPater)?.nomen,
                  )
                : toPater
                    ? substance.getPater(_shelf)
                    : substance.getMater(_shelf)) ??
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
