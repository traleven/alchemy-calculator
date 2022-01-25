import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

import 'alchemyoperations.dart';
import 'reactant.dart';

class Shelf extends ChangeNotifier {
  Shelf(this.title) : super();
  final Map<String, Reactant> _data = {};
  final Set<Color> _colors = {Colors.transparent};
  final Set<AlchemyOperation> _operations = {};
  final Set<CatalystChain> _catalysts = {};
  final String title;

  final Set<String> _operationsRegnumFilter = {};
  final Set<int> _operationStageFilter = {};
  final Set<String> _reactantRegnumFilter = {};
  final Set<String> _reactantGroupFilter = {};
  final Set<Color> _reactantColorFilter = {};
  bool _reactantPotionFilter = false;

  static Iterable<String> regna = ['mineral', 'animal', 'herbal'];
  static const Map<String, String> _regnumSupport = {'mineral': 'herbal', 'animal': 'mineral', 'herbal': 'animal'};
  static const Map<String, String> _regnumNames = {
    'mineral': 'Минеральное царство',
    'animal': 'Животное царство',
    'herbal': 'Растительное царство',
    'potion': 'Зелья',
  };

  static const Map<String, Map<String, Map<bool, String>>> _principles = {
    'mineral': {
      'mineral': {true: 'Fixatio', false: 'Solutio'},
      'animal': {true: 'Coagulatio', false: 'Conjunctio'},
      'herbal': {true: 'Separatio', false: 'Ceratio'}
    },
    'animal': {
      'mineral': {true: 'Separatio', false: 'Ceratio'},
      'animal': {true: 'Fixatio', false: 'Solutio'},
      'herbal': {true: 'Coagulatio', false: 'Conjunctio'}
    },
    'herbal': {
      'mineral': {true: 'Coagulatio', false: 'Conjunctio'},
      'animal': {true: 'Separatio', false: 'Ceratio'},
      'herbal': {true: 'Fixatio', false: 'Solutio'}
    }
  };

  static final Map<Color, ColorDescription> _colorSymbols = {};
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
    if (_colorSymbols.isEmpty) {
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
      final reactant = Reactant.fromJson(fileName, value);
      _data[reactant.nomen] = reactant.withValues(
        groupId: groupIds.firstWhereOrNull((id) => reactant.group.contains(id)),
        colorDescription: _colorSymbols[reactant.color],
      );
      if (reactant.color != null) {
        _colors.add(reactant.color!);
      }
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
        (_operationStageFilter.isEmpty || _operationStageFilter.contains(e.stage)));
  }

  Iterable<Reactant> get _filteredReactants {
    return _data.values.where((e) =>
        (!_reactantPotionFilter || e.potion != null) &&
        (_reactantRegnumFilter.isEmpty || e.regnum.isEmpty || _reactantRegnumFilter.contains(e.regnum)) &&
        (_reactantGroupFilter.isEmpty || e.group.isEmpty || _reactantGroupFilter.any((id) => e.group.contains(id))) &&
        (_reactantColorFilter.isEmpty ||
            _reactantColorFilter.contains(e.color) ||
            (e.color == null && _reactantColorFilter.contains(Colors.transparent))));
  }

  static bool checkSupport({required String regnum, required String supports}) {
    return _regnumSupport[regnum] == supports;
  }

  static bool sameRegnum(List<String> list) {
    String? regnum = list.firstWhereOrNull((element) => element.isNotEmpty);
    return regnum == null || list.every((element) => element.isEmpty || element == regnum);
  }

  static String buildPotionEffect(Reactant reactant) {
    if (!reactant.isPotion) return 'Гажа';
    String? principle = _principles[reactant.potion!.regnum]?[reactant.regnum]?[reactant.potion!.isElixir];
    return 'Принцип: $principle; Аспект: ${getIdForGroup(reactant.group)}';
  }
}

class ColorDescription {
  const ColorDescription({required this.color, required this.symbol, required this.name, required this.description});

  ColorDescription.fromJson(Color color, dynamic map) : this.fromMap(color, map);

  ColorDescription.fromMap(Color color, Map<String, dynamic> map)
      : this(
          color: color,
          symbol: map["symbol"],
          name: map["name"],
          description: map["description"].cast<String>().toList(growable: false),
        );

  final Color color;
  final String symbol;
  final String name;
  final List<String> description;
}

extension StringConversions on String {
  String get regnumName {
    return Shelf._regnumNames[this] ?? this;
  }
}
