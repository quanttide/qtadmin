"""材料生成服务 — 从邮件原始数据生成结构化材料产物。"""

import json
import os

from sqlalchemy.orm import Session

from fastapi_quanttide_hr.models.material import MaterialArtifact


def write_material_artifact(
    db: Session,
    queue_item_id: int | None,
    candidate_id: int | None,
    artifact_type: str,
    content_json: str | None = None,
    file_path: str | None = None,
) -> MaterialArtifact:
    artifact = MaterialArtifact(
        queue_item_id=queue_item_id,
        candidate_id=candidate_id,
        artifact_type=artifact_type,
        content_json=content_json,
        file_path=file_path,
    )
    db.add(artifact)
    db.flush()
    return artifact


def generate_body_artifact(
    db: Session,
    queue_item_id: int | None,
    candidate_id: int | None,
    body: str | None,
    body_text: str | None,
    materials_dir: str = "",
) -> MaterialArtifact | None:
    if not body and not body_text:
        return None

    content = {"body_html": body or "", "body_text": body_text or ""}
    content_str = json.dumps(content, ensure_ascii=False)

    file_path = None
    if materials_dir:
        artifact_dir = os.path.join(materials_dir, str(queue_item_id))
        os.makedirs(artifact_dir, exist_ok=True)
        fp = os.path.join(artifact_dir, "body.json")
        with open(fp, "w", encoding="utf-8") as f:
            f.write(content_str)
        file_path = fp

    return write_material_artifact(
        db=db, queue_item_id=queue_item_id, candidate_id=candidate_id,
        artifact_type="body_text", content_json=content_str, file_path=file_path,
    )


def generate_attachment_artifact(
    db: Session,
    queue_item_id: int | None,
    candidate_id: int | None,
    attachments: list[dict] | None,
    materials_dir: str = "",
) -> MaterialArtifact | None:
    if not attachments:
        return None

    content_str = json.dumps(attachments, ensure_ascii=False)

    file_path = None
    if materials_dir:
        artifact_dir = os.path.join(materials_dir, str(queue_item_id))
        os.makedirs(artifact_dir, exist_ok=True)
        fp = os.path.join(artifact_dir, "attachments.json")
        with open(fp, "w", encoding="utf-8") as f:
            f.write(content_str)
        file_path = fp

    return write_material_artifact(
        db=db, queue_item_id=queue_item_id, candidate_id=candidate_id,
        artifact_type="attachment_meta", content_json=content_str, file_path=file_path,
    )


def get_artifacts_by_queue(db: Session, queue_id: int) -> list[MaterialArtifact]:
    return db.query(MaterialArtifact).filter(MaterialArtifact.queue_item_id == queue_id).all()


def get_artifacts_by_candidate(db: Session, candidate_id: int) -> list[MaterialArtifact]:
    return db.query(MaterialArtifact).filter(MaterialArtifact.candidate_id == candidate_id).all()
