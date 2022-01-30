import 'package:flutter/material.dart';

import 'reactant.dart';

class Aspect {
  const Aspect({
    required this.regnum,
    required this.color,
    required this.sign,
    required this.name,
  });

  Aspect.fromJson(dynamic map) : this.fromMap(map);

  Aspect.fromMap(Map<String, dynamic> map)
      : this(
          regnum: map['regnum'],
          color: Reactant.parseColor(map['color'])!,
          sign: map['sign'],
          name: map['name'],
        );

  final String regnum;
  final Color color;
  final String sign;
  final String name;
}
