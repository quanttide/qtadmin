"""Seed data constants for demo/testing.

Extracted from examples/provider/app.py so tests and the provider app
can share the same seed data without circular package dependencies.
"""

SEED_TRANSITIONS = {
    "new": [],
    "contacted": ["contacted"],
    "exam_sent": ["contacted", "exam_sent"],
    "exam_received": ["contacted", "exam_sent", "exam_received"],
    "evaluating": ["contacted", "exam_sent", "exam_received", "evaluating"],
    "interview": ["contacted", "exam_sent", "exam_received", "evaluating", "interview"],
    "offer": ["contacted", "exam_sent", "exam_received", "evaluating", "interview", "offer"],
    "closed": ["closed"],
}

DEMO_TALENTS = [
    ("new", "张一", "zhang1@demo.local", None),
    ("new", "张二", "zhang2@demo.local", None),
    ("new", "张三", "zhang3@demo.local", None),
    ("new", "张四", "zhang4@demo.local", None),
    ("new", "张五", "zhang5@demo.local", None),
    ("contacted", "李一", "li1@demo.local", None),
    ("contacted", "李二", "li2@demo.local", "resume_passed"),
    ("contacted", "李三", "li3@demo.local", "resume_passed"),
    ("contacted", "李四", "li4@demo.local", "resume_passed"),
    ("contacted", "李五", "li5@demo.local", None),
    ("exam_sent", "王一", "wang1@demo.local", None),
    ("exam_sent", "王二", "wang2@demo.local", "taking"),
    ("exam_sent", "王三", "wang3@demo.local", "taking"),
    ("exam_sent", "王四", "wang4@demo.local", "taking"),
    ("exam_sent", "王五", "wang5@demo.local", None),
    ("exam_received", "赵一", "zhao1@demo.local", None),
    ("exam_received", "赵二", "zhao2@demo.local", None),
    ("exam_received", "赵三", "zhao3@demo.local", None),
    ("exam_received", "赵四", "zhao4@demo.local", None),
    ("exam_received", "赵五", "zhao5@demo.local", None),
    ("evaluating", "孙一", "sun1@demo.local", None),
    ("evaluating", "孙二", "sun2@demo.local", "exam_passed"),
    ("evaluating", "孙三", "sun3@demo.local", "exam_passed"),
    ("evaluating", "孙四", "sun4@demo.local", "exam_passed"),
    ("evaluating", "孙五", "sun5@demo.local", None),
    ("interview", "周一", "zhou1@demo.local", None),
    ("interview", "周子", "zhou2@demo.local", "interview_passed"),
    ("interview", "周三", "zhou3@demo.local", "interview_passed"),
    ("interview", "周四", "zhou4@demo.local", "interview_passed"),
    ("interview", "周五", "zhou5@demo.local", None),
    ("offer", "吴一", "wu1@demo.local", None),
    ("offer", "吴二", "wu2@demo.local", "accepted"),
    ("offer", "吴三", "wu3@demo.local", "accepted"),
    ("offer", "吴四", "wu4@demo.local", "accepted"),
    ("offer", "吴五", "wu5@demo.local", None),
    ("closed", "郑一", "zheng1@demo.local", None),
    ("closed", "郑二", "zheng2@demo.local", None),
    ("closed", "郑三", "zheng3@demo.local", None),
    ("closed", "郑四", "zheng4@demo.local", None),
    ("closed", "郑五", "zheng5@demo.local", None),
]

QUALITY_MAP = {
    "李二": "excellent", "李三": "excellent", "李四": "excellent",
    "孙二": "excellent", "孙三": "excellent",
    "周子": "excellent",
    "吴二": "excellent", "吴三": "excellent",
    "张五": "excellent",
}


def build_transition_chain(target: str) -> list[str]:
    """从 new 走到 target 的合法路径（不含 new 自身）。"""
    return SEED_TRANSITIONS[target]
