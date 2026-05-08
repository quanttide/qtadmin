import 'package:flutter/material.dart';
import 'package:qtadmin_studio/models/dashboard.dart';
import 'package:qtadmin_studio/views/biz_unit_widget.dart';
import 'package:qtadmin_studio/views/section_header.dart';

class BusinessSectionWidget extends StatelessWidget {
  final List<BusinessUnitData> units;
  final bool isMobile;
  final bool showHeader;

  const BusinessSectionWidget({
    super.key,
    required this.units,
    required this.isMobile,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) const SectionHeader(title: '业务线'),
        if (showHeader) const SizedBox(height: 14),
        if (isMobile)
          ...units.map((unit) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: BizUnitWidget(data: unit),
              ))
        else
          _buildDesktopGrid(),
      ],
    );
  }

  Widget _buildDesktopGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 16.0;
        const cols = 3;
        final rows = (units.length + cols - 1) ~/ cols;
        final cardWidth = (constraints.maxWidth - gap * (cols - 1)) / cols;

        return Column(
          children: List.generate(rows, (row) {
            final start = row * cols;
            final end = (start + cols).clamp(0, units.length);
            return Padding(
              padding: EdgeInsets.only(bottom: row < rows - 1 ? gap : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: units.sublist(start, end).asMap().entries.map((entry) {
                  return SizedBox(
                    width: cardWidth,
                    child: Padding(
                      padding: EdgeInsets.only(right: entry.key < cols - 1 && (start + entry.key) < units.length - 1 ? gap : 0),
                      child: BizUnitWidget(data: entry.value),
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        );
      },
    );
  }
}
