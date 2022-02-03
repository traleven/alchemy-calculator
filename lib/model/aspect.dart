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
