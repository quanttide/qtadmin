fn main() {
    let q = quotation::Quotation {
        items: vec![
            quotation::ServiceItem { name: "准备".into(), hours: 16.0, level: quotation::PersonnelLevel::Chief },
            quotation::ServiceItem { name: "交付".into(), hours: 16.0, level: quotation::PersonnelLevel::Chief },
            quotation::ServiceItem { name: "回访".into(), hours: 4.0, level: quotation::PersonnelLevel::Chief },
        ],
        premium_rate: 0.30,
    };

    let s = q.summary();
    println!("总时长: {} 小时", s.total_hours);
    println!("基础总价: {} 元", s.base_total);
    println!("溢价率: {}%", (s.premium_rate * 100.0) as u32);
    println!("溢价金额: {} 元", s.premium_amount);
    println!("折扣率: {}%", (s.discount_rate * 100.0) as u32);
    println!("折后总价: {} 元", s.total);
    println!("审批类型: {:?}", s.approval_type);
}

mod quotation {
    #[derive(Debug, Clone, Copy, PartialEq)]
    pub enum PersonnelLevel {
        Chief,
        Senior,
        Advanced,
        Mid,
        Junior,
    }

    #[derive(Debug, Clone, Copy, PartialEq)]
    pub enum ApprovalType {
        Standard,
        Major,
        Discount,
    }

    pub struct ServiceItem {
        pub name: &'static str,
        pub hours: f64,
        pub level: PersonnelLevel,
    }

    pub struct Quotation {
        pub items: Vec<ServiceItem>,
        pub premium_rate: f64,
    }

    const ENTERPRISE_RATES: [(PersonnelLevel, f64); 2] = [
        (PersonnelLevel::Chief, 2000.0),
        (PersonnelLevel::Advanced, 1000.0),
    ];

    const DISCOUNT_RULES: [(f64, f64); 2] = [
        (20.0, 0.15),
        (10.0, 0.10),
    ];

    pub struct Summary {
        pub total_hours: f64,
        pub base_total: f64,
        pub premium_rate: f64,
        pub premium_amount: f64,
        pub discount_rate: f64,
        pub discount_amount: f64,
        pub total: f64,
        pub approval_type: ApprovalType,
    }

    fn unit_price(level: PersonnelLevel) -> Option<f64> {
        ENTERPRISE_RATES.iter().find(|(l, _)| *l == level).map(|(_, p)| *p)
    }

    impl Quotation {
        pub fn total_hours(&self) -> f64 {
            self.items.iter().map(|i| i.hours).sum()
        }

        pub fn base_total(&self) -> Option<f64> {
            let mut total = 0.0;
            for item in &self.items {
                total += unit_price(item.level)? * item.hours;
            }
            Some(total)
        }

        pub fn premium_amount(&self) -> Option<f64> {
            Some(self.base_total()? * self.premium_rate)
        }

        pub fn discount_rate(&self) -> f64 {
            let hours = self.total_hours();
            for (threshold, rate) in DISCOUNT_RULES {
                if hours >= threshold {
                    return rate;
                }
            }
            0.0
        }

        pub fn discount_amount(&self) -> Option<f64> {
            Some(self.base_total()? * self.discount_rate())
        }

        pub fn total(&self) -> Option<f64> {
            let base = self.base_total()?;
            Some((base + base * self.premium_rate) * (1.0 - self.discount_rate()))
        }

        pub fn approval_type(&self) -> ApprovalType {
            if self.premium_rate > 0.0 {
                return ApprovalType::Major;
            }
            if self.discount_rate() > 0.0 {
                return ApprovalType::Discount;
            }
            ApprovalType::Standard
        }

        pub fn summary(&self) -> Summary {
            Summary {
                total_hours: self.total_hours(),
                base_total: self.base_total().unwrap_or(0.0),
                premium_rate: self.premium_rate,
                premium_amount: self.premium_amount().unwrap_or(0.0),
                discount_rate: self.discount_rate(),
                discount_amount: self.discount_amount().unwrap_or(0.0),
                total: self.total().unwrap_or(0.0),
                approval_type: self.approval_type(),
            }
        }
    }

    pub fn check_premium_condition(conditions: &[&str]) -> bool {
        let triggers = [
            "微专业共建", "长期课程开发",
            "企业内训体系设计",
            "高复杂度", "高定制化",
            "战略转型陪跑", "高管教练系列",
        ];
        conditions.iter().any(|c| triggers.contains(c))
    }

    #[cfg(test)]
    mod tests {
        use super::*;

        #[test]
        fn test_tutorial_case() {
            let q = Quotation {
                items: vec![
                    ServiceItem { name: "准备", hours: 16.0, level: PersonnelLevel::Chief },
                    ServiceItem { name: "交付", hours: 16.0, level: PersonnelLevel::Chief },
                    ServiceItem { name: "回访", hours: 4.0, level: PersonnelLevel::Chief },
                ],
                premium_rate: 0.30,
            };
            let s = q.summary();
            assert_eq!(s.total_hours, 36.0);
            assert_eq!(s.base_total, 72000.0);
            assert_eq!(s.premium_amount, 21600.0);
            assert_eq!(s.discount_rate, 0.15);
            assert_eq!(s.total, 79560.0);
            assert_eq!(s.approval_type as i32, ApprovalType::Major as i32);
        }

        #[test]
        fn test_standard_quotation() {
            let q = Quotation {
                items: vec![ServiceItem { name: "咨询", hours: 8.0, level: PersonnelLevel::Advanced }],
                premium_rate: 0.0,
            };
            let s = q.summary();
            assert_eq!(s.base_total, 8000.0);
            assert_eq!(s.discount_rate, 0.0);
            assert_eq!(s.total, 8000.0);
            assert_eq!(s.approval_type as i32, ApprovalType::Standard as i32);
        }

        #[test]
        fn test_discount_10h() {
            let q = Quotation {
                items: vec![ServiceItem { name: "咨询", hours: 10.0, level: PersonnelLevel::Advanced }],
                premium_rate: 0.0,
            };
            let s = q.summary();
            assert_eq!(s.discount_rate, 0.10);
            assert_eq!(s.total, 9000.0);
        }

        #[test]
        fn test_discount_20h() {
            let q = Quotation {
                items: vec![ServiceItem { name: "咨询", hours: 20.0, level: PersonnelLevel::Advanced }],
                premium_rate: 0.0,
            };
            let s = q.summary();
            assert_eq!(s.discount_rate, 0.15);
            assert_eq!(s.total, 17000.0);
        }

        #[test]
        fn test_mixed_levels() {
            let q = Quotation {
                items: vec![
                    ServiceItem { name: "设计", hours: 4.0, level: PersonnelLevel::Chief },
                    ServiceItem { name: "执行", hours: 16.0, level: PersonnelLevel::Advanced },
                ],
                premium_rate: 0.0,
            };
            let s = q.summary();
            assert_eq!(s.base_total, 24000.0);
            assert_eq!(s.discount_rate, 0.15);
        }

        #[test]
        fn test_premium_condition() {
            assert!(check_premium_condition(&["企业内训体系设计"]));
            assert!(check_premium_condition(&["微专业共建"]));
            assert!(!check_premium_condition(&["标准培训"]));
            assert!(!check_premium_condition(&[]));
        }

        #[test]
        fn test_approval_major() {
            let q = Quotation {
                items: vec![ServiceItem { name: "内训", hours: 8.0, level: PersonnelLevel::Chief }],
                premium_rate: 0.30,
            };
            assert_eq!(q.approval_type() as i32, ApprovalType::Major as i32);
        }
    }
}
