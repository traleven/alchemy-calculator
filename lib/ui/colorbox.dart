import 'package:flutter/material.dart';

import '../model/shelf.dart';

class ColorBox extends Container {
  ColorBox({Key? key, required double size, Color? color, Widget? child})
      : super(
          key: key,
          width: size,
          height: size,
          decoration: BoxDecoration(color: color, border: Border.all()),
          child: Text(
            Shelf.getColorDescription(color)?.symbol ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: size / 2),
          ),
        );
}
