import 'package:flutter/material.dart';
import 'package:qtadmin_qtconsult/qtconsult.dart';

Color discoveryDotColor(DiscoveryType type) {
  switch (type) {
    case DiscoveryType.risk:
      return const Color(0xFFB71C1C);
    case DiscoveryType.concern:
      return const Color(0xFFC8690A);
    case DiscoveryType.opportunity:
      return const Color(0xFF1A7F37);
    case DiscoveryType.neutral:
      return const Color(0xFF1A5FDC);
  }
}

Color stanceColor(StakeStance stance) {
  switch (stance) {
    case StakeStance.support:
      return const Color(0xFF1A7F37);
    case StakeStance.neutral:
      return const Color(0xFF777777);
    case StakeStance.oppose:
      return const Color(0xFFB71C1C);
  }
}

Color stanceBgColor(StakeStance stance) {
  switch (stance) {
    case StakeStance.support:
      return const Color(0xFFE8F5E9);
    case StakeStance.neutral:
      return const Color(0xFFF5F5F5);
    case StakeStance.oppose:
      return const Color(0xFFFFEBEE);
  }
}
