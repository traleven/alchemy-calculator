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

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path/path.dart';

class AlchemyIcons {
  static final Map<String, AssetImage> _icons = {};
  static bool initialized = false;

  static loadAsync(AssetBundle bundle) async {
    if (initialized) return;

    final manifestJson = await bundle.loadString('AssetManifest.json');
    final manifest = jsonDecode(manifestJson);
    for (final String key in manifest.keys.where((key) => key.endsWith('.png') && key.startsWith('icons/'))) {
      _icons[basenameWithoutExtension(key)] = AssetImage(manifest[key][0]);
    }

    initialized = true;
  }

  static AssetImage? named(String iconName) {
    return _icons[iconName];
  }
}
