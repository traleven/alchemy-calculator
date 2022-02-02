import 'package:alchemy_calculator/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dotted_border/dotted_border.dart';

import '../colorbox.dart';
import '../../model/simplified/alchemyoperations.dart';
import '../../model/colordescription.dart';
import '../../model/simplified/reactant.dart';
import '../../model/simplified/workbench.dart';

class SimpleReactantBlock extends StatelessWidget {
  const SimpleReactantBlock({
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
    SimpleReactant? reactant,
    String label, {
    bool solidBorder = true,
    Function(SimpleReactant)? onAcceptDrop,
  }) {
    return _droppable<SimpleReactant>(
      reactant,
      label,
      builder: (item) => ReactantItem(reactant: item),
      solidBorder: solidBorder,
      onAcceptDrop: onAcceptDrop,
    );
  }

  static Widget _operationOrNull(
    SimpleOperation? operation, {
    bool solidBorder = true,
    Function(SimpleOperation)? onAcceptDrop,
  }) {
    return _droppable<SimpleOperation>(
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
  ReactantItem({Key? key, required SimpleReactant reactant})
      : nomen = reactant.displayNomen,
        name = reactant.displayName,
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
            children: nomen.isNotEmpty
                ? [
                    Text(name),
                    Text(nomen,
                        style: Theme.of(context).textTheme.caption?.copyWith(
                            fontFamily: defaultTextStyle.fontFamily,
                            fontFamilyFallback: defaultTextStyle.fontFamilyFallback)),
                  ]
                : [Text(name)],
          ),
        ],
      ),
    );
  }
}

class OperationItem extends StatelessWidget {
  OperationItem({Key? key, required SimpleOperation operation, this.withDivider = false})
      : name = operation.displayName,
        condition = operation.description,
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
