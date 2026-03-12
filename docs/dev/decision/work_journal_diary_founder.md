# Work - Journal

This module aims to find event from journal. 
Journal is a event log. It is collected at any time, so it is dirty.
We want to find event memory as knowledge card from the journal,
so that we can cleary understand what happened in the past.

source from `data/asset/quanttide-journal-of-founder/raw`
spec at `docs/spec/work/journal_diary_founder.md`

notice that the same day event and diary should be in one file.
event saved by jsonl instead of json format.
diary saved with MYST markdown.

output to `data/asset/quanttide-journal-of-founder/memory/event` and `data/asset/quanttide-journal-of-founder/journal/diary`

`.env` has aliyun dashboard api-key
use deepseek as default model.

batch all at one time.
if run, retry 3 times.

write plan in 
`docs/dev/plan`with same file name.
write a example python module first.
`examples/work/journal.py`
