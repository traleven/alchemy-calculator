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

import 'dart:collection';

import 'package:flutter/material.dart';

import 'alchemyoperations.dart';
import 'reactant.dart';
import 'shelf.dart';

class SimpleWorkbench extends ChangeNotifier {
  factory SimpleWorkbench({required SimpleShelf shelf}) {
    if (!_cache.containsKey(shelf.title)) {
      _cache[shelf.title] = SimpleWorkbench._create(shelf: shelf);
    }
    return _cache[shelf.title]!;
  }

  SimpleWorkbench._create({required SimpleShelf shelf});

  late final List<Block> _data = [_createBlock()];

  static final Map<String, SimpleWorkbench> _cache = {};

  Block _createBlock() {
    final block = Block();
    block.addListener(_onLastBlockCompleted);
    return block;
  }

  void pushBlock() {
    _data.add(_createBlock());
    notifyListeners();
  }

  void popBlock() {
    if (_data.isNotEmpty) {
      _data.removeLast().removeListener(_onLastBlockCompleted);
    }
    if (_data.isNotEmpty) {
      //_data.last.selectedOperation = null;
    }
    notifyListeners();
  }

  void clear() {
    while (_data.isNotEmpty) {
      _data.removeLast().removeListener(_onLastBlockCompleted);
    }
    pushBlock();
  }

  void _onLastBlockCompleted() {
    if (_data.last.hasOperation) {
      //pushBlock();
      notifyListeners();
    }
  }

  void operator []=(int i, Block? block) {
    _data[i]._base = block?._base;
    _data[i]._base = block?._catalyst;
    _data[i]._operation = block?._operation;
    notifyListeners();
  }

  Block? operator [](int i) {
    return i < _data.length ? _data[i] : null;
  }

  UnmodifiableListView<Block> get blocks => UnmodifiableListView(_data);
}

class Block extends ChangeNotifier {
  SimpleReactant? _base;
  SimpleReactant? _catalyst;
  SimpleOperation? _operation;

  SimpleReactant? get base => _base;
  set base(SimpleReactant? reactant) {
    if (_base != reactant) {
      _base = reactant;
      notifyListeners();
    }
  }

  SimpleReactant? get catalyst => _catalyst;
  set catalyst(SimpleReactant? reactant) {
    if (_catalyst != reactant) {
      _catalyst = reactant;
      notifyListeners();
    }
  }

  SimpleOperation? get operation => _operation;
  set operation(SimpleOperation? operation) {
    if (_operation != operation) {
      _operation = operation;
      notifyListeners();
    }
  }

  get hasBase => _base != null;
  get hasCatalyst => hasBase && _catalyst != null;
  get hasOperation => hasCatalyst && _operation != null;
}
