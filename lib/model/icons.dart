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
