import 'package:collection/collection.dart';

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

  String get displayName => name;

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
          initial: map['initial'],
          toPater: map['direction'] == 'pater',
          stages: UnmodifiableListView(
              (map['stages'] as List<dynamic>).map((e) => SimpleCatalyst(e)).toList(growable: false)),
        );

  final SimpleCatalyst initial;
  final bool toPater;
  final UnmodifiableListView<SimpleCatalyst> stages;
}
