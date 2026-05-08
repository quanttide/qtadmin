import 'package:flutter/material.dart';
import 'package:qtadmin_studio/models/org.dart';

class OrgScreen extends StatefulWidget {
  final OrgDashboardData data;

  const OrgScreen({super.key, required this.data});

  @override
  State<OrgScreen> createState() => _OrgScreenState();
}

class _OrgScreenState extends State<OrgScreen> {
  final Set<String> _expandedReps = {};

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
              _buildInstitutionBoard(isMobile),
              const SizedBox(height: 16),
              _buildRepBoard(isMobile),
              const SizedBox(height: 16),
              _buildRankFlow(isMobile),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopbar(bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '组织管理',
                style: TextStyle(
                  fontSize: isMobile ? 17 : 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF222222),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  '职能线',
                  style: TextStyle(fontSize: 11, color: Color(0xFF999999)),
                ),
              ),
            ],
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
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          _statItem(const Color(0xFF5B8DEF), '机构', widget.data.institutions.length.toString()),
          const SizedBox(width: 16),
          _statItem(const Color(0xFF1A7F37), '代表', widget.data.representatives.length.toString()),
          const SizedBox(width: 16),
          _statItem(const Color(0xFF7C4DFF), '职级', widget.data.ranks.length.toString()),
          const SizedBox(width: 16),
          _statItem(const Color(0xFFC8690A), '待晋升', widget.data.promotions.length.toString()),
        ],
      ),
    );
  }

  Widget _statItem(Color dotColor, String label, String count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
        ),
        const SizedBox(width: 4),
        Text(
          count,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF222222),
          ),
        ),
      ],
    );
  }

  Widget _buildInstitutionBoard(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _panelHeader('机构看板', '${widget.data.institutions.length} 个机构'),
          const SizedBox(height: 12),
          if (isMobile)
            ...widget.data.institutions.map(_buildInstitutionCard)
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: widget.data.institutions
                  .map((inst) => SizedBox(
                        width: 220,
                        child: _buildInstitutionCard(inst),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildInstitutionCard(OrgInstitutionData inst) {
    final (statusLabel, statusColor, statusBg) = switch (inst.status) {
      InstitutionStatus.normal => ('正常', const Color(0xFF1A7F37), const Color(0xFFE8F5E9)),
      InstitutionStatus.warning => ('即将到期', const Color(0xFFC8690A), const Color(0xFFFFF3E0)),
      InstitutionStatus.overdue => ('逾期', const Color(0xFFB71C1C), const Color(0xFFFFEBEE)),
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  inst.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF222222),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _infoRow('频率', inst.expectedFrequency),
          if (inst.lastMeetingDate != null)
            _infoRow('上次会议', inst.lastMeetingDate!),
          if (inst.nextMeetingDate != null)
            _infoRow('下次会议', inst.nextMeetingDate!),
          _infoRow('待处理提案', '${inst.pendingProposalCount} 条'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label ',
            style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF555555),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepBoard(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _panelHeader(
            '代表履职',
            '${widget.data.representatives.length} 位代表',
          ),
          const SizedBox(height: 12),
          ...widget.data.representatives.map(_buildRepCard),
        ],
      ),
    );
  }

  Widget _buildRepCard(OrgRepresentativeData rep) {
    final instName = widget.data.institutions
        .where((i) => i.id == rep.institutionId)
        .map((i) => i.name)
        .firstOrNull ?? '';
    final (tierIcon, tierLabel) = switch (rep.tier) {
      RepPerformanceTier.green => ('🟢', '绿标'),
      RepPerformanceTier.yellow => ('🟡', '黄标'),
      RepPerformanceTier.red => ('🔴', '红标'),
    };
    final isExpanded = _expandedReps.contains(rep.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedReps.remove(rep.id);
                } else {
                  _expandedReps.add(rep.id);
                }
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Text(tierIcon, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              rep.name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF222222),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                rep.rank,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF888888),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$instName · $tierLabel · ${rep.attendanceRate.round()}%参会',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: const Color(0xFFCCCCCC),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1, thickness: 1, color: Color(0xFFF5F5F5)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _repDetailRow('任期', rep.term),
                  _repDetailRow('提案数', '${rep.proposalCount} 次'),
                  _repDetailRow('表决参与率', '${rep.voteRate.round()}%'),
                  _repDetailRow('异议次数', '${rep.objectionCount} 次'),
                  if (rep.recentVotes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      '近期表决',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF888888),
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...rep.recentVotes.take(5).map(
                          (v) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              '${v.date} · ${v.title}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ),
                        ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _repDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA)),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF555555),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankFlow(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _panelHeader('职级流动', '${widget.data.ranks.length} 个职级'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: widget.data.ranks.map((r) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: r.isManagement
                      ? const Color(0xFFF3E5F5)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${r.name} ${r.headCount}人',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: r.isManagement
                        ? const Color(0xFF6A1B9A)
                        : const Color(0xFF555555),
                  ),
                ),
              );
            }).toList(),
          ),
          if (widget.data.promotions.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 12),
            const Text(
              '晋升记录',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF888888),
              ),
            ),
            const SizedBox(height: 8),
            ...widget.data.promotions.map(
              (p) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(6),
                  border: const Border(
                    left: BorderSide(color: Color(0xFF7C4DFF), width: 2),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.personName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${p.fromRank} → ${p.toRank}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          p.date,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFFAAAAAA),
                          ),
                        ),
                        if (p.isCrossTrack)
                          Text(
                            '跨序列',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF7C4DFF),
                            ),
                          ),
                      ],
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

  Widget _panelHeader(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1.5),
        ),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF333333),
            ),
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
}
