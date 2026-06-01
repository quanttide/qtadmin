from abc import ABC, abstractmethod
from dataclasses import dataclass, field


@dataclass
class NormalizeInput:
    source_record_id: int
    raw_text: str
    source_type: str


@dataclass
class NormalizeResult:
    normalized_records: list[dict] = field(default_factory=list)
    links: list[dict] = field(default_factory=list)


class Normalizer(ABC):
    @abstractmethod
    def can_handle(self, source_type: str) -> bool:
        ...

    @abstractmethod
    def normalize(self, input: NormalizeInput) -> NormalizeResult:
        ...


_normalizers: list[Normalizer] = []


def register_normalizer(normalizer: Normalizer) -> None:
    _normalizers.append(normalizer)


def normalize(input: NormalizeInput) -> NormalizeResult:
    for normalizer in _normalizers:
        if normalizer.can_handle(input.source_type):
            return normalizer.normalize(input)
    raise ValueError(f"No Normalizer registered for source_type={input.source_type}")
