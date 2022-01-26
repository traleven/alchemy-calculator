import 'package:alchemy_calculator/model/shelf.dart';
import 'package:flutter/material.dart';

class Reactant {
  Reactant.fromJson(String regnum, dynamic map) : this.fromMap(regnum, map);

  Reactant.fromMap(String regnum, Map<String, dynamic> map)
      : this(
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
  });

  const Reactant.shit()
      : regnum = '',
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
          : nomen; //: 'Принцип: Coagulatio (усиливает свойство, ускоряет процесс); Аспект: ♋️ (психометрия, психоскопия).';

  String get displayName => stage != 0
      ? 'Unstable something'
      : potion == null
          ? (groupId.isNotEmpty ? '$groupId ' : '') +
              (colorDescription != null ? '${colorDescription!.symbol} ' : '') +
              (name.isNotEmpty ? name : nomen)
          : '${potion!.displaySolidState} (Эффект: ${potion!.regnum.regnumSymbol}; База: $nomen)';

  int get fullStage => (stage ~/ 2) * 2;
  String get displaySolidState => isSolid.solidState();
  bool get hasSolidState => quality == null || quality! >= 0;
  bool get isPotion => stage == 0 && potion?.isElixir != null;

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
          String? groupId,
          ColorDescription? colorDescription}) =>
      Reactant(
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
        potion: (potion ?? this.potion)?.brewed(asElixir: elixir),
      );

  bool isChildOf(String one, String another) =>
      (pater == one && mater == another) || (mater == one && pater == another);
}

class Potion {
  const Potion({required this.regnum, this.isElixir});

  final String regnum;
  final bool? isElixir;

  String get displaySolidState => isElixir == null
      ? '_'
      : isElixir!
          ? 'Эликсир'
          : 'Тинктура';

  Potion? brewed({bool? asElixir}) {
    return asElixir != null ? Potion(regnum: regnum, isElixir: asElixir) : this;
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
