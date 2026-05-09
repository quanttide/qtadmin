import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qtadmin_org/org.dart';
import 'package:qtadmin_studio/screens/org_screen.dart';

OrgDashboard _createTestData() {
  return OrgDashboard(
    institutions: [
      OrgInstitution(
        id: 'shareholders',
        name: '股东代表大会',
        parentId: '',
        level: 0,
        status: InstitutionStatus.normal,
        expectedFrequency: '每季一次',
        lastMeetingDate: '15天前',
        nextMeetingDate: '75天后',
        pendingProposalCount: 0,
      ),
      OrgInstitution(
        id: 'partner',
        name: '合伙人委员会',
        parentId: 'shareholders',
        level: 1,
        status: InstitutionStatus.normal,
        expectedFrequency: '每月一次',
        lastMeetingDate: '3天前',
        nextMeetingDate: '28天后',
        pendingProposalCount: 0,
      ),
      OrgInstitution(
        id: 'assembly',
        name: '公司代表大会',
        parentId: '',
        level: 0,
        status: InstitutionStatus.normal,
        expectedFrequency: '每月一次',
        lastMeetingDate: '5天前',
        nextMeetingDate: '25天后',
        pendingProposalCount: 1,
      ),
      OrgInstitution(
        id: 'tech',
        name: '技术委员会',
        parentId: 'assembly',
        level: 1,
        status: InstitutionStatus.overdue,
        expectedFrequency: '每周一次',
        lastMeetingDate: '12天前',
        nextMeetingDate: '逾期',
        pendingProposalCount: 3,
      ),
    ],
    representatives: [
      OrgRepresentative(
        id: 'p1',
        name: '张三',
        institutionIds: ['partner'],
        rank: 'M1',
        term: '2026Q1-Q2',
        attendanceRate: 100,
        proposalCount: 5,
        voteRate: 100,
        objectionCount: 1,
        tier: RepPerformanceTier.green,
        recentVotes: [
          OrgMeeting(
            id: 'm1',
            institutionId: 'partner',
            date: '2026-05-06',
            title: '预算审批会议',
            agendaItems: ['Q3预算审批'],
            attendeeCount: 9,
            totalMemberCount: 10,
          ),
        ],
      ),
      OrgRepresentative(
        id: 'p2',
        name: '李四',
        institutionIds: ['tech'],
        rank: 'M2',
        term: '2026Q1-Q2',
        attendanceRate: 60,
        proposalCount: 2,
        voteRate: 70,
        objectionCount: 0,
        tier: RepPerformanceTier.yellow,
        recentVotes: [],
      ),
    ],
    ranks: [
      OrgRank(name: '专业序列', isManagement: false, headCount: 5),
      OrgRank(name: 'M1', isManagement: true, headCount: 2),
    ],
    promotions: [
      OrgPromotion(
        id: 'pr1',
        personName: '王五',
        fromRank: '专业序列',
        toRank: 'M1',
        date: '2026-04-01',
        isCrossTrack: true,
      ),
    ],
  );
}

void main() {
  group('OrgScreen rendering', () {
    testWidgets('renders header with title and subtitle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: OrgScreen(data: _createTestData())),
        ),
      );

      expect(find.text('组织管理'), findsOneWidget);
      expect(find.text('职能线'), findsOneWidget);
    });

    testWidgets('renders stats bar with counts', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: OrgScreen(data: _createTestData())),
        ),
      );

      expect(find.text('机构'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('代表'), findsOneWidget);
      expect(find.text('2'), findsWidgets);
      expect(find.text('职级'), findsOneWidget);
      expect(find.text('待晋升'), findsOneWidget);
      expect(find.text('1'), findsWidgets);
    });

    testWidgets('renders institution cards with names and statuses', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: OrgScreen(data: _createTestData())),
        ),
      );

      expect(find.text('合伙人委员会'), findsOneWidget);
      expect(find.text('技术委员会'), findsOneWidget);
      expect(find.text('正常'), findsWidgets);
      expect(find.text('逾期'), findsWidgets);
    });

    testWidgets('renders institution info rows', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: OrgScreen(data: _createTestData())),
        ),
      );

      expect(find.text('每月一次'), findsWidgets);
      expect(find.text('每周一次'), findsWidgets);
      expect(find.text('3 条'), findsOneWidget);
    });

    testWidgets('renders representative cards with names and ranks', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: OrgScreen(data: _createTestData())),
        ),
      );

      expect(find.text('张三'), findsOneWidget);
      expect(find.text('李四'), findsOneWidget);
      expect(find.textContaining('绿标'), findsOneWidget);
      expect(find.textContaining('黄标'), findsOneWidget);
    });

    testWidgets('expands representative to show details on tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: OrgScreen(data: _createTestData())),
        ),
      );

      expect(find.text('任期'), findsNothing);
      expect(find.text('2026Q1-Q2'), findsNothing);

      await tester.scrollUntilVisible(find.text('张三'), 100);
      await tester.tap(find.text('张三'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('任期'), 100);
      expect(find.text('任期'), findsOneWidget);
      expect(find.text('2026Q1-Q2'), findsOneWidget);
      expect(find.text('提案数'), findsOneWidget);
      expect(find.text('5 次'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('近期表决'), 100);
      await tester.pumpAndSettle();
      expect(find.text('近期表决'), findsOneWidget);
    });

    testWidgets('renders rank flow section', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: OrgScreen(data: _createTestData())),
        ),
      );

      expect(find.text('专业序列 5人'), findsOneWidget);
      expect(find.text('M1 2人'), findsOneWidget);
    });

    testWidgets('renders promotion records', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: OrgScreen(data: _createTestData())),
        ),
      );

      expect(find.text('晋升记录'), findsOneWidget);
      expect(find.text('王五'), findsOneWidget);
      expect(find.text('专业序列 → M1'), findsOneWidget);
      expect(find.text('2026-04-01'), findsOneWidget);
      expect(find.text('跨序列'), findsOneWidget);
    });

    testWidgets('renders panel headers', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: OrgScreen(data: _createTestData())),
        ),
      );

      expect(find.text('机构看板'), findsOneWidget);
      expect(find.text('4 个机构'), findsOneWidget);
      expect(find.text('代表履职'), findsOneWidget);
      expect(find.text('2 位代表'), findsOneWidget);
      expect(find.text('职级流动'), findsOneWidget);
      expect(find.text('2 个职级'), findsOneWidget);
    });

    testWidgets('supports vertical scrolling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: OrgScreen(data: _createTestData())),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
