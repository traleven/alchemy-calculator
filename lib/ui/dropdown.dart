import 'package:flutter/material.dart';

class SelectorDropdown<T> extends StatefulWidget {
  const SelectorDropdown({
    Key? key,
    required this.values,
    required this.value,
    this.enabled = true,
    this.onChanged,
    required this.createItem,
  }) : super(key: key);

  final List<T> values;
  final String? Function() value;
  final bool enabled;
  final Function(String?)? onChanged;
  final DropdownMenuItem<String> Function(T) createItem;

  @override
  State<SelectorDropdown<T>> createState() => _SelectorDropdownState<T>();
}

class _SelectorDropdownState<T> extends State<SelectorDropdown<T>> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: widget.value(),
      disabledHint: const Text(''),
      hint: const Text('Select...'),
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: widget.enabled
          ? (String? newValue) {
              setState(() {
                widget.onChanged?.call(newValue);
              });
            }
          : null,
      items: widget.values.map<DropdownMenuItem<String>>(widget.createItem).toList(),
    );
  }
}
