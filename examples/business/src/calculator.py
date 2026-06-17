"""
报价计算引擎。

将章程/手册/教程中的报价规则编译为可执行代码。
"""

from dataclasses import dataclass, field
from enum import Enum
from typing import Optional


class CustomerType(Enum):
    ENTERPRISE = "企业"
    UNIVERSITY = "高校"
    STUDENT = "学生"
    OTHER = "其他"


class PersonnelLevel(Enum):
    CHIEF = "首席"
    SENIOR = "资深"
    ADVANCED = "高级"
    MID = "中级"
    JUNIOR = "初级"


class ApprovalType(Enum):
    STANDARD = "标准"
    MAJOR = "重大"
    DISCOUNT = "让利"


# 企业客户标准公开价（来源：assets/profile/index.md）
ENTERPRISE_RATES = {
    PersonnelLevel.CHIEF: 2000,
    PersonnelLevel.ADVANCED: 1000,
}

# 溢价幅度（来源：assets/profile/index.md）
PREMIUM_RANGE = (0.30, 0.50)

# 让利规则（来源：assets/profile/index.md）
DISCOUNT_RULES = [
    (20, 0.15),   # 满 20 小时 → 8.5 折
    (10, 0.10),   # 满 10 小时 → 9 折
]


@dataclass
class ServiceItem:
    name: str
    hours: float
    personnel_level: PersonnelLevel
    customer_type: CustomerType = CustomerType.ENTERPRISE

    def unit_price(self) -> Optional[float]:
        return ENTERPRISE_RATES.get(self.personnel_level)

    def subtotal(self) -> Optional[float]:
        rate = self.unit_price()
        if rate is None:
            return None
        return rate * self.hours


@dataclass
class Quotation:
    items: list[ServiceItem] = field(default_factory=list)
    premium_rate: float = 0.0       # 0–0.5
    customer_type: CustomerType = CustomerType.ENTERPRISE

    def total_hours(self) -> float:
        return sum(item.hours for item in self.items)

    def base_total(self) -> Optional[float]:
        total = 0.0
        for item in self.items:
            s = item.subtotal()
            if s is None:
                return None
            total += s
        return total

    def premium_amount(self) -> Optional[float]:
        base = self.base_total()
        if base is None:
            return None
        return base * self.premium_rate

    def discount_rate(self) -> float:
        hours = self.total_hours()
        for threshold, rate in sorted(DISCOUNT_RULES, reverse=True):
            if hours >= threshold:
                return rate
        return 0.0

    def discount_amount(self) -> Optional[float]:
        base = self.base_total()
        if base is None:
            return None
        return base * self.discount_rate()

    def total(self) -> Optional[float]:
        base = self.base_total()
        if base is None:
            return None
        return (base + base * self.premium_rate) * (1 - self.discount_rate())

    def summary(self) -> dict:
        return {
            "total_hours": self.total_hours(),
            "base_total": self.base_total(),
            "premium_rate": self.premium_rate,
            "premium_amount": self.premium_amount(),
            "discount_rate": self.discount_rate(),
            "discount_amount": self.discount_amount(),
            "total": self.total(),
        }

    def approval_type(self) -> ApprovalType:
        if self.premium_rate > 0:
            return ApprovalType.MAJOR
        if self.discount_rate() > 0:
            return ApprovalType.DISCOUNT
        return ApprovalType.STANDARD


def check_premium_condition(conditions: list[str]) -> bool:
    """
    溢价条件判断（来源：assets/handbook.md#场景三）。
    满足任一条件即可。
    """
    premium_triggers = {
        "微专业共建", "长期课程开发",
        "企业内训体系设计",
        "高复杂度", "高定制化",
        "战略转型陪跑", "高管教练系列",
    }
    return any(c in premium_triggers for c in conditions)
