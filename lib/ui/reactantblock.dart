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

import 'package:alchemy_calculator/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dotted_border/dotted_border.dart';

import 'colorbox.dart';
import '../model/alchemyoperations.dart';
import '../model/colordescription.dart';
import '../model/reactant.dart';
import '../model/workbench.dart';

class ReactantBlock extends StatelessWidget {
  const ReactantBlock({
    Key? key,
    this.onCompound,
  }) : super(key: key);

  final Function()? onCompound;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Consumer<Block>(
        builder: (context, block, child) => Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  const Spacer(),
                  _reactantOrNull(
                    block.base,
                    'Базовое вещество',
                    onAcceptDrop: (reactant) => block.base = reactant,
                  ),
                  const SizedBox(width: 20),
                  _reactantOrNull(
                    block.catalyst,
                    'Дополнительное вещество',
                    solidBorder: false,
                    onAcceptDrop: (reactant) => block.catalyst = reactant,
                  ),
                  const Spacer(),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _operationOrNull(block.operation, onAcceptDrop: (operation) => block.operation = operation),
              ),
              ElevatedButton(
                onPressed: block.hasOperation ? onCompound : null,
                style: ElevatedButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(16)),
                child: const Icon(Icons.arrow_downward),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _reactantOrNull(
    Reactant? reactant,
    String label, {
    bool solidBorder = true,
    Function(Reactant)? onAcceptDrop,
  }) {
    return _droppable<Reactant>(
      reactant,
      label,
      builder: (item) => ReactantItem(reactant: item),
      solidBorder: solidBorder,
      onAcceptDrop: onAcceptDrop,
    );
  }

  static Widget _operationOrNull(
    AlchemyOperation? operation, {
    bool solidBorder = true,
    Function(AlchemyOperation)? onAcceptDrop,
  }) {
    return _droppable<AlchemyOperation>(
      operation,
      'Операция',
      builder: (item) => OperationItem(operation: item),
      solidBorder: solidBorder,
      radius: const Radius.circular(16.0),
      onAcceptDrop: onAcceptDrop,
    );
  }

  static Widget _droppable<T extends Object>(
    T? item,
    String label, {
    required Widget Function(T) builder,
    bool solidBorder = true,
    Radius radius = const Radius.circular(2.0),
    Function(T)? onAcceptDrop,
  }) {
    return DragTarget<T>(
      builder: (context, candidateData, rejectedData) => DottedBorder(
        color: candidateData.isNotEmpty ? Theme.of(context).primaryColor : Theme.of(context).unselectedWidgetColor,
        radius: radius,
        borderType: BorderType.RRect,
        dashPattern: solidBorder ? const [10, 0] : const [2, 2],
        padding: const EdgeInsets.all(4),
        child: item != null
            ? Padding(padding: const EdgeInsets.all(4), child: builder(item))
            : SizedBox(
                width: 260,
                child: TextField(
                  decoration: InputDecoration(border: InputBorder.none, labelText: label),
                  readOnly: true,
                  enabled: false,
                ),
              ),
      ),
      onAccept: onAcceptDrop,
    );
  }
}

class ReactantItem extends StatelessWidget {
  ReactantItem({Key? key, required Reactant reactant})
      : nomen = reactant.displayNomen,
        name = reactant.displayName + (reactant.hasSolidState ? ' (${reactant.displaySolidState})' : ''),
        color = reactant.stage == 0 ? reactant.colorDescription : null,
        tooltip = reactant.fullPotionEffect,
        super(key: key);

  final String nomen;
  final String name;
  final String? tooltip;
  final ColorDescription? color;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      waitDuration: const Duration(seconds: 1),
      child: Row(
        children: [
          if (color != null) ColorBox(size: 25, color: color),
          if (color != null) const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name),
              Text(nomen,
                  style: Theme.of(context).textTheme.caption?.copyWith(
                      fontFamily: defaultTextStyle.fontFamily,
                      fontFamilyFallback: defaultTextStyle.fontFamilyFallback)),
            ],
          ),
        ],
      ),
    );
  }
}

class OperationItem extends StatelessWidget {
  OperationItem({Key? key, required AlchemyOperation operation, this.withDivider = false})
      : name = operation.displayName + (operation.requireSolidState ? ' (${operation.displaySolidState})' : ''),
        condition = operation.displayCondition,
        super(key: key);

  final String name;
  final String? condition;
  final bool withDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: condition == null || condition!.isEmpty
          ? [Text(name), if (withDivider) const Divider()]
          : [
              Text(name),
              Text(condition!, style: Theme.of(context).textTheme.caption),
              if (withDivider) const Divider(),
            ],
    );
  }
}
