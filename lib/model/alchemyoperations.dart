import 'package:alchemy_calculator/model/reactant.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'shelf.dart';

class AlchemyOperation implements Comparable {
  const AlchemyOperation({
    required this.regnum,
    required this.name,
    this.condition,
    required this.stage,
    this.substanceState,
    this.catalystState,
    this.resultState,
    this.paterQuality,
    this.materQuality,
  });

  AlchemyOperation.fromJson(dynamic map) : this.fromMap(map);

  AlchemyOperation.fromMap(Map<String, dynamic> map)
      : this(
          regnum: map["regnum"],
          name: map["name"],
          condition: map["condition"],
          stage: map["stage"] * 2,
          substanceState: map["substanceIsSolid"],
          catalystState: map["catalystIsSolid"],
          resultState: map["resultIsSolid"],
          paterQuality: map["paterQuality"],
          materQuality: map["materQuality"],
        );

  final String regnum;
  final String name;
  final String? condition;
  final int stage;
  final bool? substanceState;
  final bool? catalystState;
  final bool? resultState;
  final int? paterQuality;
  final int? materQuality;

  String get id => '$regnum $name';
  int get fullStage => stage ~/ 2;

  String get displayName => name;
  String get displaySolidState => '${substanceState?.solidState() ?? '\uFFFD'}+'
      '${catalystState?.solidState() ?? '\uFFFD'}='
      '${stage < 2 ? resultState?.solidState() ?? '_' : '\uFFFD'}';
  bool get requireSolidState => substanceState != null || catalystState != null || resultState != null;

  String? get displayCondition => condition;

  bool acceptSubstance(Reactant substance, Shelf shelf) =>
      (substanceState == null || substanceState == substance.isSolid) &&
      (paterQuality == null ||
          paterQuality == substance.quality ||
          paterQuality == substance.getPater(shelf)?.quality ||
          paterQuality == substance.getPater(shelf)?.getPater(shelf)?.quality);
  bool acceptCatalyst(Reactant catalyst, Shelf shelf) =>
      (catalystState == null || catalystState == catalyst.isSolid) &&
      (materQuality == null ||
          materQuality == catalyst.quality ||
          materQuality == catalyst.getMater(shelf)?.quality ||
          materQuality == catalyst.getMater(shelf)?.getMater(shelf)?.quality);

  @override
  int compareTo(other) {
    return stage != other.stage
        ? stage.compareTo(other.stage)
        : substanceState != other.substanceState && substanceState != null
            ? substanceState!.compareTo(other.substanceState)
            : catalystState != other.catalystState && catalystState != null
                ? catalystState!.compareTo(other.catalystState)
                : paterQuality != null && paterQuality != other.paterQuality
                    ? paterQuality!.compareTo(other.paterQuality)
                    : materQuality != null && materQuality != other.materQuality
                        ? materQuality!.compareTo(other.materQuality)
                        : regnum != other.regnum
                            ? regnum.compareTo(other.regnum)
                            : name.compareTo(other.name);
  }

  @override
  String toString() {
    return id;
  }
}

class Catalyst {
  const Catalyst(this.group, this.groupId);
  Catalyst.byAbbreviation(this.group) : groupId = group.characters.first;

  final String group;
  final String groupId;

  @override
  String toString() {
    return group;
  }

  bool includes(String groupName) => groupId.isEmpty || groupName.contains(groupId);
}

class CatalystChain {
  const CatalystChain({required this.initial, required this.toPater, required this.stages});

  CatalystChain.fromJson(dynamic map) : this.fromMap(map);

  CatalystChain.fromMap(Map<String, dynamic> map)
      : this(
          initial: Catalyst.byAbbreviation(map['initial']),
          toPater: map['direction'] == 'pater',
          stages: UnmodifiableListView(
              (map['stages'] as List<dynamic>).map((e) => Catalyst.byAbbreviation(e)).toList(growable: false)),
        );

  final Catalyst initial;
  final bool toPater;
  final UnmodifiableListView<Catalyst> stages;
}

extension ReactantExtensions on Reactant {
  Reactant? getPater(Shelf shelf) {
    return shelf.findReactant(pater);
  }

  Reactant? getMater(Shelf shelf) {
    return shelf.findReactant(mater);
  }
}
