import 'package:alchemy_calculator/panels.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:computer/computer.dart';
// import 'package:get_it/get_it.dart';

import 'model/alchemyreaction.dart';
import 'model/shelf.dart';
import 'model/workbench.dart';
import 'ui/splitview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Alchemy Calculator',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          iconTheme: const IconThemeData(
            color: Colors.black,
            opacity: 1.0,
          ),
        ),
        home: const Material(child: PageComposition()));
  }
}

class PageComposition extends StatelessWidget {
  const PageComposition({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => FutureBuilder<Shelf>(
      future: Shelf.loadAllAsync(DefaultAssetBundle.of(context)),
      builder: (context, shelf) {
        if (shelf.hasData) {
          final reaction = AlchemyReaction(shelf: shelf.data!);
          final workbench = Workbench(shelf: shelf.data!);
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
      ratio: 0.75,
      left: HorizontalSplitView(ratio: 0.8, upper: WorkbenchPanel(), lower: LogPanel()),
      right: HorizontalSplitView(ratio: 0.3, upper: OperationsPanel(), lower: ReactantsPanel()),
    );
  }
}
