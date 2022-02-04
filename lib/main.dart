import 'package:flutter/material.dart';
// import 'package:computer/computer.dart';
// import 'package:get_it/get_it.dart';

import 'pagecomposition.dart';
import 'simplecomposition.dart';

void main() {
  runApp(const MyApp());
}

const TextStyle defaultTextStyle = TextStyle(
  fontFamily: 'NotoSansSymbols',
  fontFamilyFallback: ['NotoSansSymbols-Black', 'NotoSansSymbols2', 'NotoEmoji', 'NotoSans'],
);

const TextStyle defaultBlackTextStyle = TextStyle(
  color: Colors.black,
  fontFamily: 'NotoSansSymbols',
  fontFamilyFallback: ['NotoSansSymbols-Black', 'NotoSansSymbols2', 'NotoEmoji', 'NotoSans'],
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Алхимический калькулятор',
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
        tooltipTheme: TooltipThemeData(
          textStyle: defaultTextStyle.copyWith(color: Colors.white, height: 1.2),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
      ),
      home: const Material(
        textStyle: defaultBlackTextStyle,
        child: PageComposition(),
        //child: SimplePageComposition(),
      ),
    );
  }
}
