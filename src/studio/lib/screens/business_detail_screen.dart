import 'package:flutter/material.dart';
import 'package:qtadmin_studio/models/dashboard.dart';
import 'package:qtadmin_studio/views/biz_unit_widget.dart';

class BusinessDetailScreen extends StatelessWidget {
  final BusinessUnitData unit;

  const BusinessDetailScreen({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 14 : 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BizUnitWidget(data: unit),
              ],
            ),
          ),
        );
      },
    );
  }
}
