import 'package:flutter/material.dart';
import 'package:qtadmin_studio/models/metadata.dart';

class NavItem {
  final IconData icon;
  final String label;
  final Widget Function() builder;

  const NavItem({
    required this.icon,
    required this.label,
    required this.builder,
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
              color: selected ? const Color(0xFF1A1A1A) : const Color(0xFF888888),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: selected ? const Color(0xFF1A1A1A) : const Color(0xFF888888),
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

class WorkspaceSwitcher extends StatelessWidget {
  final List<WorkspaceInfo> workspaces;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const WorkspaceSwitcher({
    super.key,
    required this.workspaces,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final workspace = workspaces[selectedIndex];
    return PopupMenuButton<int>(
      onSelected: onChanged,
      offset: const Offset(0, 48),
      itemBuilder: (context) => workspaces.asMap().entries.map((entry) {
        final i = entry.key;
        final t = entry.value;
        return PopupMenuItem<int>(
          value: i,
          child: Row(
            children: [
              Icon(t.resolveIcon(), size: 18),
              const SizedBox(width: 8),
              Text(t.name, style: const TextStyle(fontSize: 14)),
              if (i == selectedIndex)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.check, size: 16, color: Colors.blue),
                ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        width: 72,
        height: 60,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(workspace.resolveIcon(), size: 22, color: const Color(0xFF1A1A1A)),
            const SizedBox(height: 2),
            Text(
              workspace.name,
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
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
  final List<WorkspaceInfo> workspaces;
  final int selectedWorkspace;
  final ValueChanged<int> onWorkspaceChanged;
  final List<NavSection> sections;
  final int selectedIndex;
  final ValueChanged<int> onItemTap;

  const NavSidebar({
    super.key,
    required this.workspaces,
    required this.selectedWorkspace,
    required this.onWorkspaceChanged,
    required this.sections,
    required this.selectedIndex,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    int flatIndex = 0;

    if (workspaces.isEmpty) {
      return const SizedBox(width: 72);
    }

    return Container(
      width: 72,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          const SizedBox(height: 4),
          WorkspaceSwitcher(
            workspaces: workspaces,
            selectedIndex: selectedWorkspace,
            onChanged: onWorkspaceChanged,
          ),
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
              if (section.dividerBefore && items.isNotEmpty)
                buildNavDivider(),
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
