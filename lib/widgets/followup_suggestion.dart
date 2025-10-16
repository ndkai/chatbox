import 'package:flutter/material.dart';

class FollowUpSuggestions extends StatelessWidget {
  final List<String> suggestions;
  final void Function(String)? onTap;

  const FollowUpSuggestions({
    super.key,
    required this.suggestions,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(suggestions.length, (index) {
          final text = suggestions[index];
          return InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () => onTap?.call(text),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.subdirectory_arrow_right_rounded,
                    size: 18,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).expand((widget) sync* {
          yield widget;
          if (widget != suggestions.last) {
            yield Divider(height: 1, color: Colors.grey[300]);
          }
        }).toList(),
      ),
    );
  }
}
