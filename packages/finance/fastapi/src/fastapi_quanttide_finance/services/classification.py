_TAXONOMY: dict[str, list[str]] = {
    "expense_type": ["办公用品", "差旅", "采购", "工资", "其他"],
}


def validate_category(taxonomy: str, category: str) -> None:
    """Raise ValueError if category is not in the taxonomy's allowed list."""
    allowed = _TAXONOMY.get(taxonomy)
    if allowed is None:
        raise ValueError(f"Unknown taxonomy: {taxonomy}")
    if category not in allowed:
        raise ValueError(
            f"Invalid category '{category}' for taxonomy '{taxonomy}'. "
            f"Allowed: {', '.join(sorted(allowed))}"
        )
