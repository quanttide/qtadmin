import 'package:flutter/material.dart';
import 'package:qtadmin_studio/models/panorama.dart';
import 'package:qtadmin_studio/widgets/function_section_widget.dart';

class FunctionScreen extends StatelessWidget {
  final PanoramaData data;

  const FunctionScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 14 : 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: FunctionSectionWidget(
              cards: data.functionCards,
              isMobile: isMobile,
            ),
          ),
        );
      },
    );
  }
}
