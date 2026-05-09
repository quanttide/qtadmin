import 'package:flutter/material.dart';
import 'package:qtadmin_dashboard/dashboard_barrel.dart';

class FunctionSectionWidget extends StatefulWidget {
  final List<FuncCard> cards;
  final bool isMobile;
  final bool showHeader;

  const FunctionSectionWidget({
    super.key,
    required this.cards,
    required this.isMobile,
    this.showHeader = true,
  });

  @override
  State<FunctionSectionWidget> createState() => _FunctionSectionWidgetState();
}

class _FunctionSectionWidgetState extends State<FunctionSectionWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showHeader) const SectionHeader(title: '职能线'),
        if (widget.showHeader) const SizedBox(height: 14),
        if (widget.isMobile)
          _buildMobileGrid()
        else
          _buildDesktopGrid(),
        if (widget.isMobile)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  backgroundColor: const Color(0xFFF5F5F5),
                  foregroundColor: const Color(0xFF888888),
                  side: const BorderSide(color: Color(0xFFDDDDDD), style: BorderStyle.solid, width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
                child: Text(
                  _expanded ? '收起职能模块' : '展开全部职能模块',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDesktopGrid() {
    const gap = 12.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        const cols = 5;
        final cardWidth = (constraints.maxWidth - gap * (cols - 1)) / cols;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.cards.asMap().entries.map((entry) {
            return SizedBox(
              width: cardWidth,
              child: Padding(
                padding: EdgeInsets.only(right: entry.key < widget.cards.length - 1 ? gap : 0),
                child: FuncCardWidget(data: entry.value),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildMobileGrid() {
    return Column(
      children: widget.cards.asMap().entries.map((entry) {
        final i = entry.key;
        final card = entry.value;
        final isVisible = i == 0 || card.isWarning || _expanded;
        if (!isVisible) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: FuncCardWidget(data: card),
        );
      }).toList(),
    );
  }
}
