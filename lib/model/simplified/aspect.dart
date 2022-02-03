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
