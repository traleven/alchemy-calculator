import 'package:flutter/material.dart';

import 'package:alchemy_calculator/model/colordescription.dart';

import 'shelf.dart';

class SimpleReactant {
  SimpleReactant.fromJson(SimpleShelf shelf, dynamic map) : this.fromMap(shelf, map);

  SimpleReactant.fromMap(SimpleShelf shelf, Map<String, dynamic> map)
      : this(
            shelf: shelf,
            element: map['element'],
            name: map['name'] ?? map['nomen'],
            isSolid: map['solid'] ?? true,
            color: map['color'],
            quality: map['quality']);

  const SimpleReactant({
    required SimpleShelf? shelf,
    required this.element,
    required this.name,
    this.isSolid = true,
    this.color,
    this.colorDescription,
    this.quality,
    this.stage = 0,
    this.potion,
  }) : _shelf = shelf;

  const SimpleReactant.shit()
      : _shelf = null,
        element = '',
        name = 'Мертвая Голова',
        isSolid = true,
        color = null,
        colorDescription = null,
        quality = -1,
        stage = 0,
        potion = null;

  final SimpleShelf? _shelf;
  final String element;
  final String name;
  final bool isSolid;
  final String? color;
  final ColorDescription? colorDescription;
  final int? quality;
  final int stage;

  final SimplePotion? potion;
  String? get nature => potion?.nature;

  String get displayNomen => stage != 0
      ? 'Микстура'
      : potion == null
          ? ''
          : '${potion!.nature.natureSymbol}${potion!.displayPrincipleDirection}$_namePrefix';

  String get displayName => stage != 0
      ? 'Нестабильное соединение'
      : potion == null
          ? [_namePrefix, name].join(' ')
          : potionEffect;
  String get _namePrefix => (colorDescription != null ? colorDescription!.symbol : '') + (element.elementSymbol);

  int get fullStage => stage ~/ 2;
  String get displaySolidState => isSolid.solidState();
  bool get hasSolidState => quality == null || quality! >= 0;
  bool get isPotion => stage == 0 && potion?.isElixir != null;

  String get potionEffect {
    if (!isPotion) return '';
    return _shelf?.buildPotionEffect(this) ?? '';
  }

  String get fullPotionEffect {
    if (!isPotion) return '';
    return _shelf?.buildFullPotionEffect(this) ?? '';
  }

  @override
  String toString() {
    return name;
  }

  static Color? parseColor(String? string) {
    if (null == string) return null;
    return Color(int.parse(string.substring(1), radix: 16) + 0xFF000000);
  }

  SimpleReactant withValues(
          {int? stage,
          bool? solid,
          String? element,
          SimplePotion? potion,
          bool? elixir,
          String? principle,
          ColorDescription? colorDescription}) =>
      SimpleReactant(
        shelf: _shelf,
        element: element ?? this.element,
        name: name,
        isSolid: solid ?? isSolid,
        color: color,
        colorDescription: colorDescription ?? this.colorDescription,
        quality: quality,
        stage: stage ?? this.stage,
        potion: (potion ?? this.potion)?.brewed(asElixir: elixir, principle: principle),
      );

  SimpleConcoct concoct() {
    return SimpleConcoct._fromReactant(this);
  }
}

class SimpleConcoct implements SimpleReactant {
  const SimpleConcoct({
    required SimpleShelf? shelf,
    this.isSolid = true,
    this.quality,
    required this.potions,
  }) : _shelf = shelf;

  factory SimpleConcoct._fromReactant(SimpleReactant reactant) {
    return SimpleConcoct(
      shelf: reactant._shelf,
      isSolid: reactant.isSolid,
      quality: reactant.quality,
      potions: [reactant],
    );
  }

  @override
  final SimpleShelf? _shelf;
  @override
  String get element => '';
  @override
  String get nature => '';

  @override
  String get name => potions.map((e) => e.displayName).join('\n');
  String get nomen => _namePrefix + ' ' + potions.map((e) => e.displayNomen).join('; ');

  @override
  final bool isSolid;

  @override
  final int? quality;

  @override
  String? get color => null;

  @override
  ColorDescription? get colorDescription => null;

  @override
  int get stage => 0;

  @override
  int get fullStage => stage ~/ 2;

  @override
  String get displayNomen => potions.length == 1 ? potions[0].displayNomen : nomen;

  @override
  String get displayName => potions.length == 1 ? potions[0].displayName : name;

  @override
  String get _namePrefix => '\u{1F74C}${element.elementSymbol}:';

  @override
  String get displaySolidState => isSolid.solidState();

  @override
  bool get hasSolidState => true;

  @override
  bool get isPotion => true;

  @override
  String get potionEffect {
    if (!isPotion) return '';
    return _shelf?.buildPotionEffect(this) ?? '';
  }

  @override
  String get fullPotionEffect {
    return potions.map((potion) => _shelf?.buildFullPotionEffect(potion)).join('\n\n');
  }

  @override
  String toString() {
    return name;
  }

  @override
  SimplePotion? get potion => null;

  final List<SimpleReactant> potions;

  @override
  SimpleConcoct withValues(
          {int? stage,
          bool? solid,
          String? element,
          SimplePotion? potion,
          bool? elixir,
          String? principle,
          ColorDescription? colorDescription}) =>
      SimpleConcoct(
        shelf: _shelf,
        isSolid: solid ?? isSolid,
        quality: quality,
        potions: potions,
      );

  SimpleConcoct merge(SimpleReactant other) {
    if (!other.isPotion) return this;
    return SimpleConcoct(
      shelf: _shelf,
      isSolid: isSolid,
      quality: quality,
      potions: [...potions, ...other.concoct().potions],
    );
  }

  @override
  SimpleConcoct concoct() {
    return this;
  }
}

class SimplePotion {
  const SimplePotion({required this.nature, this.isElixir, this.principle});

  final String nature;
  final bool? isElixir;
  final String? principle;

  String get displayPrincipleDirection => isElixir == null
      ? '_'
      : isElixir!
          ? '\u{1F757}'
          : '\u{1F768}';

  SimplePotion? brewed({bool? asElixir, String? principle}) {
    return asElixir != null ? SimplePotion(nature: nature, isElixir: asElixir, principle: principle) : this;
  }
}

extension BoolComparison on bool {
  int compareTo(bool? other) => (this ? 1 : -1).compareTo(other == null
      ? 0
      : other
          ? 1
          : -1);
  String solidState() => this ? ' 🝙 ' : '💧';
}

extension StringConversions on String {
  String get regnumSymbol {
    switch (this) {
      case 'mineral':
        return '\u{1F728}';
      case 'animal':
        return '\u{1F721}';
      case 'herbal':
        return '\u{1F76E}';
      case 'potion':
        return '\u{2697}';
    }
    return this;
  }

  String get elementSymbol {
    switch (this) {
      case 'Огонь':
        return '\u{1F702}';
      case 'Воздух':
        return '\u{1F701}';
      case 'Вода':
        return '\u{1F704}';
      case 'Земля':
        return '\u{1F703}';
    }
    return this;
  }

  String get natureSymbol {
    switch (this) {
      case 'Сульфур':
        return '\u{1F70E}';
      case 'Меркурий':
        return '\u{263F}';
      case 'Соль':
        return '\u{1F73F}';
      case 'potion':
        return '\u{2697}';
    }
    return this;
  }
}
