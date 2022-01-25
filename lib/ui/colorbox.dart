import 'package:flutter/material.dart';

import '../model/shelf.dart';

class ColorBox extends Container {
  ColorBox({Key? key, required double size, ColorDescription? color, Widget? child})
      : super(
          key: key,
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color?.color ?? Colors.transparent,
            border: Border.all(color: const Color(0xFF303030)),
          ),
          child: Text(
            color?.symbol ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: size / 2),
          ),
        );
}
