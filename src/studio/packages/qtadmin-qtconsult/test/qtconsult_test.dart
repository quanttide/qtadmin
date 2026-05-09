import 'package:flutter_test/flutter_test.dart';
import 'package:qtadmin_qtconsult/qtconsult.dart';

void main() {
  group('WorkspaceType', () {
    test('byName resolves correctly', () {
      expect(WorkspaceType.values.byName('customer'), WorkspaceType.customer);
      expect(WorkspaceType.values.byName('internal'), WorkspaceType.internal);
    });
  });

  group('Discovery', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'd1',
        'text': '团队产能利用率不足60%',
        'type': 'concern',
        'status': 'confirmed',
        'source': '量潮云',
        'date': '5月7日',
        'linkedToStrategy': true,
      };
      final discovery = Discovery.fromJson(json);

      expect(discovery.id, 'd1');
      expect(discovery.text, '团队产能利用率不足60%');
      expect(discovery.type, DiscoveryType.concern);
      expect(discovery.status, DiscoveryStatus.confirmed);
      expect(discovery.linkedToStrategy, true);
    });

    test('fromJson defaults linkedToStrategy to false', () {
      final json = {
        'id': 'd2',
        'text': '测试发现',
        'type': 'risk',
        'status': 'pending',
        'source': '测试',
        'date': '5月1日',
      };
      final discovery = Discovery.fromJson(json);

      expect(discovery.linkedToStrategy, false);
    });

    test('copyWith creates updated copy', () {
      final original = Discovery(
        id: 'd1',
        text: '测试',
        type: DiscoveryType.risk,
        status: DiscoveryStatus.pending,
        source: '源',
        date: '5月1日',
      );
      final updated = original.copyWith(
        status: DiscoveryStatus.confirmed,
        linkedToStrategy: true,
      );

      expect(updated.id, 'd1');
      expect(updated.status, DiscoveryStatus.confirmed);
      expect(updated.linkedToStrategy, true);
      expect(updated.type, DiscoveryType.risk);
      expect(updated.date, '5月1日');
    });
  });

  group('Communication', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'c1',
        'title': '需求调研会',
        'date': '5月14日',
        'summary': '与CEO进行了2小时的需求调研',
      };
      final comm = Communication.fromJson(json);

      expect(comm.id, 'c1');
      expect(comm.title, '需求调研会');
      expect(comm.summary, '与CEO进行了2小时的需求调研');
    });
  });

  group('Stakeholder', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 's1',
        'name': 'CEO 张总',
        'role': 'CEO',
        'stance': 'support',
        'concern': '关注降本增效',
        'detail': '项目发起人',
      };
      final stakeholder = Stakeholder.fromJson(json);

      expect(stakeholder.name, 'CEO 张总');
      expect(stakeholder.stance, StakeStance.support);
      expect(stakeholder.stanceLabel, '支持');
    });

    test('stanceLabel returns correct Chinese labels', () {
      expect(
        Stakeholder(id: 's1', name: '', role: '', stance: StakeStance.support, concern: '', detail: '').stanceLabel,
        '支持',
      );
      expect(
        Stakeholder(id: 's2', name: '', role: '', stance: StakeStance.neutral, concern: '', detail: '').stanceLabel,
        '中立',
      );
      expect(
        Stakeholder(id: 's3', name: '', role: '', stance: StakeStance.oppose, concern: '', detail: '').stanceLabel,
        '反对',
      );
    });
  });

  group('StrategyRevision', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'r1',
        'date': '5月7日',
        'reason': '发现产能利用率低',
        'relatedDiscoveryId': 'd1',
        'isReviewed': true,
      };
      final revision = StrategyRevision.fromJson(json);

      expect(revision.id, 'r1');
      expect(revision.reason, '发现产能利用率低');
      expect(revision.isReviewed, true);
    });

    test('fromJson defaults isReviewed to false', () {
      final json = {
        'id': 'r2',
        'date': '5月7日',
        'reason': '测试',
      };
      final revision = StrategyRevision.fromJson(json);

      expect(revision.isReviewed, false);
      expect(revision.relatedDiscoveryId, isNull);
    });

    test('copyWith creates updated copy', () {
      final original = StrategyRevision(
        id: 'r1',
        date: '5月7日',
        reason: '原因',
      );
      final updated = original.copyWith(isReviewed: true, date: '5月8日');

      expect(updated.isReviewed, true);
      expect(updated.date, '5月8日');
      expect(updated.id, 'r1');
    });

    test('copyWith keeps original values when not specified', () {
      final original = StrategyRevision(
        id: 'r1',
        date: '5月7日',
        reason: '原因',
        relatedDiscoveryId: 'd1',
        isReviewed: true,
      );
      final updated = original.copyWith();

      expect(updated.isReviewed, true);
      expect(updated.relatedDiscoveryId, 'd1');
      expect(updated.date, '5月7日');
    });
  });

  group('QtConsult', () {
    test('fromJson parses full consult data', () {
      final json = {
        'workspace': 'customer',
        'projectName': '某制造企业数字化项目',
        'phase': '方案期',
        'industry': '制造业',
        'scale': '500人',
        'maturity': 'L2',
        'strategyGoal': '实现数据可视化',
        'strategyInsight': '判断：真实诉求可能是产能利用率不透明',
        'strategySteps': ['第一步：ERP数据打通试点'],
        'riskNote': 'IT人力不足是硬约束',
        'discoveries': [
          {
            'id': 'd1',
            'text': '数据分散在3个ERP系统',
            'type': 'concern',
            'status': 'confirmed',
            'source': '需求调研会',
            'date': '5月14日',
          },
        ],
        'communications': [
          {
            'id': 'c1',
            'title': '需求调研会',
            'date': '5月14日',
            'summary': '与CEO进行了调研',
          },
        ],
        'revisions': [
          {
            'id': 'r1',
            'date': '5月14日',
            'reason': '发现中层抗拒',
            'relatedDiscoveryId': 'd2',
            'isReviewed': true,
          },
        ],
        'stakeholders': [
          {
            'id': 's1',
            'name': 'CEO 张总',
            'role': 'CEO',
            'stance': 'support',
            'concern': '关注ROI',
            'detail': '项目发起人',
          },
        ],
      };
      final data = QtConsult.fromJson(json);

      expect(data.workspace, WorkspaceType.customer);
      expect(data.projectName, '某制造企业数字化项目');
      expect(data.discoveries.length, 1);
      expect(data.communications.length, 1);
      expect(data.revisions.length, 1);
      expect(data.stakeholders.length, 1);
      expect(data.isInternal, false);
    });

    test('fromJson defaults workspace to customer when null', () {
      final json = {
        'projectName': '测试',
        'phase': '方案期',
        'industry': '测试',
        'scale': '小',
        'maturity': 'L1',
        'strategyGoal': '目标',
        'strategyInsight': '洞察',
        'strategySteps': [],
        'riskNote': '无',
        'discoveries': [],
        'revisions': [],
        'stakeholders': [],
      };
      final data = QtConsult.fromJson(json);

      expect(data.workspace, WorkspaceType.customer);
    });

    test('fromJson defaults communications to empty list when null', () {
      final json = {
        'projectName': '测试',
        'phase': '方案期',
        'industry': '测试',
        'scale': '小',
        'maturity': 'L1',
        'strategyGoal': '目标',
        'strategyInsight': '洞察',
        'strategySteps': [],
        'riskNote': '无',
        'discoveries': [],
        'revisions': [],
        'stakeholders': [],
      };
      final data = QtConsult.fromJson(json);

      expect(data.communications, isEmpty);
    });

    test('isInternal returns true for internal workspace', () {
      final data = QtConsult(
        workspace: WorkspaceType.internal,
        projectName: '',
        phase: '',
        industry: '',
        scale: '',
        maturity: '',
        strategyGoal: '',
        strategyInsight: '',
        strategySteps: [],
        riskNote: '',
        discoveries: [],
        communications: [],
        revisions: [],
        stakeholders: [],
      );
      expect(data.isInternal, true);
    });
  });
}
