import 'package:flutter/material.dart';

class DetailRow extends StatelessWidget {
  const DetailRow(this.label, this.value, {super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(label,
                style: TextStyle(
                    color: Colors.blueGrey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
              flex: 4,
              child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}

class DetailWidgetRow extends StatelessWidget {
  const DetailWidgetRow(this.label, this.widget, {super.key});

  final String label;
  final Widget widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.blueGrey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500)),
          Expanded(child: widget),
        ],
      ),
    );
  }
}
