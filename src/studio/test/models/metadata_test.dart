import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qtadmin_studio/models/metadata.dart';

void main() {
  group('NavEntry', () {
    test('fromJson parses string name correctly', () {
      final item = NavEntry.fromJson('dashboard');

      expect(item.name, 'dashboard');
    });
  });

  group('NavSectionDef', () {
    test('fromJson parses id and string items correctly', () {
      final json = {
        'id': 'dashboard',
        'items': ['dashboard', 'thinking'],
      };
      final section = NavSectionDef.fromJson(json);

      expect(section.id, 'dashboard');
      expect(section.items.length, 2);
      expect(section.items[0].name, 'dashboard');
      expect(section.items[1].name, 'thinking');
    });

    test('fromJson handles empty items', () {
      final json = {'id': 'business', 'items': <dynamic>[]};
      final section = NavSectionDef.fromJson(json);
      expect(section.items, isEmpty);
    });
  });

  group('WorkspaceInfo', () {
    test('fromJson parses correctly with dir', () {
      final json = {'name': '量潮科技', 'icon': 'business_outlined', 'dir': 'company'};
      final info = WorkspaceInfo.fromJson(json);

      expect(info.name, '量潮科技');
      expect(info.icon, 'business_outlined');
      expect(info.dir, 'company');
    });

    test('resolveIcon returns correct IconData for person_outline', () {
      final info = WorkspaceInfo(name: '量潮创始人', icon: 'person_outline', dir: 'founder');
      expect(info.resolveIcon(), Icons.person_outline);
    });

    test('resolveIcon returns correct IconData for business_outlined', () {
      final info = WorkspaceInfo(name: '量潮科技', icon: 'business_outlined', dir: 'company');
      expect(info.resolveIcon(), Icons.business_outlined);
    });

    test('resolveIcon returns circle_outlined for unknown icon', () {
      final info = WorkspaceInfo(name: '测试', icon: 'unknown', dir: 'test');
      expect(info.resolveIcon(), Icons.circle_outlined);
    });
  });

  group('NavMetadata', () {
    test('fromJson parses founder metadata correctly', () {
      final json = {
        'sections': [
          {
            'id': 'dashboard',
            'items': ['dashboard'],
          },
          {
            'id': 'business',
            'items': ['thinking', 'writing'],
          },
        ],
      };
      final metadata = NavMetadata.fromJson(json);

      expect(metadata.sections.length, 2);
      expect(metadata.sections[0].id, 'dashboard');
      expect(metadata.sections[0].items.length, 1);
      expect(metadata.sections[0].items[0].name, 'dashboard');
      expect(metadata.sections[1].id, 'business');
      expect(metadata.sections[1].items.length, 2);
      expect(metadata.sections[1].items[1].name, 'writing');
    });

    test('fromJson parses company metadata correctly', () {
      final json = {
        'sections': [
          {
            'id': 'dashboard',
            'items': ['dashboard'],
          },
          {
            'id': 'business',
            'items': ['data', 'classroom', 'consulting', 'cloud'],
          },
          {
            'id': 'function',
            'items': ['hr', 'finance', 'org', 'strategy', 'media'],
          },
        ],
      };
      final metadata = NavMetadata.fromJson(json);

      expect(metadata.sections.length, 3);
      expect(metadata.sections[2].id, 'function');
      expect(metadata.sections[2].items.length, 5);
    });

    test('allItems flattens all items across sections', () {
      final json = {
        'sections': [
          {'id': 'a', 'items': ['A']},
          {'id': 'b', 'items': ['B', 'C']},
          {'id': 'c', 'items': ['D']},
        ],
      };
      final metadata = NavMetadata.fromJson(json);

      expect(metadata.allItems.length, 4);
      expect(metadata.allItems.map((i) => i.name), ['A', 'B', 'C', 'D']);
    });
  });

  group('SectionDef', () {
    test('fromJson parses correctly', () {
      final json = {'id': 'dashboard', 'dividerBefore': false};
      final def = SectionDef.fromJson(json);

      expect(def.id, 'dashboard');
      expect(def.dividerBefore, false);
    });
  });

  group('RootMetadata', () {
    test('fromJson parses workspaces and sections', () {
      final json = {
        'workspaces': [
          {'name': '量潮创始人', 'icon': 'person_outline', 'dir': 'founder'},
          {'name': '量潮科技', 'icon': 'business_outlined', 'dir': 'company'},
        ],
        'sections': [
          {'id': 'dashboard', 'dividerBefore': false},
          {'id': 'business', 'dividerBefore': true},
          {'id': 'function', 'dividerBefore': true},
        ],
      };
      final root = RootMetadata.fromJson(json);

      expect(root.workspaces.length, 2);
      expect(root.workspaces[0].name, '量潮创始人');
      expect(root.workspaces[1].dir, 'company');
      expect(root.sections.length, 3);
      expect(root.sections[0].dividerBefore, false);
      expect(root.sections[2].id, 'function');
    });

    test('workspaceById finds workspace by dir', () {
      final root = RootMetadata(
        workspaces: [
          WorkspaceInfo(name: 'A', icon: 'person_outline', dir: 'founder'),
          WorkspaceInfo(name: 'B', icon: 'business_outlined', dir: 'company'),
        ],
        sections: [],
      );

      expect(root.workspaceById('company').name, 'B');
    });

    test('sectionById finds section by id', () {
      final root = RootMetadata(
        workspaces: [WorkspaceInfo(name: 'A', icon: 'person_outline', dir: 'a')],
        sections: [
          SectionDef(id: 'dashboard', dividerBefore: false),
          SectionDef(id: 'business', dividerBefore: true),
        ],
      );

      expect(root.sectionById('business').dividerBefore, true);
    });
  });
}
