import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/simplified/alchemyreaction.dart';
import 'model/simplified/shelf.dart';
import 'model/simplified/workbench.dart';
import 'simplepanels.dart';
import 'ui/splitview.dart';

class SimplePageComposition extends StatelessWidget {
  const SimplePageComposition({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => FutureBuilder<SimpleShelf>(
      future: SimpleShelf.loadAllAsync(DefaultAssetBundle.of(context)),
      builder: (context, shelf) {
        if (shelf.hasData) {
          final reaction = AlchemyReaction(shelf: shelf.data!);
          final workbench = SimpleWorkbench(shelf: shelf.data!);
          return MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: shelf.data),
              ChangeNotifierProvider.value(value: workbench),
              ChangeNotifierProvider.value(value: reaction),
            ],
            child: _page,
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      });

  Widget get _page {
    return const VerticalSplitView(
      ratio: 0.6,
      left: HorizontalSplitView(ratio: 0.8, upper: WorkbenchPanel(), lower: LogPanel()),
      right: HorizontalSplitView(ratio: 0.3, upper: OperationsPanel(), lower: ReactantsPanel()),
    );
  }
}
