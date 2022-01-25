import 'package:alchemy_calculator/model/reactant.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class AlchemyOperation implements Comparable {
  const AlchemyOperation({
    required this.regnum,
    required this.name,
    this.condition,
    required this.stage,
    this.substanceState,
    this.catalystState,
    this.resultState,
  });

  AlchemyOperation.fromJson(dynamic map) : this.fromMap(map);

  AlchemyOperation.fromMap(Map<String, dynamic> map)
      : this(
          regnum: map["regnum"],
          name: map["name"],
          condition: map["condition"],
          stage: map["stage"],
          substanceState: map["substanceIsSolid"],
          catalystState: map["catalystIsSolid"],
          resultState: map["resultIsSolid"],
        );

  final String regnum;
  final String name;
  final String? condition;
  final int stage;
  final bool? substanceState;
  final bool? catalystState;
  final bool? resultState;

  get id => '$regnum $name';

  get displayName => name;
  get displaySolidState =>
      '${substanceState?.solidState() ?? '_'}+${catalystState?.solidState() ?? '_'}=${resultState?.solidState() ?? '_'}';
  get requireSolidState => substanceState != null || catalystState != null || resultState != null;

  get displayCondition => condition;

  bool acceptSubstance(Reactant substance) => substanceState == null || substanceState == substance.isSolid;
  bool acceptCatalyst(Reactant catalyst) => catalystState == null || catalystState == catalyst.isSolid;

  @override
  int compareTo(other) {
    return stage != other.stage
        ? stage.compareTo(other.stage)
        : substanceState != other.substanceState && substanceState != null
            ? substanceState!.compareTo(other.substanceState)
            : catalystState != other.catalystState && catalystState != null
                ? catalystState!.compareTo(other.catalystState)
                : regnum != other.regnum
                    ? regnum.compareTo(other.regnum)
                    : name.compareTo(other.name);
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
  const CatalystChain({required this.initial, required this.direction, required this.stages});

  CatalystChain.fromJson(dynamic map) : this.fromMap(map);

  CatalystChain.fromMap(Map<String, dynamic> map)
      : this(
          initial: Catalyst.byAbbreviation(map['initial']),
          direction: map['direction'],
          stages: UnmodifiableListView(
              (map['stages'] as List<dynamic>).map((e) => Catalyst.byAbbreviation(e)).toList(growable: false)),
        );

  final Catalyst initial;
  final String direction;
  final UnmodifiableListView<Catalyst> stages;
}
