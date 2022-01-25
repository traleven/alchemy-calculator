import 'dart:collection';

import 'package:flutter/material.dart';

import 'alchemyoperations.dart';
import 'reactant.dart';
import 'shelf.dart';

class Workbench extends ChangeNotifier {
  factory Workbench({required Shelf shelf}) {
    if (!_cache.containsKey(shelf.title)) {
      _cache[shelf.title] = Workbench._create(shelf: shelf);
    }
    return _cache[shelf.title]!;
  }

  Workbench._create({required Shelf shelf});

  late final List<Block> _data = [_createBlock()];

  static final Map<String, Workbench> _cache = {};

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
  Reactant? _base;
  Reactant? _catalyst;
  AlchemyOperation? _operation;

  Reactant? get base => _base;
  set base(Reactant? reactant) {
    if (_base != reactant) {
      _base = reactant;
      notifyListeners();
    }
  }

  Reactant? get catalyst => _catalyst;
  set catalyst(Reactant? reactant) {
    if (_catalyst != reactant) {
      _catalyst = reactant;
      notifyListeners();
    }
  }

  AlchemyOperation? get operation => _operation;
  set operation(AlchemyOperation? operation) {
    if (_operation != operation) {
      _operation = operation;
      notifyListeners();
    }
  }

  get hasBase => _base != null;
  get hasCatalyst => hasBase && _catalyst != null;
  get hasOperation => hasCatalyst && _operation != null;
}
