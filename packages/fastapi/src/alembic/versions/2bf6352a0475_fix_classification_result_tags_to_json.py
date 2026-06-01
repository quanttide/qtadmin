"""fix: classification_result.tags to JSON

Revision ID: 2bf6352a0475
Revises: 571dd6946d4b
Create Date: 2026-05-31 15:21:46.704629

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import sqlite

# revision identifiers, used by Alembic.
revision: str = '2bf6352a0475'
down_revision: Union[str, Sequence[str], None] = '571dd6946d4b'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    with op.batch_alter_table('classification_result') as batch_op:
        batch_op.alter_column('tags',
               existing_type=sa.VARCHAR(),
               type_=sqlite.JSON(),
               existing_nullable=True)


def downgrade() -> None:
    """Downgrade schema."""
    with op.batch_alter_table('classification_result') as batch_op:
        batch_op.alter_column('tags',
               existing_type=sqlite.JSON(),
               type_=sa.VARCHAR(),
               existing_nullable=True)
