import 'package:flutter/material.dart';

class ActionButton extends ElevatedButton {
  const ActionButton({
    super.key,
    required super.onPressed,
    required super.child,
    this.loading = false,
  });

  final bool loading;

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.loading == false ? widget.onPressed : null,
      child: widget.loading == false
          ? widget.child
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                widget.child!,
                SizedBox(width: 12),
                CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                  constraints: BoxConstraints.tight(Size.square(16)),
                ),
              ],
            ),
    );
  }
}
