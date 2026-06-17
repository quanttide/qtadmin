"""报价计算引擎测试"""

from examples.business.src.calculator import (
    ServiceItem,
    Quotation,
    PersonnelLevel,
    CustomerType,
    ApprovalType,
    check_premium_condition,
)


def test_tutorial_case():
    """教程案例：数据分析内训两天"""
    items = [
        ServiceItem("准备", 16, PersonnelLevel.CHIEF),
        ServiceItem("交付", 16, PersonnelLevel.CHIEF),
        ServiceItem("回访", 4, PersonnelLevel.CHIEF),
    ]
    q = Quotation(items=items, premium_rate=0.30)
    s = q.summary()

    assert s["total_hours"] == 36
    assert s["base_total"] == 72000       # 36 × 2000
    assert s["premium_rate"] == 0.30
    assert s["premium_amount"] == 21600   # 72000 × 0.30
    assert s["discount_rate"] == 0.15     # 36h ≥ 20h → 8.5折
    assert s["total"] == 79560            # (72000 + 21600) × 0.85
    assert q.approval_type() == ApprovalType.MAJOR


def test_standard_quotation_no_premium():
    """标准报价：无溢价、无让利"""
    items = [
        ServiceItem("标准咨询", 8, PersonnelLevel.ADVANCED),
    ]
    q = Quotation(items=items)
    s = q.summary()

    assert s["total_hours"] == 8
    assert s["base_total"] == 8000        # 8 × 1000
    assert s["premium_rate"] == 0.0
    assert s["premium_amount"] == 0
    assert s["discount_rate"] == 0.0      # 8h < 10h → 无折扣
    assert s["total"] == 8000
    assert q.approval_type() == ApprovalType.STANDARD


def test_discount_10h():
    """满 10 小时 → 9 折"""
    items = [
        ServiceItem("咨询服务", 10, PersonnelLevel.ADVANCED),
    ]
    q = Quotation(items=items)
    s = q.summary()

    assert s["discount_rate"] == 0.10
    assert s["discount_amount"] == 1000   # 10000 × 0.10
    assert s["total"] == 9000
    assert q.approval_type() == ApprovalType.DISCOUNT


def test_discount_20h():
    """满 20 小时 → 8.5 折（高折扣优先）"""
    items = [
        ServiceItem("咨询服务", 20, PersonnelLevel.ADVANCED),
    ]
    q = Quotation(items=items)
    s = q.summary()

    assert s["discount_rate"] == 0.15
    assert s["total"] == 17000            # 20000 × 0.85


def test_mixed_personnel_levels():
    """混合人员等级"""
    items = [
        ServiceItem("方案设计", 4, PersonnelLevel.CHIEF),
        ServiceItem("执行实施", 16, PersonnelLevel.ADVANCED),
    ]
    q = Quotation(items=items)
    s = q.summary()

    assert s["base_total"] == 24000       # 4 × 2000 + 16 × 1000
    assert s["total_hours"] == 20
    assert s["discount_rate"] == 0.15


def test_premium_condition_check():
    """溢价条件判断"""
    assert check_premium_condition(["企业内训体系设计"]) is True
    assert check_premium_condition(["微专业共建"]) is True
    assert check_premium_condition(["高复杂度", "高定制化"]) is True
    assert check_premium_condition(["标准培训"]) is False
    assert check_premium_condition([]) is False


def test_approval_major_when_premium():
    """涉及溢价 → 重大报价"""
    q = Quotation(items=[ServiceItem("内训", 8, PersonnelLevel.CHIEF)], premium_rate=0.30)
    assert q.approval_type() == ApprovalType.MAJOR


def test_approval_standard():
    """无溢价无让利 → 标准报价"""
    q = Quotation(items=[ServiceItem("咨询", 4, PersonnelLevel.ADVANCED)])
    assert q.approval_type() == ApprovalType.STANDARD
