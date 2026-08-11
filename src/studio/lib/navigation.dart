import 'package:flutter/material.dart';

class NavItem {
  final String routeId;
  final IconData icon;
  final String label;

  const NavItem({
    required this.routeId,
    required this.icon,
    required this.label,
  });
}

class NavSection {
  final List<NavItem> items;
  final bool dividerBefore;

  const NavSection({required this.items, this.dividerBefore = true});
}

class NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const NavIcon({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 64,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: selected
                  ? const Color(0xFF1A1A1A)
                  : const Color(0xFF888888),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: selected
                    ? const Color(0xFF1A1A1A)
                    : const Color(0xFF888888),
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildNavDivider() {
  return const Padding(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    child: Divider(height: 1, thickness: 1),
  );
}

class NavSidebar extends StatelessWidget {
  final List<NavSection> sections;
  final int selectedIndex;
  final ValueChanged<int> onItemTap;

  const NavSidebar({
    super.key,
    required this.sections,
    required this.selectedIndex,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    int flatIndex = 0;

    return Container(
      width: 72,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          const SizedBox(height: 4),
          ...sections.asMap().entries.expand((entry) {
            final section = entry.value;
            final items = section.items.map((item) {
              final idx = flatIndex++;
              return NavIcon(
                icon: item.icon,
                label: item.label,
                selected: selectedIndex == idx,
                onTap: () => onItemTap(idx),
              );
            }).toList();
            return [
              if (section.dividerBefore && items.isNotEmpty) buildNavDivider(),
              ...items,
            ];
          }),
          buildNavDivider(),
          const Spacer(),
        ],
      ),
    );
  }
}
