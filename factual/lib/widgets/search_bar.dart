import 'package:flutter/material.dart';

class FigmaSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterTap;

  const FigmaSearchBar({
    super.key,
    this.controller,
    this.onSubmitted,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: onSubmitted,
              decoration: InputDecoration(
                hintText: 'Search news...',
                hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                isDense: true,
              ),
            ),
          ),
          if (onFilterTap != null) ...[
            Container(
              height: 24,
              width: 1,
              color: Theme.of(context).colorScheme.outline,
            ),
            IconButton(
              icon: Icon(
                Icons.tune, // Filter icon
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
              onPressed: onFilterTap,
            ),
          ],
        ],
      ),
    );
  }
}
