import 'package:alchemy_calculator/model/icons.dart';
import 'package:alchemy_calculator/model/colordescription.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

import 'alchemyoperations.dart';
import 'aspect.dart';
import 'reactant.dart';

class SimpleShelf extends ChangeNotifier {
  SimpleShelf(this.title) : super();
  final Map<String, SimpleReactant> _data = {};
  final Set<SimpleOperation> _operations = {};
  final Set<CatalystChain> _catalysts = {};
  final String title;

  final Set<String> _operationsNatureFilter = {};
  final Set<int> _operationStageFilter = {};
  final Set<String> _reactantElementFilter = {};
  final Set<String> _reactantColorFilter = {};
  bool _reactantPotionFilter = false;

  final Map<String, Map<String, SimpleAspect>> _aspects = {};

  static final Map<String, Map<bool, SimplePrinciple>> _principles = {};

  static final Map<Color, ColorDescription> _colorSymbols = {};
  static final Map<String, List<String>> _signSymbols = {};
  static final Map<String, SimpleShelf> _cache = {};
  static const Map<String, String> _natureSupport = {'Соль': 'Меркурий', 'Меркурий': 'Сульфур', 'Сульфур': 'Соль'};

  static const List<String> natures = ['Сульфур', 'Меркурий', 'Соль'];
  static const List<String> elements = ['Огонь', 'Воздух', 'Вода', 'Земля'];

  static Future<SimpleShelf> loadAsync(AssetBundle bundle, String fileName) async {
    if (!_cache.containsKey(fileName)) {
      var shelf = SimpleShelf(fileName);
      await shelf.asyncInit(bundle, fileName);
      _cache[fileName] = shelf;
    }
    return _cache[fileName]!;
  }

  static Future<SimpleShelf> loadAllAsync(AssetBundle bundle) async {
    if (!_cache.containsKey('')) {
      var shelf = SimpleShelf('');
      await shelf.asyncInit(bundle, 'simplified');
      _cache[''] = shelf;
    }
    return _cache['']!;
  }

  Future<void> asyncInit(AssetBundle bundle, String fileName) async {
    await AlchemyIcons.loadAsync(bundle);
    if (_colorSymbols.length <= 1) {
      final nomenclatureJson = await bundle.loadString('recipies/nomenclature.json');
      Map<String, dynamic> data = jsonDecode(nomenclatureJson);
      data['colors'].forEach((value) {
        final color = SimpleReactant.parseColor(value['color']);
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
      final reactant = SimpleReactant.fromJson(this, value);
      _data[reactant.name] = reactant.withValues(
        colorDescription: _colorSymbols[reactant.color?.namedColor],
      );
    });

    data["operations"].forEach((value) {
      final operation = SimpleOperation.fromJson(value);
      _operations.add(operation);
    });

    data["catalysts"].forEach((value) {
      final chain = CatalystChain.fromJson(value);
      _catalysts.add(chain);
    });

    data["principles"].forEach((value) {
      final principle = SimplePrinciple.fromJson(value);
      _principles[principle.nature] ??= {};
      _principles[principle.nature]![principle.toPater] = principle;
    });

    data["aspects"].forEach((value) {
      final aspect = SimpleAspect.fromJson(value);
      _aspects[aspect.element] ??= {};
      _aspects[aspect.element]![aspect.color] = aspect;
    });

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

  List<SimpleReactant> get reactants => _data.values.toList(growable: false);
  List<SimpleReactant> get filteredReactants => _filteredReactants.toList(growable: false);

  List<ColorDescription> get colors => _colorSymbols.values.toList(growable: false);

  List<SimpleOperation> get operations => _operations.toList(growable: false);
  List<SimpleOperation> get filteredOperations {
    var result = _filteredOperations.toList(growable: false);
    result.sort();
    return result;
  }

  SimpleReactant? findReactant(String? reactant) => _data[reactant];
  SimpleReactant? findReactantWhere(bool Function(SimpleReactant) predicate) =>
      _data.values.firstWhereOrNull(predicate);
  SimpleOperation? findOperation(String? operation) => _operations.firstWhereOrNull((op) => op.id == operation);
  CatalystChain? findCatalystChain(String initial, String nigredo) =>
      _catalysts.firstWhereOrNull((cat) => cat.initial.includes(initial) && cat.stages[0].includes(nigredo));
  Iterable<CatalystChain> findAllCatalystChains(bool Function(CatalystChain) predicate) => _catalysts.where(predicate);

  bool operationsNatureFilterIncludes(String s) => _operationsNatureFilter.contains(s);
  void setOperationsNatureFilter(String s, bool active) {
    active ? _operationsNatureFilter.add(s) : _operationsNatureFilter.remove(s);
    notifyListeners();
  }

  bool operationsStageFilterIncludes(int i) => _operationStageFilter.contains(i);
  void setOperationStageFilter(int i, bool active) {
    active ? _operationStageFilter.add(i) : _operationStageFilter.remove(i);
    notifyListeners();
  }

  bool reactantElementFilterIncludes(String s) => _reactantElementFilter.contains(s);
  void setReactantElementFilter(String s, bool active) {
    active ? _reactantElementFilter.add(s) : _reactantElementFilter.remove(s);
    notifyListeners();
  }

  bool reactantColorFilterIncludes(String c) => _reactantColorFilter.contains(c);
  void setReactantColorFilter(String c, bool active) {
    active ? _reactantColorFilter.add(c) : _reactantColorFilter.remove(c);
    notifyListeners();
  }

  bool reactantPotionFilterIncludes() => _reactantPotionFilter;
  void setReactantPotionFilter(bool active) {
    _reactantPotionFilter = active;
    notifyListeners();
  }

  Iterable<SimpleOperation> get _filteredOperations {
    return _operations.where((e) =>
        (_operationsNatureFilter.isEmpty || e.nature.isEmpty || _operationsNatureFilter.contains(e.nature)) &&
        (_operationStageFilter.isEmpty || _operationStageFilter.contains(e.fullStage)));
  }

  Iterable<SimpleReactant> get _filteredReactants {
    return _data.values.where((e) =>
        (_reactantPotionFilter == e.isPotion) &&
        (_reactantElementFilter.isEmpty || e.element.isEmpty || _reactantElementFilter.contains(e.element)) &&
        (_reactantColorFilter.isEmpty || _reactantColorFilter.contains(e.colorDescription?.name) || e.color == null));
  }

  void registerPotion(SimpleReactant reactant) {
    if (reactant.isPotion) {
      _data[reactant.displayNomen] = reactant;
      notifyListeners();
    }
  }

  static bool checkSupport({required String? nature, required String? supports}) {
    return _natureSupport[nature] == supports;
  }

  static bool sameRegnum(List<String> list) {
    String? regnum = list.firstWhereOrNull((element) => element.isNotEmpty);
    return regnum == null || list.every((element) => element.isEmpty || element == regnum);
  }

  String buildPotionEffect(SimpleReactant reactant) {
    if (!reactant.isPotion) return 'Гажа';
    SimplePrinciple? principle =
        findPrinciple(potionNature: reactant.potion!.nature, elixir: reactant.potion!.isElixir!);
    SimpleAspect? aspect = findAspect(element: reactant.element, color: reactant.color);
    return '${principle?.name}: ${aspect?.name}';
  }

  String buildFullPotionEffect(SimpleReactant reactant) {
    if (!reactant.isPotion) return 'Гажа';
    SimplePrinciple? principle =
        findPrinciple(potionNature: reactant.potion!.nature, elixir: reactant.potion!.isElixir!);
    SimpleAspect? aspect = findAspect(element: reactant.element, color: reactant.color);
    return 'База: ${reactant.element}, ${reactant.name}\n'
        'Природа: ${reactant.nature}\n'
        'Принцип: ${reactant.nature?.natureSymbol}${reactant.potion!.displayPrincipleDirection} ${principle?.name}\n'
        'Аспект: ${reactant.colorDescription?.symbol}${reactant.element.elementSymbol} (${aspect?.name})';
  }

  SimplePrinciple? findPrinciple({required String potionNature, required bool elixir}) {
    return _principles[potionNature]?[elixir];
  }

  SimplePrinciple? findPotionPrinciple({required SimpleReactant potion, bool? elixir}) {
    if (potion.potion == null) return null;
    if (null == elixir && null == potion.potion?.isElixir) return null;
    return findPrinciple(
      potionNature: potion.potion!.nature,
      elixir: elixir ?? potion.potion!.isElixir!,
    );
  }

  SimpleAspect? findAspect({required String element, required String? color}) => _aspects[element]?[color];
}

class SimplePrinciple {
  const SimplePrinciple({
    required this.nature,
    required this.name,
    required this.toPater,
  });

  SimplePrinciple.fromJson(dynamic map) : this.fromMap(map);

  SimplePrinciple.fromMap(Map<String, dynamic> map)
      : this(
          nature: map['nature'],
          name: map['name'],
          toPater: map['toPater'],
        );

  final String nature;
  final String name;
  final bool toPater;
}

extension StringConversions on String {
  AssetImage? get regnumIcon {
    return AlchemyIcons.named(this == 'potion' ? 'icon_$this' : 'icon_realm_$this');
  }

  AssetImage? get natureIcon {
    switch (this) {
      case 'Сульфур':
        return AlchemyIcons.named('icon_matter_sulphur');
      case 'Меркурий':
        return AlchemyIcons.named('icon_matter_mercury');
      case 'Соль':
        return AlchemyIcons.named('icon_matter_salt');
    }
    return null;
  }

  AssetImage? get elementIcon {
    switch (this) {
      case 'Огонь':
        return AlchemyIcons.named('icon_element_fire');
      case 'Воздух':
        return AlchemyIcons.named('icon_element_air');
      case 'Вода':
        return AlchemyIcons.named('icon_element_water');
      case 'Земля':
        return AlchemyIcons.named('icon_element_earth');
    }
    return null;
  }

  int? regnumRelativeTo(String referenceNature) {
    if (SimpleShelf.checkSupport(nature: this, supports: referenceNature)) return 1;
    if (SimpleShelf.checkSupport(nature: referenceNature, supports: this)) return -1;
    if (SimpleShelf.sameRegnum([this, referenceNature])) return 0;
    return null;
  }

  Color get namedColor {
    return SimpleShelf._colorSymbols.values.firstWhereOrNull((cd) {
          return cd.name == this || cd.description.contains(this);
        })?.color ??
        Colors.transparent;
  }
}
