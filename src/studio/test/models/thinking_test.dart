import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qtadmin_think/think.dart';

void main() {
  group('resolveThinkingIcon', () {
    test('returns correct icons for known names', () {
      expect(resolveThinkingIcon('explore_outlined'), Icons.explore_outlined);
      expect(resolveThinkingIcon('construction_outlined'), Icons.construction_outlined);
      expect(resolveThinkingIcon('auto_awesome_outlined'), Icons.auto_awesome_outlined);
      expect(resolveThinkingIcon('rocket_launch_outlined'), Icons.rocket_launch_outlined);
      expect(resolveThinkingIcon('psychology_outlined'), Icons.psychology_outlined);
      expect(resolveThinkingIcon('chat_outlined'), Icons.chat_outlined);
      expect(resolveThinkingIcon('transform_outlined'), Icons.transform_outlined);
      expect(resolveThinkingIcon('touch_app_outlined'), Icons.touch_app_outlined);
      expect(resolveThinkingIcon('short_text_outlined'), Icons.short_text_outlined);
    });

    test('returns circle_outlined for unknown name', () {
      expect(resolveThinkingIcon('nonexistent'), Icons.circle_outlined);
    });
  });
}
