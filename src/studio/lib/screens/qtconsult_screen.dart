import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qtadmin_qtconsult/consult.dart';
import 'package:qtadmin_studio/constants.dart';
import 'package:qtadmin_studio/views/stat_item.dart';

class QtConsultScreen extends StatelessWidget {
  const QtConsultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _Body();
  }
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final Set<String> _expandedComms = {};
  final Set<String> _expandedStakeholders = {};

  QtConsult get _data => context.watch<ConsultBloc>().state.data;

  String _dateString() {
    final now = DateTime.now();
    return '${now.month}月${now.day}日';
  }

  int get _pendingReviewCount =>
      _data.revisions.where((r) => !r.isReviewed).length;

  int get _confirmedCount =>
      _data.discoveries.where((d) => d.status == DiscoveryStatus.confirmed).length;

  int get _highRiskCount => _data.discoveries
      .where((d) => d.type == DiscoveryType.risk && d.status == DiscoveryStatus.confirmed)
      .length;

  int get _blockerCount =>
      _data.discoveries.where((d) => d.type == DiscoveryType.risk).length;

  void _showAddDiscoveryDialog() {
    final textController = TextEditingController();
    DiscoveryType selectedType = DiscoveryType.concern;
    String selectedSource = '直接记录';
    final bloc = context.read<ConsultBloc>();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              titlePadding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
              contentPadding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
              actionsPadding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              title: const Text('记录新发现', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: textController,
                      autofocus: true,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: _data.isInternal
                            ? '量潮云数据揭示了什么之前没注意到的问题？'
                            : '这次接触发现了什么之前不知道的？描述具体事实……',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFAAAAAA)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF1A7F37)),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('发现类型', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF666666))),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<DiscoveryType>(
                      initialValue: selectedType,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        isDense: true,
                      ),
                      items: const [
                        DropdownMenuItem(value: DiscoveryType.risk, child: Text('⚠ 风险 / 阻碍', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: DiscoveryType.concern, child: Text('🔶 需关注', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: DiscoveryType.opportunity, child: Text('💡 机会 / 积极信号', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: DiscoveryType.neutral, child: Text('ℹ️ 中性信息', style: TextStyle(fontSize: 13))),
                      ],
                      onChanged: (v) {
                        if (v != null) setDialogState(() => selectedType = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text('来源', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF666666))),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: selectedSource,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        isDense: true,
                      ),
                      items: _data.isInternal
                          ? const [
                              DropdownMenuItem(value: '量潮云 · 项目数据', child: Text('量潮云 · 项目数据', style: TextStyle(fontSize: 13))),
                              DropdownMenuItem(value: '量潮云 · 财务数据', child: Text('量潮云 · 财务数据', style: TextStyle(fontSize: 13))),
                              DropdownMenuItem(value: '量潮云 · 销售看板', child: Text('量潮云 · 销售看板', style: TextStyle(fontSize: 13))),
                              DropdownMenuItem(value: '直接观察', child: Text('直接观察', style: TextStyle(fontSize: 13))),
                            ]
                          : const [
                              DropdownMenuItem(value: '直接记录', child: Text('直接记录', style: TextStyle(fontSize: 13))),
                              DropdownMenuItem(value: '需求调研会（5月14日）', child: Text('需求调研会（5月14日）', style: TextStyle(fontSize: 13))),
                              DropdownMenuItem(value: '初次接触（5月10日）', child: Text('初次接触（5月10日）', style: TextStyle(fontSize: 13))),
                            ],
                      onChanged: (v) {
                        if (v != null) setDialogState(() => selectedSource = v);
                      },
                    ),
                    const SizedBox(height: 6),
                    const Text('提交后系统会自动检查策略是否需要调整。高风险发现将触发策略审视提醒。', style: TextStyle(fontSize: 10, color: Color(0xFFAAAAAA))),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('取消', style: TextStyle(fontSize: 13)),
                ),
                FilledButton(
                  onPressed: () {
                    final text = textController.text.trim();
                    if (text.isEmpty) return;
                    bloc.add(AddDiscovery(
                      text: text,
                      type: selectedType,
                      source: selectedSource,
                      date: _dateString(),
                    ));
                    Navigator.pop(ctx);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A1A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('提交发现', style: TextStyle(fontSize: 13)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 10 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopbar(isMobile),
              const SizedBox(height: 14),
              _buildStatsBar(),
              const SizedBox(height: 16),
              _buildPanels(isMobile),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopbar(bool isMobile) {
    final phaseTag = _data.isInternal ? '内部观察' : _data.phase;
    final phaseColor = _data.isInternal ? const Color(0xFF6A1B9A) : const Color(0xFF1A7F37);
    final phaseBg = _data.isInternal ? const Color(0xFFF3E5F5) : const Color(0xFFE8F5E9);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _data.projectName,
                style: TextStyle(
                  fontSize: isMobile ? 17 : 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF222222),
                ),
              ),
              if (_data.isInternal)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    '以独立观察者身份审视公司现状',
                    style: TextStyle(fontSize: 11, color: Color(0xFF999999)),
                  ),
                ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: phaseBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            phaseTag,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: phaseColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 1))],
      ),
      child: Row(
        children: [
          StatItem(dotColor: Color(0xFF1A7F37), label: '已确认发现', value: _confirmedCount.toString()),
          const SizedBox(width: 16),
          StatItem(dotColor: Color(0xFFC8690A), label: '高风险', value: _highRiskCount.toString()),
          const SizedBox(width: 16),
          StatItem(dotColor: Color(0xFFB71C1C), label: '阻碍项', value: _blockerCount.toString()),
          if (_pendingReviewCount > 0) ...[
            const Spacer(),
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⚠', style: TextStyle(fontSize: 10)),
                    const SizedBox(width: 3),
                    Text(
                      '策略待审视 $_pendingReviewCount 条',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFC8690A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPanels(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _buildInfoPanel(),
          const SizedBox(height: 12),
          _buildStrategyPanel(),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildInfoPanel()),
        const SizedBox(width: 16),
        Expanded(child: _buildStrategyPanel()),
      ],
    );
  }

  String get _infoPanelSubtitle {
    if (_data.isInternal) return '组织自身是什么情况';
    return '客户是什么情况';
  }

  Widget _buildInfoPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _panelHeader('信息看板', _infoPanelSubtitle),
          const SizedBox(height: 12),
          _buildProfileRow(),
          const SizedBox(height: 14),
          _sectionTitle('发现清单'),
          ..._data.discoveries.map(_buildDiscoveryItem),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showAddDiscoveryDialog,
              icon: const Icon(Icons.add, size: 14),
              label: const Text('添加新发现', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1A7F37),
                side: const BorderSide(color: Color(0xFFDDDDDD), style: BorderStyle.solid, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          if (_data.communications.isNotEmpty) ...[
            const SizedBox(height: 16),
            _sectionTitle('沟通记录'),
            ..._data.communications.map(_buildCommItem),
          ],
        ],
      ),
    );
  }

  Widget _panelHeader(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1.5)),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF333333)),
          ),
          const SizedBox(width: 6),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA)),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF888888),
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(child: Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE))),
        ],
      ),
    );
  }

  Widget _buildProfileRow() {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        _profileTag(_data.industry),
        _profileTag(_data.scale),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            _data.maturity,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFFC8690A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _profileTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF555555)),
      ),
    );
  }

  Widget _buildDiscoveryItem(Discovery d) {
    final bloc = context.read<ConsultBloc>();
    final dotColor = discoveryDotColor(d.type);
    final statusLabel = switch (d.status) {
      DiscoveryStatus.confirmed => '已确认',
      DiscoveryStatus.pending => '待确认',
      DiscoveryStatus.dismissed => '已驳回',
    };
    final statusColor = switch (d.status) {
      DiscoveryStatus.confirmed => const Color(0xFF1A7F37),
      DiscoveryStatus.pending => const Color(0xFFB68A00),
      DiscoveryStatus.dismissed => const Color(0xFF999999),
    };
    final statusBg = switch (d.status) {
      DiscoveryStatus.confirmed => const Color(0xFFE8F5E9),
      DiscoveryStatus.pending => const Color(0xFFFFF8E1),
      DiscoveryStatus.dismissed => const Color(0xFFF5F5F5),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: d.status == DiscoveryStatus.dismissed ? const Color(0xFFF9F9F9) : Colors.transparent,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: dotColor.withAlpha(30), blurRadius: 4, spreadRadius: 1)],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.text,
                    style: TextStyle(
                      fontSize: 12,
                      color: d.status == DiscoveryStatus.dismissed
                          ? const Color(0xFF999999)
                          : const Color(0xFF333333),
                      decoration: d.status == DiscoveryStatus.dismissed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        '${d.date} · ${d.source}',
                        style: const TextStyle(fontSize: 10, color: Color(0xFFAAAAAA)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: statusColor),
                        ),
                      ),
                      if (d.linkedToStrategy)
                        const Text(' 🔗', style: TextStyle(fontSize: 9)),
                    ],
                  ),
                ],
              ),
            ),
            if (d.status != DiscoveryStatus.dismissed)
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.more_horiz, size: 16, color: Color(0xFFBBBBBB)),
                onSelected: (action) {
                  if (action == 'confirm' && d.status != DiscoveryStatus.confirmed) {
                    bloc.add(ConfirmDiscovery(d.id));
                  } else if (action == 'dismiss') {
                    bloc.add(DismissDiscovery(d.id));
                  } else if (action == 'delete') {
                    bloc.add(DeleteDiscovery(d.id));
                  }
                },
                itemBuilder: (ctx) => [
                  if (d.status != DiscoveryStatus.confirmed)
                    const PopupMenuItem(value: 'confirm', child: Text('确认', style: TextStyle(fontSize: 12))),
                  const PopupMenuItem(value: 'dismiss', child: Text('驳回', style: TextStyle(fontSize: 12))),
                  const PopupMenuItem(value: 'delete', child: Text('删除', style: TextStyle(fontSize: 12, color: Color(0xFFB71C1C)))),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommItem(Communication c) {
    final isExpanded = _expandedComms.contains(c.id);
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expandedComms.remove(c.id);
              } else {
                _expandedComms.clear();
                _expandedComms.add(c.id);
              }
            });
          },
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
            child: Row(
              children: [
                const Text('📄', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${c.title} · 纪要看全文',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Text(c.date, style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA))),
                const SizedBox(width: 4),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 14,
                  color: const Color(0xFFCCCCCC),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 4, left: 4, right: 4),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(6),
              border: const Border(left: BorderSide(color: Color(0xFFDDDDDD), width: 2)),
            ),
            child: Text(c.summary, style: const TextStyle(fontSize: 11, color: Color(0xFF666666), height: 1.6)),
          ),
      ],
    );
  }

  Widget _buildStrategyPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2))],
        border: _pendingReviewCount > 0 ? Border.all(color: const Color(0xFFC8690A), width: 2) : null,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _strategyPanelHeader(),
          const SizedBox(height: 14),
          _strategySection('战略诉求', _data.strategyGoal, _data.strategyInsight, isItalic: true),
          const SizedBox(height: 14),
          _buildStrategySteps(),
          const SizedBox(height: 14),
          _buildRiskNote(),
          const SizedBox(height: 14),
          _strategySectionTitle('决策链路'),
          ..._data.stakeholders.map(_buildStakeholderItem),
          const SizedBox(height: 16),
          _sectionTitle('策略修正记录'),
          if (_data.revisions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('暂无策略修正记录', style: TextStyle(fontSize: 12, color: Color(0xFFCCCCCC)))),
            )
          else
            ..._data.revisions.map(_buildRevisionItem),
        ],
      ),
    );
  }

  Widget _strategyPanelHeader() {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1.5)),
      ),
      child: Row(
        children: [
          const Text(
            '策略看板',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF333333)),
          ),
          const SizedBox(width: 6),
          const Text('我们怎么应对', style: TextStyle(fontSize: 11, color: Color(0xFFAAAAAA))),
          if (_pendingReviewCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFC8690A),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _strategySection(String title, String main, String? insight, {bool isItalic = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF555555))),
        const SizedBox(height: 4),
        Text(main, style: const TextStyle(fontSize: 12, color: Color(0xFF333333), height: 1.5)),
        if (insight != null) ...[
          const SizedBox(height: 2),
          Text(
            insight,
            style: TextStyle(
              fontSize: 11,
              color: const Color(0xFF888888),
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStrategySteps() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('切入策略', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF555555))),
        const SizedBox(height: 4),
        ..._data.strategySteps.map(
          (step) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('→ ', style: TextStyle(fontSize: 12, color: Color(0xFFBBBBBB), fontWeight: FontWeight.w600)),
                Expanded(child: Text(step, style: const TextStyle(fontSize: 12, color: Color(0xFF333333), height: 1.5))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRiskNote() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(6),
        border: const Border(left: BorderSide(color: Color(0xFFC8690A), width: 3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('⚠ ', style: TextStyle(fontSize: 11)),
          Expanded(
            child: Text(
              _data.riskNote,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFFC8690A), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _strategySectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF555555)),
      ),
    );
  }

  Widget _buildStakeholderItem(Stakeholder s) {
    final isExpanded = _expandedStakeholders.contains(s.id);
    return InkWell(
      onTap: () {
        setState(() {
          if (isExpanded) {
            _expandedStakeholders.remove(s.id);
          } else {
            _expandedStakeholders.add(s.id);
          }
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
        decoration: BoxDecoration(
          border: const Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(s.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF222222))),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: stanceBgColor(s.stance),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    s.stanceLabel,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: stanceColor(s.stance)),
                  ),
                ),
                const Spacer(),
                Text(s.concern, style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
              ],
            ),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(s.detail, style: const TextStyle(fontSize: 11, color: Color(0xFF666666), height: 1.6)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevisionItem(StrategyRevision r) {
    final bloc = context.read<ConsultBloc>();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        border: const Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
        color: !r.isReviewed ? const Color(0xFFFFFDF7) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Text(r.date, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFFAAAAAA))),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.reason, style: const TextStyle(fontSize: 11, color: Color(0xFF333333), height: 1.5)),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: r.isReviewed ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    r.isReviewed ? '已审视' : '待审视',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: r.isReviewed ? const Color(0xFF1A7F37) : const Color(0xFFC8690A),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!r.isReviewed)
            GestureDetector(
              onTap: () => bloc.add(ReviewRevision(r.id)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF1A7F37)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '确认审视',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF1A7F37)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
