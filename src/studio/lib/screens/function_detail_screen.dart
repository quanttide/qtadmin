import 'package:flutter/material.dart';
import 'package:qtadmin_studio/models/dashboard.dart';
import 'package:qtadmin_studio/views/func_card_widget.dart';

class FuncDetailScreen extends StatelessWidget {
  final FuncCardData card;

  const FuncDetailScreen({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 14 : 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: FuncCardWidget(data: card),
          ),
        );
      },
    );
  }
}
