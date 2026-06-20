import 'package:flutter_test/flutter_test.dart';
import 'package:qtadmin_org/org.dart';

void main() {
  group('InstitutionStatus', () {
    test('byName resolves correctly', () {
      expect(InstitutionStatus.values.byName('normal'), InstitutionStatus.normal);
      expect(InstitutionStatus.values.byName('warning'), InstitutionStatus.warning);
      expect(InstitutionStatus.values.byName('overdue'), InstitutionStatus.overdue);
    });
  });

  group('RepPerformanceTier', () {
    test('byName resolves correctly', () {
      expect(RepPerformanceTier.values.byName('green'), RepPerformanceTier.green);
      expect(RepPerformanceTier.values.byName('yellow'), RepPerformanceTier.yellow);
      expect(RepPerformanceTier.values.byName('red'), RepPerformanceTier.red);
    });
  });

  group('OrgInstitution', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'inst1',
        'name': '股东会',
        'level': 1,
        'status': 'normal',
        'lastMeetingDate': '2025-01-15',
        'nextMeetingDate': '2025-04-15',
        'expectedFrequency': '每季度1次',
        'memberIds': ['rep1', 'rep2'],
        'pendingProposalCount': 3,
      };
      final inst = OrgInstitution.fromJson(json);
      expect(inst.name, '股东会');
      expect(inst.level, 1);
      expect(inst.status, InstitutionStatus.normal);
      expect(inst.pendingProposalCount, 3);
    });

    test('fromJson defaults parentId to empty string', () {
      final json = {
        'id': 'inst2',
        'name': '董事会',
        'level': 2,
        'status': 'warning',
      };
      final inst = OrgInstitution.fromJson(json);
      expect(inst.parentId, '');
      expect(inst.pendingProposalCount, 0);
    });

    test('copyWith creates updated copy', () {
      final original = OrgInstitution(
        id: 'inst1',
        name: '股东会',
        status: InstitutionStatus.normal,
      );
      final updated = original.copyWith(status: InstitutionStatus.warning);
      expect(updated.status, InstitutionStatus.warning);
      expect(updated.name, '股东会');
    });
  });

  group('OrgMeeting', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'mtg1',
        'institutionId': 'inst1',
        'date': '2025-01-15',
        'title': '第一季度会议',
        'agendaItems': ['预算审批', '人事任命'],
        'attendeeCount': 5,
        'totalMemberCount': 7,
      };
      final mtg = OrgMeeting.fromJson(json);
      expect(mtg.title, '第一季度会议');
      expect(mtg.attendeeCount, 5);
    });

    test('fromJson defaults lists and counts', () {
      final json = {
        'id': 'mtg2',
        'institutionId': 'inst2',
        'date': '2025-02-01',
        'title': '临时会议',
      };
      final mtg = OrgMeeting.fromJson(json);
      expect(mtg.agendaItems, isEmpty);
      expect(mtg.attendeeCount, 0);
    });
  });

  group('OrgRepresentative', () {
    test('fromJson parses correctly with full data', () {
      final json = {
        'id': 'rep1',
        'name': '张三',
        'institutionIds': ['inst1'],
        'rank': '董事长',
        'term': '2024-2026',
        'attendanceRate': 0.95,
        'proposalCount': 12,
        'voteRate': 0.98,
        'objectionCount': 1,
        'tier': 'green',
        'recentVotes': [
          {
            'id': 'mtg1',
            'institutionId': 'inst1',
            'date': '2025-01-15',
            'title': '第一季度会议',
          },
        ],
      };
      final rep = OrgRepresentative.fromJson(json);
      expect(rep.name, '张三');
      expect(rep.tier, RepPerformanceTier.green);
      expect(rep.recentVotes.length, 1);
    });
  });

  group('OrgRank', () {
    test('fromJson parses correctly', () {
      final json = {'name': '董事长', 'isManagement': true, 'headCount': 1};
      final rank = OrgRank.fromJson(json);
      expect(rank.name, '董事长');
      expect(rank.isManagement, true);
    });
  });

  group('OrgPromotion', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'promo1',
        'personName': '李四',
        'fromRank': '经理',
        'toRank': '高级经理',
        'date': '2025-03-01',
      };
      final promo = OrgPromotion.fromJson(json);
      expect(promo.personName, '李四');
      expect(promo.isCrossTrack, false);
    });

    test('fromJson defaults isCrossTrack to false', () {
      final json = {
        'id': 'promo2',
        'personName': '王五',
        'fromRank': '专员',
        'toRank': '主管',
        'date': '2025-04-01',
      };
      final promo = OrgPromotion.fromJson(json);
      expect(promo.isCrossTrack, false);
    });
  });

  group('OrgDashboard', () {
    test('fromJson parses correctly', () {
      final json = {
        'institutions': [
          {'id': 'inst1', 'name': '股东会', 'level': 1, 'status': 'normal'},
        ],
        'representatives': [
          {
            'id': 'rep1',
            'name': '张三',
            'institutionIds': ['inst1'],
            'rank': '董事长',
            'tier': 'green',
          },
        ],
        'ranks': [
          {'name': '董事长', 'isManagement': true, 'headCount': 1},
        ],
        'promotions': [
          {
            'id': 'promo1',
            'personName': '李四',
            'fromRank': '经理',
            'toRank': '高级经理',
            'date': '2025-03-01',
          },
        ],
      };
      final dashboard = OrgDashboard.fromJson(json);
      expect(dashboard.institutions.length, 1);
      expect(dashboard.representatives.length, 1);
      expect(dashboard.ranks.length, 1);
      expect(dashboard.promotions.length, 1);
    });
  });
}
