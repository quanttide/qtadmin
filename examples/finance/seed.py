"""M4 Demo — 填充演示数据到独立 demo 数据库。

不会触碰主开发库的 quanttide_finance.db。
通过 --reset 确认后清空 demo 数据重新生成。
"""

import argparse
import sys
from datetime import date
from pathlib import Path
from random import choice, randint, seed as random_seed

from sqlalchemy import create_engine, event
from sqlalchemy.engine import Engine
from sqlalchemy.orm import sessionmaker

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "packages/fastapi/src"))
from fastapi_quanttide_finance.models.source_record import SourceRecord
from fastapi_quanttide_finance.models.normalized_record import NormalizedRecord
from fastapi_quanttide_finance.models.record_link import RecordLink
from fastapi_quanttide_finance.models.classification_result import ClassificationResult
from fastapi_quanttide_finance.database import Base


@event.listens_for(Engine, "connect")
def _set_sqlite_pragma(dbapi_connection, connection_record):
    cursor = dbapi_connection.cursor()
    cursor.execute("PRAGMA foreign_keys=ON")
    cursor.close()


DEMO_DIR = Path(__file__).resolve().parent
DEMO_DB_PATH = DEMO_DIR / "demo.db"
DB_URL = f"sqlite:///{DEMO_DB_PATH}"

# ------- 演示数据 -------

DEPARTMENTS = ["研发部", "市场部", "行政部", "财务部", "销售部", "采购部"]
PEOPLE = {
    "研发部": ["张伟", "李强", "王芳", "刘洋"],
    "市场部": ["陈静", "赵敏", "周杰"],
    "行政部": ["吴婷", "郑浩"],
    "财务部": ["孙丽", "黄伟", "林涛"],
    "销售部": ["马超", "朱红", "何亮", "徐飞"],
    "采购部": ["胡明", "郭雪"],
}
COUNTERPARTIES = [
    "京东企业购", "携程商旅", "滴滴企业版", "中国石油", "中国移动",
    "顺丰速运", "联想集团", "用友网络", "华为技术", "阿里云",
]
RECORD_DESCRIPTIONS = [
    "办公用品采购", "差旅报销", "项目外包服务费", "设备维修费",
    "培训费用", "交通补贴", "通讯费", "快递费",
    "软件订阅费", "招待费", "房租水电", "保洁服务",
]
AMOUNT_RANGES = {  # (min, max) 单位分
    "expense": (5000, 500000),
    "income": (10000, 2000000),
    "transfer": (50000, 1000000),
    "reimbursement": (10000, 200000),
    "other": (1000, 100000),
}
CLASSIFICATION_CATEGORIES = ["办公用品", "差旅", "采购", "工资", "其他"]
CATEGORY_WEIGHT = {"办公用品": .3, "差旅": .25, "采购": .2, "工资": .15, "其他": .1}


def weighted_choice(options, weights):
    r = randint(1, 100)
    cumulative = 0
    for opt, w in zip(options, weights):
        cumulative += w * 100
        if r <= cumulative:
            return opt
    return options[-1]


def main():
    parser = argparse.ArgumentParser(description="填充 demo 数据库")
    parser.add_argument("--reset", action="store_true", help="确认清空 demo 数据后重新生成")
    args = parser.parse_args()

    random_seed(42)

    engine = create_engine(DB_URL, echo=False)
    SessionLocal = sessionmaker(bind=engine)

    if args.reset and DEMO_DB_PATH.exists():
        DEMO_DB_PATH.unlink()
        print(f"Removed existing demo DB: {DEMO_DB_PATH}")

    if DEMO_DB_PATH.exists():
        print(f"Demo DB already exists: {DEMO_DB_PATH}")
        print("Use --reset to regenerate.")
        sys.exit(0)

    # 建表
    Base.metadata.create_all(engine)
    print(f"Created demo DB: {DEMO_DB_PATH}")

    session = SessionLocal()

    # ---- 生成原始记录 ----
    all_srs = []
    sr_id = 0
    for month in [6, 7, 8]:
        for dept in DEPARTMENTS:
            num = randint(2, 4)
            for _ in range(num):
                sr_id += 1
                day = randint(1, 28)
                person = choice(PEOPLE[dept])
                sr = SourceRecord(
                    source_type="manual",
                    raw_text=f"{dept}{person}提交的{choice(RECORD_DESCRIPTIONS)}",
                    ingestion_status="normalized",
                )
                session.add(sr)
                session.flush()
                all_srs.append(sr)

    session.commit()
    print(f"Created {len(all_srs)} SourceRecords")

    # ---- 生成标准化记录 ----
    all_nrs = []
    for i, sr in enumerate(all_srs):
        dept = DEPARTMENTS[i % len(DEPARTMENTS)]
        person = choice(PEOPLE[dept])
        month = 6 + (i // (len(DEPARTMENTS) * 3))  # 大致分配到 6-8 月
        day = 1 + (i % 28)
        record_type = choice(["expense", "expense", "expense", "reimbursement", "other"])
        direction = "outflow" if record_type != "income" else choice(["outflow", "inflow"])
        amt_range = AMOUNT_RANGES.get(record_type, (10000, 100000))
        amount_cents = randint(*amt_range)

        nr = NormalizedRecord(
            primary_source_id=sr.id,
            record_type=record_type,
            business_date=date(2026, month, day),
            amount_cents=amount_cents,
            currency="CNY",
            direction=direction,
            department=dept,
            person=person,
            counterparty=choice(COUNTERPARTIES),
            description=choice(RECORD_DESCRIPTIONS),
            normalization_status="normalized",
        )
        session.add(nr)
        session.flush()
        all_nrs.append(nr)

        # 建立 RecordLink
        rl = RecordLink(
            source_record_id=sr.id,
            normalized_record_id=nr.id,
            relation_type="primary",
        )
        session.add(rl)

    session.commit()
    print(f"Created {len(all_nrs)} NormalizedRecords + {len(all_nrs)} RecordLinks")

    # ---- 生成分类 ----
    total_classifications = 0
    accepted_total = 0
    for nr in all_nrs:
        # 约 85% 的记录有分类（剩余的作为"未分类"展示在统计中）
        if randint(1, 100) > 85:
            continue
        cat = weighted_choice(CLASSIFICATION_CATEGORIES, [
            CATEGORY_WEIGHT[c] for c in CLASSIFICATION_CATEGORIES
        ])
        is_accepted = randint(1, 100) <= 75  # 75% 已审核

        cr = ClassificationResult(
            normalized_record_id=nr.id,
            taxonomy="expense_type",
            category=cat,
            classifier_kind="manual",
            confidence=0.95 if is_accepted else 0.70,
            review_status="accepted" if is_accepted else "candidate",
            is_active=True,
        )
        session.add(cr)
        total_classifications += 1
        if is_accepted:
            accepted_total += 1

    session.commit()
    print(f"Created {total_classifications} classifications ({accepted_total} accepted, {total_classifications - accepted_total} candidates)")

    # ---- 验证 ----
    total = session.query(NormalizedRecord).count()
    sum_amount = session.query(__import__("sqlalchemy").func.sum(NormalizedRecord.amount_cents)).scalar() or 0
    classified = (
        session.query(NormalizedRecord)
        .filter(
            NormalizedRecord.id.in_(
                session.query(ClassificationResult.normalized_record_id).filter(
                    ClassificationResult.review_status == "accepted",
                    ClassificationResult.is_active == True,
                )
            )
        )
        .count()
    )

    print(f"\n=== Demo Data Summary ===")
    print(f"Total records: {total}")
    print(f"Sum amount_cents: {sum_amount:,} (¥{sum_amount/100:,.2f})")
    print(f"Records with accepted classification: {classified}")
    print(f"Classification rate: {classified/total*100:.0f}%")
    print(f"\nDemo DB: {DEMO_DB_PATH}")
    print("Ready! Start uvicorn and open the demo.")
    print()
    print("启动后端时需指定 demo 数据库：")
    print("  DEMO_DB=1 uvicorn fastapi_quanttide_finance.app:app --reload")
    print("或手动修改 database.py 中的 DATABASE_URL 指向 demo/demo.db")

    session.close()


if __name__ == "__main__":
    main()
