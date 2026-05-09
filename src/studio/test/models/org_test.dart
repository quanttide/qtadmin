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
        'id': 'exec',
        'name': '执行委员会',
        'parentId': 'assembly',
        'level': 2,
        'status': 'warning',
        'lastMeetingDate': '7天前',
        'nextMeetingDate': '明天',
        'expectedFrequency': '每周一次',
        'memberIds': ['p1', 'p2'],
        'pendingProposalCount': 2,
      };
      final inst = OrgInstitution.fromJson(json);

      expect(inst.id, 'exec');
      expect(inst.name, '执行委员会');
      expect(inst.parentId, 'assembly');
      expect(inst.level, 2);
      expect(inst.status, InstitutionStatus.warning);
      expect(inst.lastMeetingDate, '7天前');
      expect(inst.nextMeetingDate, '明天');
      expect(inst.expectedFrequency, '每周一次');
      expect(inst.memberIds, ['p1', 'p2']);
      expect(inst.pendingProposalCount, 2);
    });

    test('fromJson defaults parentId to empty string', () {
      final json = {
        'id': 'partner',
        'name': '合伙人委员会',
        'level': 0,
        'status': 'normal',
        'expectedFrequency': '每月一次',
      };
      final inst = OrgInstitution.fromJson(json);

      expect(inst.parentId, '');
      expect(inst.memberIds, isEmpty);
      expect(inst.pendingProposalCount, 0);
    });
  });

  group('OrgMeeting', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'm1',
        'institutionId': 'secretary',
        'date': '2026-05-06',
        'title': '预算审批会议',
        'agendaItems': ['Q3预算审批'],
        'attendeeCount': 9,
        'totalMemberCount': 10,
      };
      final meeting = OrgMeeting.fromJson(json);

      expect(meeting.id, 'm1');
      expect(meeting.title, '预算审批会议');
      expect(meeting.agendaItems, ['Q3预算审批']);
      expect(meeting.attendeeCount, 9);
    });

    test('fromJson defaults agendaItems to empty list', () {
      final json = {
        'id': 'm2',
        'institutionId': 'secretary',
        'date': '2026-04-29',
        'title': '周例会',
      };
      final meeting = OrgMeeting.fromJson(json);

      expect(meeting.agendaItems, isEmpty);
      expect(meeting.attendeeCount, 0);
    });
  });

  group('OrgRepresentative', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'p1',
        'name': '张三',
        'institutionIds': ['secretary', 'exec'],
        'rank': 'M1',
        'term': '2026Q1-Q2',
        'attendanceRate': 100,
        'proposalCount': 5,
        'voteRate': 100,
        'objectionCount': 1,
        'tier': 'green',
        'recentVotes': [
          {
            'id': 'm1',
            'institutionId': 'secretary',
            'date': '2026-05-06',
            'title': '预算审批会议',
            'agendaItems': ['Q3预算审批'],
            'attendeeCount': 9,
            'totalMemberCount': 10,
          },
        ],
      };
      final rep = OrgRepresentative.fromJson(json);

      expect(rep.id, 'p1');
      expect(rep.name, '张三');
      expect(rep.institutionIds, ['secretary', 'exec']);
      expect(rep.rank, 'M1');
      expect(rep.tier, RepPerformanceTier.green);
      expect(rep.attendanceRate, 100);
      expect(rep.recentVotes.length, 1);
      expect(rep.recentVotes[0].title, '预算审批会议');
    });

    test('fromJson defaults recentVotes to empty list', () {
      final json = {
        'id': 'p2',
        'name': '李四',
        'institutionIds': ['exec'],
        'rank': 'M2',
        'term': '2026Q1-Q2',
        'tier': 'yellow',
      };
      final rep = OrgRepresentative.fromJson(json);

      expect(rep.recentVotes, isEmpty);
      expect(rep.attendanceRate, 0);
      expect(rep.proposalCount, 0);
    });
  });

  group('OrgRank', () {
    test('fromJson parses correctly', () {
      final json = {
        'name': 'M1',
        'isManagement': true,
        'headCount': 2,
      };
      final rank = OrgRank.fromJson(json);

      expect(rank.name, 'M1');
      expect(rank.isManagement, true);
      expect(rank.headCount, 2);
    });

    test('fromJson defaults isManagement to false', () {
      final json = {
        'name': '专业序列',
        'headCount': 5,
      };
      final rank = OrgRank.fromJson(json);

      expect(rank.isManagement, false);
      expect(rank.headCount, 5);
    });
  });

  group('OrgPromotion', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'pr1',
        'personName': '王五',
        'fromRank': '专业序列',
        'toRank': 'M1',
        'date': '2026-04-01',
        'isCrossTrack': true,
      };
      final prom = OrgPromotion.fromJson(json);

      expect(prom.id, 'pr1');
      expect(prom.personName, '王五');
      expect(prom.fromRank, '专业序列');
      expect(prom.toRank, 'M1');
      expect(prom.isCrossTrack, true);
    });

    test('fromJson defaults isCrossTrack to false', () {
      final json = {
        'id': 'pr2',
        'personName': '赵六',
        'fromRank': 'M1',
        'toRank': 'M2',
        'date': '2026-05-01',
      };
      final prom = OrgPromotion.fromJson(json);

      expect(prom.isCrossTrack, false);
    });
  });

  group('OrgDashboard', () {
    test('fromJson parses full org dashboard data', () {
      final json = {
        'institutions': [
          {
            'id': 'partner',
            'name': '合伙人委员会',
            'parentId': '',
            'level': 0,
            'status': 'normal',
            'expectedFrequency': '每月一次',
          },
        ],
        'representatives': [
          {
            'id': 'p1',
            'name': '张三',
            'institutionIds': ['secretary'],
            'rank': 'M1',
            'term': '2026Q1-Q2',
            'tier': 'green',
          },
        ],
        'ranks': [
          {'name': '专业序列', 'headCount': 5},
        ],
        'promotions': [
          {
            'id': 'pr1',
            'personName': '王五',
            'fromRank': '专业序列',
            'toRank': 'M1',
            'date': '2026-04-01',
          },
        ],
      };
      final data = OrgDashboard.fromJson(json);

      expect(data.institutions.length, 1);
      expect(data.representatives.length, 1);
      expect(data.ranks.length, 1);
      expect(data.promotions.length, 1);
      expect(data.institutions[0].name, '合伙人委员会');
      expect(data.representatives[0].name, '张三');
      expect(data.ranks[0].name, '专业序列');
      expect(data.promotions[0].personName, '王五');
    });
  });
}
