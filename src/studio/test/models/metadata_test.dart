import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qtadmin_studio/models/metadata.dart';

void main() {
  group('NavItemData', () {
    test('fromJson parses correctly', () {
      final json = {
        'label': '全景图',
        'icon': 'today_outlined',
        'pageType': 'panorama',
      };
      final item = NavItemData.fromJson(json);

      expect(item.label, '全景图');
      expect(item.icon, 'today_outlined');
      expect(item.pageType, 'panorama');
    });

    test('resolveIcon returns correct IconData for known icon', () {
      final item = NavItemData(label: '测试', icon: 'storage_outlined', pageType: 'detail');
      expect(item.resolveIcon(), Icons.storage_outlined);
    });

    test('resolveIcon returns circle_outlined for unknown icon', () {
      final item = NavItemData(label: '测试', icon: 'nonexistent_icon', pageType: 'detail');
      expect(item.resolveIcon(), Icons.circle_outlined);
    });

    test('resolveIcon handles all known icon names', () {
      final testCases = {
        'person_outline': Icons.person_outline,
        'business_outlined': Icons.business_outlined,
        'today_outlined': Icons.today_outlined,
        'storage_outlined': Icons.storage_outlined,
        'school_outlined': Icons.school_outlined,
        'support_agent_outlined': Icons.support_agent_outlined,
        'cloud_outlined': Icons.cloud_outlined,
        'psychology_outlined': Icons.psychology_outlined,
        'edit_outlined': Icons.edit_outlined,
        'people_outline': Icons.people_outline,
        'account_balance_outlined': Icons.account_balance_outlined,
        'account_tree_outlined': Icons.account_tree_outlined,
        'track_changes_outlined': Icons.track_changes_outlined,
        'campaign_outlined': Icons.campaign_outlined,
      };

      for (final entry in testCases.entries) {
        final item = NavItemData(label: '', icon: entry.key, pageType: '');
        expect(item.resolveIcon(), entry.value,
            reason: 'Icon "${entry.key}" should resolve to ${entry.value}');
      }
    });
  });

  group('NavSectionData', () {
    test('fromJson parses id and items correctly', () {
      final json = {
        'id': 'panorama',
        'items': [
          {'label': '全景图', 'icon': 'today_outlined', 'pageType': 'panorama'},
          {'label': '思考', 'icon': 'psychology_outlined', 'pageType': 'thinking'},
        ],
      };
      final section = NavSectionData.fromJson(json);

      expect(section.id, 'panorama');
      expect(section.items.length, 2);
      expect(section.items[0].label, '全景图');
      expect(section.items[1].label, '思考');
      expect(section.items[1].pageType, 'thinking');
    });

    test('fromJson handles empty items', () {
      final json = {'id': 'business', 'items': <dynamic>[]};
      final section = NavSectionData.fromJson(json);
      expect(section.items, isEmpty);
    });
  });

  group('TenantInfo', () {
    test('fromJson parses correctly with dir', () {
      final json = {'name': '量潮科技', 'icon': 'business_outlined', 'dir': 'company'};
      final info = TenantInfo.fromJson(json);

      expect(info.name, '量潮科技');
      expect(info.icon, 'business_outlined');
      expect(info.dir, 'company');
    });

    test('resolveIcon returns correct IconData for person_outline', () {
      final info = TenantInfo(name: '量潮创始人', icon: 'person_outline', dir: 'founder');
      expect(info.resolveIcon(), Icons.person_outline);
    });

    test('resolveIcon returns correct IconData for business_outlined', () {
      final info = TenantInfo(name: '量潮科技', icon: 'business_outlined', dir: 'company');
      expect(info.resolveIcon(), Icons.business_outlined);
    });

    test('resolveIcon returns circle_outlined for unknown icon', () {
      final info = TenantInfo(name: '测试', icon: 'unknown', dir: 'test');
      expect(info.resolveIcon(), Icons.circle_outlined);
    });
  });

  group('NavMetadata', () {
    test('fromJson parses founder metadata correctly', () {
      final json = {
        'sections': [
          {
            'id': 'panorama',
            'items': [
              {'label': '全景图', 'icon': 'today_outlined', 'pageType': 'panorama'},
            ],
          },
          {
            'id': 'business',
            'items': [
              {'label': '思考', 'icon': 'psychology_outlined', 'pageType': 'thinking'},
              {'label': '写作', 'icon': 'edit_outlined', 'pageType': 'writing'},
            ],
          },
        ],
      };
      final metadata = NavMetadata.fromJson(json);

      expect(metadata.sections.length, 2);
      expect(metadata.sections[0].id, 'panorama');
      expect(metadata.sections[0].items.length, 1);
      expect(metadata.sections[1].id, 'business');
      expect(metadata.sections[1].items.length, 2);
    });

    test('fromJson parses company metadata correctly', () {
      final json = {
        'sections': [
          {
            'id': 'panorama',
            'items': [
              {'label': '全景图', 'icon': 'today_outlined', 'pageType': 'panorama'},
            ],
          },
          {
            'id': 'business',
            'items': [
              {'label': '量潮数据', 'icon': 'storage_outlined', 'pageType': 'business_detail'},
              {'label': '量潮课堂', 'icon': 'school_outlined', 'pageType': 'business_detail'},
              {'label': '量潮咨询', 'icon': 'support_agent_outlined', 'pageType': 'consulting'},
              {'label': '量潮云', 'icon': 'cloud_outlined', 'pageType': 'business_detail'},
            ],
          },
          {
            'id': 'function',
            'items': [
              {'label': '人力资源', 'icon': 'people_outline', 'pageType': 'function_detail'},
              {'label': '财务管理', 'icon': 'account_balance_outlined', 'pageType': 'function_detail'},
              {'label': '组织管理', 'icon': 'account_tree_outlined', 'pageType': 'function_detail'},
              {'label': '战略管理', 'icon': 'track_changes_outlined', 'pageType': 'function_detail'},
              {'label': '新媒体', 'icon': 'campaign_outlined', 'pageType': 'function_detail'},
            ],
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
          {'id': 'a', 'items': [{'label': 'A', 'icon': 'today_outlined', 'pageType': 'panorama'}]},
          {'id': 'b', 'items': [{'label': 'B', 'icon': 'psychology_outlined', 'pageType': 'thinking'}, {'label': 'C', 'icon': 'edit_outlined', 'pageType': 'writing'}]},
          {'id': 'c', 'items': [{'label': 'D', 'icon': 'people_outline', 'pageType': 'function_detail'}]},
        ],
      };
      final metadata = NavMetadata.fromJson(json);

      expect(metadata.allItems.length, 4);
      expect(metadata.allItems.map((i) => i.label), ['A', 'B', 'C', 'D']);
    });
  });

  group('SectionDef', () {
    test('fromJson parses correctly', () {
      final json = {'id': 'panorama', 'dividerBefore': false};
      final def = SectionDef.fromJson(json);

      expect(def.id, 'panorama');
      expect(def.dividerBefore, false);
    });
  });

  group('RootMetadata', () {
    test('fromJson parses tenants and sections', () {
      final json = {
        'tenants': [
          {'name': '量潮创始人', 'icon': 'person_outline', 'dir': 'founder'},
          {'name': '量潮科技', 'icon': 'business_outlined', 'dir': 'company'},
        ],
        'sections': [
          {'id': 'panorama', 'dividerBefore': false},
          {'id': 'business', 'dividerBefore': true},
          {'id': 'function', 'dividerBefore': true},
        ],
      };
      final root = RootMetadata.fromJson(json);

      expect(root.tenants.length, 2);
      expect(root.tenants[0].name, '量潮创始人');
      expect(root.tenants[1].dir, 'company');
      expect(root.sections.length, 3);
      expect(root.sections[0].dividerBefore, false);
      expect(root.sections[2].id, 'function');
    });

    test('tenantById finds tenant by dir', () {
      final root = RootMetadata(
        tenants: [
          TenantInfo(name: 'A', icon: 'person_outline', dir: 'founder'),
          TenantInfo(name: 'B', icon: 'business_outlined', dir: 'company'),
        ],
        sections: [],
      );

      expect(root.tenantById('company').name, 'B');
    });

    test('sectionById finds section by id', () {
      final root = RootMetadata(
        tenants: [TenantInfo(name: 'A', icon: 'person_outline', dir: 'a')],
        sections: [
          SectionDef(id: 'panorama', dividerBefore: false),
          SectionDef(id: 'business', dividerBefore: true),
        ],
      );

      expect(root.sectionById('business').dividerBefore, true);
    });
  });
}
