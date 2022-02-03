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

import 'package:alchemy_calculator/model/shelf.dart';
import 'package:flutter/material.dart';

import 'colordescription.dart';

class Reactant {
  Reactant.fromJson(Shelf shelf, String regnum, dynamic map) : this.fromMap(shelf, regnum, map);

  Reactant.fromMap(Shelf shelf, String regnum, Map<String, dynamic> map)
      : this(
            shelf: shelf,
            regnum: regnum,
            nomen: map['nomen'],
            name: map['name'] ?? map['nomen'],
            isSolid: map['solid'] ?? true,
            circle: map['circle'] ?? 7,
            group: map['group'] ?? 'Unknown',
            pater: map['pater'] ?? '',
            mater: map['mater'] ?? '',
            color: parseColor(map['color']),
            quality: map['quality']);

  const Reactant({
    required Shelf? shelf,
    required this.regnum,
    required this.nomen,
    required this.name,
    this.isSolid = true,
    required this.circle,
    required this.group,
    this.groupId = '',
    this.pater = '',
    this.mater = '',
    this.color,
    this.colorDescription,
    this.quality,
    this.stage = 0,
    this.potion,
  }) : _shelf = shelf;

  const Reactant.shit()
      : _shelf = null,
        regnum = '',
        nomen = 'Мертвая Голова',
        name = '🝎 🝎 🝎 Гажа 🝎 🝎 \u{1f74e}',
        isSolid = true,
        circle = 7,
        group = '',
        groupId = '',
        pater = '',
        mater = '',
        color = null,
        colorDescription = null,
        quality = -1,
        stage = 0,
        potion = null;

  final Shelf? _shelf;
  final String regnum;
  final String nomen;
  final String name;
  final bool isSolid;
  final int circle;
  final String group;
  final String groupId;
  final String pater;
  final String mater;
  final Color? color;
  final ColorDescription? colorDescription;
  final int? quality;
  final int stage;

  final Potion? potion;

  String get displayNomen => stage != 0
      ? 'Микстура'
      : potion == null
          ? nomen
          : '${potion!.regnum.regnumSymbol}${potion!.displayPrincipleDirection}${regnum.regnumSymbol}$_namePrefix $nomen';

  String get displayName => stage != 0
      ? 'Нестабильное соединение'
      : potion == null
          ? [_namePrefix, (name.isNotEmpty ? name : nomen)].join(' ')
          : potionEffect;
  String get _namePrefix =>
      (colorDescription != null ? colorDescription!.symbol : '') + (groupId.isNotEmpty ? groupId : '');

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
    return name.isNotEmpty ? name : nomen;
  }

  static Color? parseColor(String? string) {
    if (null == string) return null;
    return Color(int.parse(string.substring(1), radix: 16) + 0xFF000000);
  }

  Reactant withValues(
          {int? stage,
          bool? solid,
          String? regnum,
          Potion? potion,
          bool? elixir,
          String? principle,
          String? groupId,
          ColorDescription? colorDescription}) =>
      Reactant(
        shelf: _shelf,
        regnum: regnum ?? this.regnum,
        nomen: nomen,
        name: name,
        isSolid: solid ?? isSolid,
        circle: circle,
        group: group,
        groupId: groupId ?? this.groupId,
        pater: pater,
        mater: mater,
        color: color,
        colorDescription: colorDescription ?? this.colorDescription,
        quality: quality,
        stage: stage ?? this.stage,
        potion: (potion ?? this.potion)?.brewed(asElixir: elixir, principle: principle),
      );

  bool isChildOf(String one, String another) =>
      (pater == one && mater == another) || (mater == one && pater == another);

  Concoct concoct() {
    return Concoct._fromReactant(this);
  }
}

class Concoct implements Reactant {
  const Concoct({
    required Shelf? shelf,
    required this.regnum,
    this.isSolid = true,
    this.quality,
    required this.potions,
  }) : _shelf = shelf;

  factory Concoct._fromReactant(Reactant reactant) {
    return Concoct(
      shelf: reactant._shelf,
      regnum: reactant.potion?.regnum ?? '',
      isSolid: reactant.isSolid,
      quality: reactant.quality,
      potions: [reactant],
    );
  }

  @override
  final Shelf? _shelf;
  @override
  final String regnum;
  @override
  String get nomen =>
      _namePrefix + potions.map((e) => e.displayNomen.substring(e.displayNomen.characters.first.length)).join('; ');
  @override
  String get name =>
      _namePrefix + ' ' + potions.map((e) => e.displayName.substring(e.displayName.characters.first.length)).join('; ');
  @override
  final bool isSolid;

  @override
  final int? quality;

  @override
  int get circle => -1;

  @override
  String get group => '';
  @override
  String get groupId => '';
  @override
  String get pater => '';
  @override
  String get mater => '';

  @override
  Color? get color => null;

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
  String get _namePrefix => '\u{1F74C}${regnum.regnumSymbol}:';

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
    return name.isNotEmpty ? name : nomen;
  }

  @override
  bool isChildOf(String one, String another) => false;

  @override
  Potion? get potion => null;

  final List<Reactant> potions;

  @override
  Concoct withValues(
          {int? stage,
          bool? solid,
          String? regnum,
          Potion? potion,
          bool? elixir,
          String? principle,
          String? groupId,
          ColorDescription? colorDescription}) =>
      Concoct(
        shelf: _shelf,
        regnum: regnum ?? this.regnum,
        isSolid: solid ?? isSolid,
        quality: quality,
        potions: potions,
      );

  Concoct merge(Reactant other) {
    if (!other.isPotion) return this;
    return Concoct(
      shelf: _shelf,
      regnum: regnum,
      isSolid: isSolid,
      quality: quality,
      potions: [...potions, ...other.concoct().potions],
    );
  }

  @override
  Concoct concoct() {
    return this;
  }
}

class Potion {
  const Potion({required this.regnum, this.isElixir, this.principle});

  final String regnum;
  final bool? isElixir;
  final String? principle;

  String get displayPrincipleDirection => isElixir == null
      ? '_'
      : isElixir!
          ? '\u{1F757}'
          : '\u{1F768}';

  Potion? brewed({bool? asElixir, String? principle}) {
    return asElixir != null ? Potion(regnum: regnum, isElixir: asElixir, principle: principle) : this;
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
}
