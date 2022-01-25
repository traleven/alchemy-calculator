import 'package:flutter/material.dart';

class VerticalSplitView extends StatefulWidget {
  final Widget left;
  final Widget right;
  final double ratio;

  const VerticalSplitView({Key? key, required this.left, required this.right, this.ratio = 0.5})
      : assert(ratio >= 0),
        assert(ratio <= 1),
        super(key: key);

  @override
  _VerticalSplitViewState createState() => _VerticalSplitViewState();
}

class _VerticalSplitViewState extends State<VerticalSplitView> {
  final _dividerWidth = 8.0;

  //from 0-1
  double _ratio = 0.5;
  double? _maxWidth;

  @override
  void initState() {
    super.initState();
    _ratio = widget.ratio;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, BoxConstraints constraints) {
      assert(_ratio <= 1);
      assert(_ratio >= 0);
      double maxWidth = _maxWidth ?? constraints.maxWidth - _dividerWidth;
      if (maxWidth != constraints.maxWidth) {
        maxWidth = constraints.maxWidth - _dividerWidth;
      }

      return SizedBox(
        width: constraints.maxWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: _ratio * maxWidth,
              child: widget.left,
            ),
            MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                child: Container(
                  decoration: BoxDecoration(color: Theme.of(context).dividerColor, border: const Border()),
                  child: SizedBox(
                    width: _dividerWidth,
                    height: constraints.maxHeight,
                  ),
                ),
                onPanUpdate: (DragUpdateDetails details) {
                  setState(() {
                    _ratio += details.delta.dx / maxWidth;
                    if (_ratio > 1) {
                      _ratio = 1;
                    } else if (_ratio < 0.0) {
                      _ratio = 0.0;
                    }
                  });
                },
              ),
            ),
            SizedBox(
              width: (1 - _ratio) * maxWidth,
              child: widget.right,
            ),
          ],
        ),
      );
    });
  }
}

class HorizontalSplitView extends StatefulWidget {
  final Widget upper;
  final Widget lower;
  final double ratio;

  const HorizontalSplitView({Key? key, required this.upper, required this.lower, this.ratio = 0.5})
      : assert(ratio >= 0),
        assert(ratio <= 1),
        super(key: key);

  @override
  _HorizontalSplitViewState createState() => _HorizontalSplitViewState();
}

class _HorizontalSplitViewState extends State<HorizontalSplitView> {
  final _dividerHeight = 8.0;

  //from 0-1
  double _ratio = 0.5;
  double? _maxHeight;

  @override
  void initState() {
    super.initState();
    _ratio = widget.ratio;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, BoxConstraints constraints) {
      assert(_ratio <= 1);
      assert(_ratio >= 0);
      double maxHeight = _maxHeight ?? constraints.maxHeight - _dividerHeight;
      if (maxHeight != constraints.maxHeight) {
        maxHeight = constraints.maxHeight - _dividerHeight;
      }

      return SizedBox(
        height: constraints.maxHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: _ratio * maxHeight,
              child: widget.upper,
            ),
            MouseRegion(
              cursor: SystemMouseCursors.resizeRow,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                child: Container(
                  decoration: BoxDecoration(color: Theme.of(context).dividerColor, border: const Border()),
                  //padding: EdgeInsets.all(5),
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: _dividerHeight,
                  ),
                ),
                onPanUpdate: (DragUpdateDetails details) {
                  setState(() {
                    _ratio += details.delta.dy / maxHeight;
                    if (_ratio > 1) {
                      _ratio = 1;
                    } else if (_ratio < 0.0) {
                      _ratio = 0.0;
                    }
                  });
                },
              ),
            ),
            SizedBox(
              height: (1 - _ratio) * maxHeight,
              child: widget.lower,
            ),
          ],
        ),
      );
    });
  }
}
