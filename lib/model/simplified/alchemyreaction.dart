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
  factory AlchemyReaction({required SimpleShelf shelf}) {
    if (!_cache.containsKey(shelf.title)) {
      _cache[shelf.title] = AlchemyReaction._create(shelf: shelf);
    }
    return _cache[shelf.title]!;
  }

  AlchemyReaction._create({required SimpleShelf shelf}) : _shelf = shelf;

  static final Map<String, AlchemyReaction> _cache = {};

  final SimpleShelf _shelf;

  final List<String> _log = [];

  Iterable<String> get log => _log;

  void call(SimpleWorkbench workbench) {
    var chain = workbench.blocks;
    if (chain.isEmpty || !chain.first.hasOperation) return;
    var log = '';

    try {
      Iterable<CatalystChain>? reactionPath;

      for (int i = 0, n = chain.length; i < n && chain[i].hasOperation; ++i) {
        final substance = chain[i].base!;
        final catalyst = chain[i].catalyst!;
        final operation = chain[i].operation!;
        log += '${operation.nature.natureSymbol} ';
        log += '(${substance.displayName}) + (${catalyst.displayName}) =[${operation.displayName}]=> ';

        // Concoct brewing
        if (substance.isPotion) {
          final result = _concoctReaction(substance: substance, catalyst: catalyst, operation: operation);
          log += result.displayName.replaceAll('\n', '; ');
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
            log += '${const SimpleReactant.shit().displayName}\n';
            chain = _progress(workbench, i + 1, const SimpleReactant.shit());
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
            log += '${const SimpleReactant.shit().displayName}\n';
            chain = _progress(workbench, i + 1, const SimpleReactant.shit());
          }
        } else {
          log += '${const SimpleReactant.shit().displayName}\n';
          chain = _progress(workbench, i + 1, const SimpleReactant.shit());
        }
      }
    } finally {
      _log.insert(0, log);
      notifyListeners();
    }
  }

  SimpleReactant _concoctReaction({
    required SimpleReactant substance,
    required SimpleReactant catalyst,
    required SimpleOperation operation,
  }) {
    if (!substance.isPotion || !catalyst.isPotion || catalyst is SimpleConcoct) return const SimpleReactant.shit();

    final concoct = substance.concoct();
    if (!SimpleShelf.checkSupport(nature: catalyst.nature, supports: concoct.potions.last.nature)) {
      return const SimpleReactant.shit();
    }
    final result = concoct.merge(catalyst);
    if (result.potions.length > 3) return const SimpleReactant.shit();
    final principles = result.potions.map((e) => e.potion!.principle).toSet();
    if (result.potions.length != principles.length) return const SimpleReactant.shit();
    final aspects = result.potions.map((e) => '${e.colorDescription?.symbol}${e.element.elementSymbol}');
    if (result.potions.length != aspects.length) return const SimpleReactant.shit();

    return result;
  }

  Iterable<CatalystChain>? _filterReactionPaths(
    Iterable<CatalystChain>? reactionPath, {
    required SimpleReactant substance,
    required SimpleReactant catalyst,
    required SimpleOperation operation,
  }) {
    if (substance.stage == 0 && null == reactionPath) {
      reactionPath = _shelf.findAllCatalystChains((chain) => chain.initial.includes(substance.element));
    }
    reactionPath = reactionPath?.where((chain) => chain.stages[operation.fullStage].includes(catalyst.element));
    final step = evaluateStep(substance: substance, catalyst: catalyst);
    if (step == 0) return null;
    if (step == 2) return (substance.stage % 2 == 0) ? reactionPath : null;

    return reactionPath?.where((chain) => ((step > 0) == chain.toPater) ^ (substance.stage % 2 != 0));
  }

  SimpleReactant _reverseReaction({
    required SimpleReactant substance,
    required SimpleReactant catalyst,
    required SimpleOperation operation,
  }) {
    final step = evaluateStep(substance: substance, catalyst: catalyst).abs();
    if (0 == step) return const SimpleReactant.shit();

    if (substance.stage == 0 && substance.potion == null) {
      substance = substance.withValues(potion: SimplePotion(nature: operation.nature));
    }
    if (substance.potion == null) {
      // Not a potion
      return const SimpleReactant.shit();
    } else {
      // Potion
      return substance.withValues(
        stage: substance.stage + step,
      );
    }
  }

  int evaluateStep({required SimpleReactant substance, required SimpleReactant catalyst}) {
    if (null == catalyst.colorDescription) return 0;
    if (null == substance.colorDescription) return 0;

    return 2;
  }

  Iterable<CatalystChain>? _resetPath({required Iterable<CatalystChain>? path, required SimpleReactant substance}) {
    return substance.stage < 6 ? path : null;
  }

  SimpleReactant _transmute({required SimpleReactant substance, required bool toPater}) {
    if (substance.potion == null) return const SimpleReactant.shit();
    return substance.stage < 6
        ? substance
        : substance.withValues(
            stage: 0,
            elixir: toPater,
            principle: _shelf.findPotionPrinciple(potion: substance, elixir: toPater)?.name,
          );
  }

  UnmodifiableListView<Block> _progress(SimpleWorkbench workbench, int i, SimpleReactant? substance) {
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
