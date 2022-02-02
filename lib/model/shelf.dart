import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

import 'alchemyoperations.dart';
import 'aspect.dart';
import 'colordescription.dart';
import 'reactant.dart';
import 'icons.dart';

class Shelf extends ChangeNotifier {
  Shelf(this.title) : super();
  final Map<String, Reactant> _data = {};
  final Set<AlchemyOperation> _operations = {};
  final Set<CatalystChain> _catalysts = {};
  final String title;

  final Set<String> _operationsRegnumFilter = {};
  final Set<int> _operationStageFilter = {};
  final Set<String> _reactantRegnumFilter = {};
  final Set<String> _reactantGroupFilter = {};
  final Set<Color> _reactantColorFilter = {};
  bool _reactantPotionFilter = false;

  final Map<String, Map<Color, List<Aspect>>> _aspects = {};

  static Iterable<String> regna = ['mineral', 'animal', 'herbal'];
  static const Map<String, String> _regnumSupport = {'mineral': 'herbal', 'animal': 'mineral', 'herbal': 'animal'};
  static const Map<String, String> _regnumNames = {
    'mineral': 'Минеральное царство',
    'animal': 'Животное царство',
    'herbal': 'Растительное царство',
    'potion': 'Зелья',
  };

  static final Map<int, Map<bool, Principle>> _principles = {
    // -1: {true: 'Separatio', false: 'Ceratio'},
    // 0: {true: 'Fixatio', false: 'Solutio'},
    // 1: {true: 'Coagulatio', false: 'Conjunctio'},
  };

  static final Map<Color, ColorDescription> _colorSymbols = {
    Colors.transparent: const ColorDescription(
      color: Colors.transparent,
      symbol: '',
      icon: null,
      name: '',
      description: [],
      paterQuality: -1,
      materQuality: -1,
    )
  };
  static final Map<String, List<String>> _signSymbols = {};
  static final Map<String, Shelf> _cache = {};

  static Future<Shelf> loadAsync(AssetBundle bundle, String fileName) async {
    if (!_cache.containsKey(fileName)) {
      var shelf = Shelf(fileName);
      await shelf.asyncInit(bundle, fileName);
      _cache[fileName] = shelf;
    }
    return _cache[fileName]!;
  }

  static Future<Shelf> loadAllAsync(AssetBundle bundle) async {
    if (!_cache.containsKey('')) {
      var shelf = Shelf('');
      await shelf.asyncInit(bundle, 'mineral');
      await shelf.asyncInit(bundle, 'animal');
      await shelf.asyncInit(bundle, 'herbal');
      _cache[''] = shelf;
    }
    return _cache['']!;
  }

  Future<void> asyncInit(AssetBundle bundle, String fileName) async {
    await AlchemyIcons.loadAsync(bundle);
    if (_colorSymbols.length == 1) {
      final nomenclatureJson = await bundle.loadString('recipies/nomenclature.json');
      Map<String, dynamic> data = jsonDecode(nomenclatureJson);
      data['colors'].forEach((value) {
        final color = Reactant.parseColor(value['color']);
        if (color != null) {
          _colorSymbols[color] = ColorDescription.fromJson(color, value);
        }
      });
      data['signs'].forEach((value) {
        _signSymbols[value['symbol']] = value['names'].cast<String>().toList();
      });
    }

    final json = await bundle.loadString('recipies/$fileName.json');
    Map<String, dynamic> data = jsonDecode(json);
    data["reactants"].forEach((value) {
      final reactant = Reactant.fromJson(this, fileName, value);
      _data[reactant.nomen] = reactant.withValues(
        groupId: groupIds.firstWhereOrNull((id) => reactant.group.contains(id)),
        colorDescription: _colorSymbols[reactant.color],
      );
    });

    if (operations.isEmpty) {
      final operationsJson = await bundle.loadString('recipies/operations.json');
      data = jsonDecode(operationsJson);
      data["operations"].forEach((value) {
        final operation = AlchemyOperation.fromJson(value);
        _operations.add(operation);
      });
      data["catalysts"].forEach((value) {
        final chain = CatalystChain.fromJson(value);
        _catalysts.add(chain);
      });
    }

    if (_principles.isEmpty) {
      final json = await bundle.loadString('recipies/potions.json');
      data = jsonDecode(json);
      data["principles"].forEach((value) {
        final principle = Principle.fromJson(value);
        _principles[principle.regnum] ??= {};
        _principles[principle.regnum]![principle.toPater] = principle;
      });
    }

    if (_aspects.isEmpty) {
      final json = await bundle.loadString('recipies/potions.json');
      data = jsonDecode(json);
      data["aspects"].forEach((value) {
        final aspect = Aspect.fromJson(value);
        _aspects[aspect.regnum] ??= {};
        _aspects[aspect.regnum]![aspect.color] ??= [];
        _aspects[aspect.regnum]![aspect.color]!.add(aspect);
      });
    }

    notifyListeners();
  }

  List<String> get groupIds {
    var result = _signSymbols.keys.toList(growable: false);
    result.sort();
    return result;
  }

  static String? getNameForGroup(String groupId) => _signSymbols[groupId]?.join('\n');
  static String? getIdForGroup(String groupName) =>
      _signSymbols.keys.firstWhereOrNull((sign) => groupName.contains(sign));

  List<Reactant> get reactants => _data.values.toList(growable: false);
  List<Reactant> get filteredReactants => _filteredReactants.toList(growable: false);

  List<ColorDescription> get colors => _colorSymbols.values.toList(growable: false);

  List<AlchemyOperation> get operations => _operations.toList(growable: false);
  List<AlchemyOperation> get filteredOperations {
    var result = _filteredOperations.toList(growable: false);
    result.sort();
    return result;
  }

  List<Reactant> getNamesForGroup(String? group) =>
      _data.values.where((element) => element.group == group).toList(growable: false);

  Reactant? findReactant(String? reactant) => _data[reactant];
  Reactant? findReactantWhere(bool Function(Reactant) predicate) => _data.values.firstWhereOrNull(predicate);
  AlchemyOperation? findOperation(String? operation) => _operations.firstWhereOrNull((op) => op.id == operation);
  CatalystChain? findCatalystChain(String initial, String nigredo) =>
      _catalysts.firstWhereOrNull((cat) => cat.initial.includes(initial) && cat.stages[0].includes(nigredo));
  Iterable<CatalystChain> findAllCatalystChains(bool Function(CatalystChain) predicate) => _catalysts.where(predicate);

  bool operationsRegnumFilterIncludes(String s) => _operationsRegnumFilter.contains(s);
  void setOperationsRegnumFilter(String s, bool active) {
    active ? _operationsRegnumFilter.add(s) : _operationsRegnumFilter.remove(s);
    notifyListeners();
  }

  bool operationsStageFilterIncludes(int i) => _operationStageFilter.contains(i);
  void setOperationStageFilter(int i, bool active) {
    active ? _operationStageFilter.add(i) : _operationStageFilter.remove(i);
    notifyListeners();
  }

  bool reactantRegnumFilterIncludes(String s) => _reactantRegnumFilter.contains(s);
  void setReactantRegnumFilter(String s, bool active) {
    active ? _reactantRegnumFilter.add(s) : _reactantRegnumFilter.remove(s);
    notifyListeners();
  }

  bool reactantGroupFilterIncludes(String s) => _reactantGroupFilter.contains(s);
  void setReactantGroupFilter(String s, bool active) {
    active ? _reactantGroupFilter.add(s) : _reactantGroupFilter.remove(s);
    notifyListeners();
  }

  bool reactantColorFilterIncludes(Color c) => _reactantColorFilter.contains(c);
  void setReactantColorFilter(Color c, bool active) {
    active ? _reactantColorFilter.add(c) : _reactantColorFilter.remove(c);
    notifyListeners();
  }

  bool reactantPotionFilterIncludes() => _reactantPotionFilter;
  void setReactantPotionFilter(bool active) {
    _reactantPotionFilter = active;
    notifyListeners();
  }

  Iterable<AlchemyOperation> get _filteredOperations {
    return _operations.where((e) =>
        (_operationsRegnumFilter.isEmpty || e.regnum.isEmpty || _operationsRegnumFilter.contains(e.regnum)) &&
        (_operationStageFilter.isEmpty || _operationStageFilter.contains(e.fullStage)));
  }

  Iterable<Reactant> get _filteredReactants {
    return _data.values.where((e) =>
        (_reactantPotionFilter == e.isPotion) &&
        (_reactantRegnumFilter.isEmpty || _getRegnum(e).isEmpty || _reactantRegnumFilter.contains(_getRegnum(e))) &&
        (_reactantGroupFilter.isEmpty || e.group.isEmpty || _reactantGroupFilter.any((id) => e.group.contains(id))) &&
        (_reactantColorFilter.isEmpty ||
            _reactantColorFilter.contains(e.color) ||
            (e.color == null && _reactantColorFilter.contains(Colors.transparent))));
  }

  static String _getRegnum(Reactant reactant) => reactant.potion?.regnum ?? reactant.regnum;

  void registerPotion(Reactant reactant) {
    if (reactant.isPotion) {
      _data[reactant.displayNomen] = reactant;
      notifyListeners();
    }
  }

  static bool checkSupport({required String regnum, required String supports}) {
    return _regnumSupport[regnum] == supports;
  }

  static bool sameRegnum(List<String> list) {
    String? regnum = list.firstWhereOrNull((element) => element.isNotEmpty);
    return regnum == null || list.every((element) => element.isEmpty || element == regnum);
  }

  String buildPotionEffect(Reactant reactant) {
    if (!reactant.isPotion) return 'Гажа';
    Principle? principle = findPrinciple(
        potionRegnum: reactant.potion!.regnum, substanceRegnum: reactant.regnum, elixir: reactant.potion!.isElixir!);
    return '${reactant.potion!.regnum.regnumSymbol}${reactant.potion!.displayPrincipleDirection} ${principle?.nomen} ${reactant.colorDescription?.symbol}${reactant.groupId}';
  }

  String buildFullPotionEffect(Reactant reactant) {
    if (!reactant.isPotion) return 'Гажа';
    Principle? principle = findPrinciple(
        potionRegnum: reactant.potion!.regnum, substanceRegnum: reactant.regnum, elixir: reactant.potion!.isElixir!);
    Aspect? aspect = findAspect(
        regnum: reactant.potion!.regnum, color: reactant.color ?? Colors.transparent, groupId: reactant.groupId);
    return 'Цель: ${reactant.potion!.regnum.regnumName}\n'
        'База: ${reactant.regnum.regnumName}, ${reactant.name}, ${reactant.nomen}\n'
        'Принцип: ${reactant.potion!.displayPrincipleDirection} ${principle?.nomen} (${principle?.description[reactant.potion!.regnum]})\n'
        'Аспект: ${reactant.colorDescription?.symbol}${reactant.groupId} (${aspect?.name})';
  }

  Principle? findPrinciple({required String potionRegnum, required String substanceRegnum, required bool elixir}) {
    final relative = substanceRegnum.regnumRelativeTo(potionRegnum) ?? -2;
    return _principles[relative]?[elixir];
  }

  Principle? findPotionPrinciple({required Reactant potion, bool? elixir}) {
    if (potion.potion == null) return null;
    if (null == elixir && null == potion.potion?.isElixir) return null;
    return findPrinciple(
      potionRegnum: potion.potion!.regnum,
      substanceRegnum: potion.regnum,
      elixir: elixir ?? potion.potion!.isElixir!,
    );
  }

  Aspect? findAspect({required String regnum, required Color color, required String groupId}) =>
      _aspects[regnum]?[color]?.firstWhereOrNull((aspect) => aspect.sign.contains(groupId));
}

class Principle {
  const Principle({
    required this.regnum,
    required this.nomen,
    required this.name,
    required this.description,
    required this.toPater,
  });

  Principle.fromJson(dynamic map) : this.fromMap(map);

  Principle.fromMap(Map<String, dynamic> map)
      : this(
          regnum: map['regnum'],
          nomen: map['nomen'],
          name: map['name'],
          description: Map.fromIterables(Shelf.regna, map['description'].cast<String>()),
          toPater: map['toPater'],
        );

  final int regnum;
  final String nomen;
  final String name;
  final bool toPater;
  final Map<String, String> description;
}

extension StringConversions on String {
  String get regnumName {
    return Shelf._regnumNames[this] ?? this;
  }

  AssetImage? get regnumIcon {
    return AlchemyIcons.named(this == 'potion' ? 'icon_$this' : 'icon_realm_$this');
  }

  int? regnumRelativeTo(String referenceRegnum) {
    if (Shelf.checkSupport(regnum: this, supports: referenceRegnum)) return 1;
    if (Shelf.checkSupport(regnum: referenceRegnum, supports: this)) return -1;
    if (Shelf.sameRegnum([this, referenceRegnum])) return 0;
    return null;
  }
}
