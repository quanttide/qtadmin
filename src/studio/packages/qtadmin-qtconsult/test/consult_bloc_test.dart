import 'package:flutter_test/flutter_test.dart';
import 'package:qtadmin_qtconsult/consult.dart';

QtConsult _createTestData() {
  return QtConsult(
    workspace: WorkspaceType.customer,
    projectName: '测试项目',
    phase: '调研',
    industry: '科技',
    scale: '中型',
    maturity: '成长期',
    strategyGoal: '提升市场份额',
    strategyInsight: '需要聚焦',
    strategySteps: ['第一步'],
    riskNote: '无',
    discoveries: [
      Discovery(
        id: 'd1', text: '发现1', type: DiscoveryType.risk,
        source: '测试', date: '5月1日',
      ),
      Discovery(
        id: 'd2', text: '发现2', type: DiscoveryType.opportunity,
        source: '测试', date: '5月2日',
        status: DiscoveryStatus.confirmed,
      ),
    ],
    communications: [],
    revisions: [
      StrategyRevision(id: 'r1', date: '5月1日', reason: '需要审视', relatedDiscoveryId: 'd1'),
    ],
    stakeholders: [
      Stakeholder(id: 's1', name: '张三', role: 'CEO', stance: StakeStance.support, concern: '成本', detail: '细节'),
    ],
  );
}

void main() {
  late ConsultBloc bloc;
  late QtConsult initial;

  setUp(() {
    initial = _createTestData();
    bloc = ConsultBloc(ConsultState(data: initial));
  });

  group('ConsultBloc', () {
    test('initial state has data', () {
      expect(bloc.state.data.projectName, '测试项目');
      expect(bloc.state.data.discoveries.length, 2);
      expect(bloc.state.data.revisions.length, 1);
    });

    test('ConfirmDiscovery changes status to confirmed', () async {
      bloc.add(ConfirmDiscovery('d1'));
      await pumpEventQueue();
      expect(bloc.state.data.discoveries[0].status, DiscoveryStatus.confirmed);
    });

    test('ConfirmDiscovery leaves other discoveries unchanged', () async {
      bloc.add(ConfirmDiscovery('d1'));
      await pumpEventQueue();
      expect(bloc.state.data.discoveries[1].status, DiscoveryStatus.confirmed);
    });

    test('DismissDiscovery changes status to dismissed', () async {
      bloc.add(DismissDiscovery('d1'));
      await pumpEventQueue();
      expect(bloc.state.data.discoveries[0].status, DiscoveryStatus.dismissed);
    });

    test('AddDiscovery inserts new discovery at end', () async {
      bloc.add(AddDiscovery(
        text: '新发现', type: DiscoveryType.concern,
        source: '测试', date: '5月3日',
      ));
      await pumpEventQueue();
      expect(bloc.state.data.discoveries.length, 3);
      expect(bloc.state.data.discoveries.last.text, '新发现');
    });

    test('DeleteDiscovery removes discovery and linked revisions', () async {
      bloc.add(DeleteDiscovery('d1'));
      await pumpEventQueue();
      expect(bloc.state.data.discoveries.length, 1);
      expect(bloc.state.data.discoveries[0].id, 'd2');
      expect(bloc.state.data.revisions.length, 0);
    });

    test('DeleteDiscovery keeps unlinked revisions', () async {
      bloc.add(DeleteDiscovery('d2'));
      await pumpEventQueue();
      expect(bloc.state.data.discoveries.length, 1);
      expect(bloc.state.data.revisions.length, 1);
    });

    test('ReviewRevision marks revision as reviewed', () async {
      bloc.add(ReviewRevision('r1'));
      await pumpEventQueue();
      expect(bloc.state.data.revisions[0].isReviewed, true);
    });

    test('ReviewRevision updates date', () async {
      bloc.add(ReviewRevision('r1'));
      await pumpEventQueue();
      expect(bloc.state.data.revisions[0].date, '5月1日');
    });
  });
}
