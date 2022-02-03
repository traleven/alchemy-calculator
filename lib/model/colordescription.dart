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
