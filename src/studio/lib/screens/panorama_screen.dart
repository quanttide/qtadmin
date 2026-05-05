import 'package:flutter/material.dart';
import 'package:qtadmin_studio/models/panorama.dart';
import 'package:qtadmin_studio/widgets/biz_unit_widget.dart';
import 'package:qtadmin_studio/widgets/func_card_widget.dart';

class PanoramaScreen extends StatefulWidget {
  const PanoramaScreen({super.key});

  @override
  State<PanoramaScreen> createState() => _PanoramaScreenState();
}

class _PanoramaScreenState extends State<PanoramaScreen> {
  bool _funcExpanded = false;

  static const _mobileBreakpoint = 768.0;

  static final List<BusinessUnitData> _businessUnits = [
    BusinessUnitData(
      name: '量潮数据',
      tag: '主营',
      decisions: [
        DecisionData(
          fromPerson: '陈小明',
          deadline: '本周内回复',
          title: '华为数据清洗 · 接不接？',
          context: '回头客 ¥12,000，10周。产能刚好够，但接了教育类要等一个月。',
          teamAdvice: '小明倾向：接，维持老客户',
          actions: [
            const DecisionAction(label: '批准', isPrimary: true),
            const DecisionAction(label: '驳回'),
            const DecisionAction(label: '附条件'),
          ],
        ),
        DecisionData(
          fromPerson: '李四维',
          deadline: '下周一前',
          title: '牛津项目 · 新增分析维度',
          context: '合同外需求。加则多2周，不加可能影响海外口碑。',
          teamAdvice: '四维建议：加，牛津是桥头堡',
          actions: [
            const DecisionAction(label: '同意加需求', isPrimary: true),
            const DecisionAction(label: '婉拒'),
          ],
        ),
      ],
    ),
    BusinessUnitData(
      name: '量潮课堂',
      tag: '主营',
      decisions: [
        DecisionData(
          fromPerson: '王老师',
          deadline: '今日需定',
          title: '杭电Python实训 · 已超期2周',
          context: '客户在催。加人赶工还是谈延期？',
          teamAdvice: '王老师建议：谈延期',
          isUrgent: true,
          actions: [
            const DecisionAction(label: '同意延期', isPrimary: true),
            const DecisionAction(label: '加人赶工'),
          ],
        ),
      ],
    ),
    BusinessUnitData(
      name: '量潮云',
      tag: '孵化中',
      isPrimary: false,
      emptyMessage: '暂无待决策事项\n市场调研进行中',
    ),
  ];

  static final List<FuncCardData> _functionCards = [
    FuncCardData(
      name: '人力资源',
      metrics: const [
        MetricData(label: '团队', value: '8人'),
        MetricData(label: '出勤', value: '全员'),
        MetricData(label: '待审批', value: '0'),
      ],
      trend: const TrendData(text: '无异常'),
    ),
    FuncCardData(
      name: '财务管理',
      metrics: const [
        MetricData(label: '本月回款', value: '¥84k/120k'),
        MetricData(label: '现金流', value: '健康'),
      ],
      trend: const TrendData(text: '无预警'),
    ),
    FuncCardData(
      name: '组织管理',
      metrics: const [
        MetricData(label: '决策委托率', value: '42%'),
        MetricData(label: '标准化率', value: '60%'),
        MetricData(label: '去中心化度', value: '40%'),
      ],
      trend: const TrendData(text: '↓5% 比上月', direction: TrendDirection.down),
      warning: '连续2月下降',
      isWarning: true,
    ),
    FuncCardData(
      name: '战略管理',
      metrics: const [
        MetricData(label: '季度OKR', value: '推进中'),
        MetricData(label: '量潮云', value: '报告下周出'),
      ],
      trend: const TrendData(text: '无阻塞'),
    ),
    FuncCardData(
      name: '新媒体',
      metrics: const [
        MetricData(label: '公众号', value: '按时'),
        MetricData(label: '知乎', value: '3篇/周'),
      ],
      trend: const TrendData(text: '稳定'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < _mobileBreakpoint;
        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 14 : 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isMobile),
                const SizedBox(height: 28),
                _buildBusinessSection(isMobile),
                const SizedBox(height: 32),
                _buildFunctionSection(isMobile),
                const SizedBox(height: 28),
                _buildBottomNote(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '量潮科技',
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          '2026年5月6日 · 星期三',
          style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
        ),
      ],
    );
  }

  Widget _buildBusinessSection(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('业务线'),
        const SizedBox(height: 14),
        if (isMobile)
          ..._businessUnits.map((unit) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: BizUnitWidget(data: unit),
              ))
        else
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 16.0;
              final unitWidth = (constraints.maxWidth - gap * 2) / 3;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _businessUnits.map((unit) {
                  return SizedBox(
                    width: unitWidth,
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: _businessUnits.last == unit ? 0 : gap,
                      ),
                      child: BizUnitWidget(data: unit),
                    ),
                  );
                }).toList(),
              );
            },
          ),
      ],
    );
  }

  Widget _buildFunctionSection(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('职能线'),
        const SizedBox(height: 14),
        if (isMobile)
          _buildMobileFuncGrid()
        else
          _buildDesktopFuncGrid(),
        if (isMobile)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  backgroundColor: const Color(0xFFF5F5F5),
                  foregroundColor: const Color(0xFF888888),
                  side: const BorderSide(color: Color(0xFFDDDDDD), style: BorderStyle.solid, width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: () {
                  setState(() {
                    _funcExpanded = !_funcExpanded;
                  });
                },
                child: Text(
                  _funcExpanded ? '收起职能模块' : '展开全部职能模块',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDesktopFuncGrid() {
    const gap = 12.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - gap * 4) / 5;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _functionCards.map((card) {
            return SizedBox(
              width: cardWidth,
              child: Padding(
                padding: EdgeInsets.only(right: _functionCards.last == card ? 0 : gap),
                child: FuncCardWidget(data: card),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildMobileFuncGrid() {
    return Column(
      children: _functionCards.asMap().entries.map((entry) {
        final i = entry.key;
        final card = entry.value;
        final isVisible = i == 0 || card.isWarning || _funcExpanded;
        if (!isVisible) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: FuncCardWidget(data: card),
        );
      }).toList(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.only(bottom: 6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF555555)),
      ),
    );
  }

  Widget _buildBottomNote() {
    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
      ),
      child: const Text(
        '其余5位成员无需你介入 · 今日无待审批报销 · 本周全员周报已提交',
        style: TextStyle(fontSize: 12, color: Color(0xFFAAAAAA)),
      ),
    );
  }
}
