import 'package:flutter/material.dart';
import 'package:qtadmin_studio/models/panorama.dart';
import 'package:qtadmin_studio/widgets/business_section_widget.dart';

class BusinessScreen extends StatelessWidget {
  final PanoramaData data;

  const BusinessScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 14 : 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: BusinessSectionWidget(
              units: data.businessUnits,
              isMobile: isMobile,
            ),
          ),
        );
      },
    );
  }
}
