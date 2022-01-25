import 'package:alchemy_calculator/model/reactant.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/alchemyoperations.dart';
import 'model/alchemyreaction.dart';
import 'ui/colorbox.dart';
import 'model/workbench.dart';
import 'ui/reactantblock.dart';
import 'model/shelf.dart';

class WorkbenchPanel extends StatelessWidget {
  const WorkbenchPanel({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        restorationId: "workbench",
        primary: false,
        child: Consumer<Workbench>(
          builder: (context, workbench, child) => Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final block in workbench.blocks)
                ChangeNotifierProvider.value(
                  value: block,
                  child: Consumer<AlchemyReaction>(
                    builder: (context, reaction, child) => ReactantBlock(onCompound: () => reaction(workbench)),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: Consumer<Workbench>(
        builder: (context, workbench, child) => IconButton(
          onPressed: workbench.blocks.length > 1 ? () => workbench.clear() : null,
          tooltip: 'Reset',
          icon: const Icon(Icons.clear),
        ),
      ),
    );
  }
}

class LogPanel extends StatelessWidget {
  const LogPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AlchemyReaction>(
      builder: (context, reaction, child) => Scaffold(
        body: ListView(
          primary: false,
          children: [
            for (final item in reaction.log) Row(children: [Text(item)])
          ],
        ),
        floatingActionButton: IconButton(
          onPressed: reaction.clearLog,
          tooltip: 'Clear',
          icon: const Icon(Icons.clear),
        ),
      ),
    );
  }
}

class OperationsPanel extends StatelessWidget {
  const OperationsPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<Shelf>(
      builder: (context, shelf, child) => Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            FilterPadding(child: FilterWrap(children: _buildRegnumFilterChips(shelf))),
            FilterPadding(child: FilterWrap(children: _buildStageFilterChips(shelf))),
            const Divider(),
            Expanded(
              child: ListView(
                primary: false,
                padding: const EdgeInsets.all(4),
                children: [
                  for (final item in shelf.filteredOperations)
                    Draggable<AlchemyOperation>(
                      dragAnchorStrategy: pointerDragAnchorStrategy,
                      data: item,
                      feedback: _makeDraggable(context, OperationItem(operation: item)),
                      child: OperationItem(operation: item, withDivider: true),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRegnumFilterChips(Shelf shelf) {
    return Shelf.regna
        .map<Widget>(
          (regnum) => FilterChipWithTooltip(
            label: Text(regnum.regnumSymbol),
            selected: shelf.operationsRegnumFilterIncludes(regnum),
            onSelected: (active) => shelf.setOperationsRegnumFilter(regnum, active),
            tooltip: regnum.regnumName,
          ),
        )
        .toList();
  }

  List<Widget> _buildStageFilterChips(Shelf shelf) {
    final result = [
      FilterChip(
        label: const Text('Nigredo'),
        selected: shelf.operationsStageFilterIncludes(0),
        onSelected: (active) => shelf.setOperationStageFilter(0, active),
      ),
      FilterChip(
        label: const Text('Albedo'),
        selected: shelf.operationsStageFilterIncludes(1),
        onSelected: (active) => shelf.setOperationStageFilter(1, active),
      ),
      FilterChip(
        label: const Text('Rubedo'),
        selected: shelf.operationsStageFilterIncludes(2),
        onSelected: (active) => shelf.setOperationStageFilter(2, active),
      ),
      FilterChip(
        label: const Text('Other'),
        selected: shelf.operationsStageFilterIncludes(-1),
        onSelected: (active) => shelf.setOperationStageFilter(-1, active),
      ),
    ];
    return result;
  }
}

class ReactantsPanel extends StatelessWidget {
  const ReactantsPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<Shelf>(
      builder: (context, shelf, child) => Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            FilterPadding(child: FilterWrap(children: _buildRegnumFilterChips(shelf))),
            FilterPadding(child: FilterWrap(children: _buildGroupFilterChips(shelf))),
            FilterPadding(child: FilterWrap(children: _buildColorFilterChips(shelf))),
            const Divider(),
            Expanded(
              child: ListView(
                primary: false,
                children: [
                  for (final item in shelf.filteredReactants)
                    Draggable<Reactant>(
                      dragAnchorStrategy: pointerDragAnchorStrategy,
                      data: item,
                      feedback: _makeDraggable(context, ReactantItem(reactant: item)),
                      child: Column(
                        children: [
                          ReactantItem(reactant: item),
                          const Divider(),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static List<Widget> _buildRegnumFilterChips(Shelf shelf) {
    final result = Shelf.regna
        .map(
          (regnum) => FilterChipWithTooltip(
            label: Text(regnum.regnumSymbol),
            selected: shelf.reactantRegnumFilterIncludes(regnum),
            onSelected: (active) => shelf.setReactantRegnumFilter(regnum, active),
            tooltip: regnum.regnumName,
          ),
        )
        .toList();

    result.add(
      FilterChipWithTooltip(
        label: Text('potion'.regnumSymbol),
        selected: shelf.reactantPotionFilterIncludes(),
        onSelected: (active) => shelf.setReactantPotionFilter(active),
        tooltip: 'potion'.regnumName,
      ),
    );
    return result;
  }

  static List<Widget> _buildGroupFilterChips(Shelf shelf) {
    return shelf.groupIds
        .map((id) => FilterChipWithTooltip(
              label: Text(id),
              selected: shelf.reactantGroupFilterIncludes(id),
              onSelected: (active) => shelf.setReactantGroupFilter(id, active),
              tooltip: Shelf.getNameForGroup(id) ?? '',
            ))
        .toList(growable: false);
  }

  static List<Widget> _buildColorFilterChips(Shelf shelf) {
    return shelf.colors
        .map((color) => FilterChipWithTooltip(
              label: ColorBox(size: 15, color: color),
              selected: shelf.reactantColorFilterIncludes(color),
              onSelected: (active) => shelf.setReactantColorFilter(color, active),
              tooltip: Shelf.getColorDescription(color)?.name ?? '',
            ))
        .toList(growable: false);
  }
}

class FilterWrap extends Wrap {
  FilterWrap({
    Key? key,
    Axis direction = Axis.horizontal,
    WrapAlignment alignment = WrapAlignment.start,
    double spacing = 8.0,
    WrapAlignment runAlignment = WrapAlignment.start,
    double runSpacing = 4.0,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    Clip clipBehavior = Clip.none,
    List<Widget> children = const <Widget>[],
  }) : super(
          key: key,
          direction: direction,
          alignment: alignment,
          spacing: spacing,
          runAlignment: runAlignment,
          runSpacing: runSpacing,
          crossAxisAlignment: crossAxisAlignment,
          textDirection: textDirection,
          verticalDirection: verticalDirection,
          clipBehavior: clipBehavior,
          children: children,
        );
}

class FilterPadding extends Padding {
  const FilterPadding({Key? key, EdgeInsets padding = const EdgeInsets.only(bottom: 4), Widget? child})
      : super(key: key, padding: padding, child: child);
}

class FilterChipWithTooltip extends StatelessWidget {
  const FilterChipWithTooltip({
    Key? key,
    required this.label,
    this.selected = false,
    required this.onSelected,
    this.tooltip,
    this.waitDuration = const Duration(seconds: 1),
  }) : super(key: key);

  final Widget label;
  final bool selected;
  final Function(bool) onSelected;

  final String? tooltip;
  final Duration? waitDuration;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      waitDuration: waitDuration,
      child: FilterChip(
        label: label,
        selected: selected,
        onSelected: onSelected,
      ),
    );
  }
}

Widget _makeDraggable(BuildContext context, Widget item) {
  return Material(
    type: MaterialType.card,
    clipBehavior: Clip.hardEdge,
    elevation: 8.0,
    borderRadius: const BorderRadius.all(Radius.circular(4)),
    child: Padding(padding: const EdgeInsets.all(4), child: item),
  );
}
