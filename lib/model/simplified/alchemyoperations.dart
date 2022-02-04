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

import 'package:collection/collection.dart';

import 'reactant.dart';

class SimpleOperation implements Comparable {
  const SimpleOperation({
    required this.nature,
    required this.name,
    required this.stage,
    this.description,
  });

  SimpleOperation.fromJson(dynamic map) : this.fromMap(map);

  SimpleOperation.fromMap(Map<String, dynamic> map)
      : this(
          nature: map["nature"],
          name: map["name"],
          stage: map["stage"] * 2,
          description: map["description"],
        );

  final String nature;
  final String name;
  final int stage;
  final String? description;

  String get id => '$nature $name';
  int get fullStage => stage ~/ 2;

  String get displayName => '${nature.natureSymbol} $name';

  @override
  int compareTo(other) {
    return stage != other.stage
        ? stage.compareTo(other.stage)
        : nature != other.nature
            ? nature.compareTo(other.nature)
            : name.compareTo(other.name);
  }

  @override
  String toString() {
    return id;
  }
}

class SimpleCatalyst {
  const SimpleCatalyst(this.element);

  final String element;

  @override
  String toString() {
    return element;
  }

  bool includes(String element) => this.element.isEmpty || this.element == element;
}

class CatalystChain {
  const CatalystChain({required this.initial, required this.toPater, required this.stages});

  CatalystChain.fromJson(dynamic map) : this.fromMap(map);

  CatalystChain.fromMap(Map<String, dynamic> map)
      : this(
          initial: SimpleCatalyst(map['initial']),
          toPater: map['direction'] == 'pater',
          stages: UnmodifiableListView(
              (map['stages'] as List<dynamic>).map((e) => SimpleCatalyst(e)).toList(growable: false)),
        );

  final SimpleCatalyst initial;
  final bool toPater;
  final UnmodifiableListView<SimpleCatalyst> stages;
}
