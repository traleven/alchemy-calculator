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

import '../model/colordescription.dart';

class ColorBox extends Container {
  ColorBox({Key? key, required double size, ColorDescription? color, Widget? child})
      : super(
          key: key,
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color?.color ?? Colors.transparent,
            border: Border.all(color: const Color(0xFF303030)),
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
          child: Transform.scale(scale: 0.85, child: ImageIcon(color?.icon)),
        );
}
