# Work - Journal

This module aims to find event from journal. 
Journal is a event log. It is collected at any time, so it is dirty.
We want to find event memory as knowledge card from the journal,
so that we can cleary understand what happened in the past.

the knowledge base root path is in the `.env`
source from repo `quanttide-journal-of-founder` > `default/raw`
spec at `quanttide-specification-of-founder` > `/work/delivery/journal.md`

notice that the same day event and diary should be in one file.
event saved by jsonl instead of json format.
diary saved with MYST markdown.

output to `quanttide-journal-of-founder`>`default/memory/event` and `quanttide-journal-of-founder` > `default/journal/diary`

`.env` has aliyun dashboard api-key
use deepseek as default model.

batch all at one time.
if run, retry 3 times.

workflow in `quanttide-handbook-of-founder` > `code/workflow/design.md`
