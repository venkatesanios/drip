import 'package:flutter/material.dart';

class ConditionTile extends StatelessWidget {
  final String name;
  final String rule;
  final bool status;
  final VoidCallback onRemove;
  final ValueChanged<bool> onStatusChanged;

  const ConditionTile({
    super.key,
    required this.name,
    required this.rule,
    required this.status,
    required this.onRemove,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontSize: 15)),
            Text(rule, style: TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 5),
          ],
        ),
        const Spacer(),
        Transform.scale(
          scale: 0.7,
          child: Tooltip(
            message: status ? 'deactivate' : 'activate',
            child: Switch(
              hoverColor: Theme.of(context).primaryColor,
              activeColor: Theme.of(context).primaryColorLight,
              value: status,
              onChanged: onStatusChanged,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Remove condition',
          onPressed: onRemove,
          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
        ),
      ],
    );
  }
}