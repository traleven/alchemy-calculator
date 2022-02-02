class SimpleAspect {
  const SimpleAspect({
    required this.element,
    required this.color,
    required this.name,
  });

  SimpleAspect.fromJson(dynamic map) : this.fromMap(map);

  SimpleAspect.fromMap(Map<String, dynamic> map)
      : this(
          element: map['element'],
          color: map['color'],
          name: map['name'],
        );

  final String element;
  final String color;
  final String name;
}
