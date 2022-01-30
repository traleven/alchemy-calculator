import 'package:flutter/material.dart';

import 'icons.dart';

class ColorDescription {
  const ColorDescription(
      {required this.color,
      required this.symbol,
      required this.icon,
      required this.name,
      required this.description,
      required this.paterQuality,
      required this.materQuality});

  ColorDescription.fromJson(Color color, dynamic map) : this.fromMap(color, map);

  ColorDescription.fromMap(Color color, Map<String, dynamic> map)
      : this(
          color: color,
          symbol: map["symbol"],
          icon: AlchemyIcons.named(map["icon"]),
          name: map["name"],
          description: map["description"].cast<String>().toList(growable: false),
          paterQuality: map["paterQuality"],
          materQuality: map["materQuality"],
        );

  final Color color;
  final String symbol;
  final AssetImage? icon;
  final String name;
  final List<String> description;
  final int paterQuality;
  final int materQuality;
}
