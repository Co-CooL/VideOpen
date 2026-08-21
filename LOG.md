# Removal log

Tracks content removed or corrected from this repo because it was stale, pointed at something that doesn't exist, or overclaimed a capability that isn't actually implemented. Newest first.

## 2026-08-21 — Provider fallback claim removed (fal.ai/WaveSpeed)

**Removed from:** `skills/run/SKILL.md`, "Provider routing" section.

**What it claimed:** that the skill would automatically fall back from kie.ai to fal.ai, then WaveSpeed AI, on failure.

**Why removed:** no recipe file, script branch, or request shape exists anywhere in the repo for either provider — only kie.ai is ever actually called. The `.env.example` keys (`FAL_KEY`, `WAVESPEED_API_KEY`) are kept as provisioned-but-unused, now labeled as such instead of implying an implemented fallback.

## 2026-08-21 — Wan 2.6 / Veo 3.1 / Kling downgraded from "wired" to "recipe only"

**Corrected in:** `skills/run/SKILL.md` (Models table, Video model routing, Duration), `skills/run/README.md` ("Models wired"), root `README.md` ("Features").

**What it claimed:** that all six video models (Seedance Pro/Lite/2.5, Wan, Veo, Kling) were live and routable, with routing logic actively telling the agent to switch to Wan/Veo/Kling for style, quality, or tier reasons.

**Why corrected:** `animate.sh`'s model routing only ever recognized `pro`, `lite`, and `2.5` — calling Wan/Veo/Kling failed with "unknown model key." The three have verified request recipes under `models/`, but no code path in `animate.sh` ever existed for them. Docs now state plainly that only Seedance Pro/Lite/2.5 are callable today.

## 2026-08-21 — Dangling "warmup playbook" reference removed

**Removed from:** `skills/run/SKILL.md`, Blotato publish hand-off section.

**What it claimed:** "confirm the target account is warmed up first (see the warmup playbook)."

**Why removed:** no warmup playbook file existed anywhere in the repo — the pointer went nowhere. Replaced with an inline check instead of a broken reference.

## Earlier (pre-dating this log) — Blotato mention removed from README intro

**Removed from:** root `README.md`, opening description line.

**What it said:** "...and hand off a publish-ready file (with Blotato integration for scheduling)."

**Why removed:** de-emphasized Blotato as a headline feature since it's an optional MCP integration, not a built-in guarantee — the fuller explanation lives further down under "Features" instead.

## Earlier (pre-dating this log) — Higgsfield-Open reference removed

**Removed from:** root `README.md`, `ffmpeg` requirement note.

**What it said:** "...see `Loumna/Higgsfield-Open`'s `.claude/hooks/session-start.sh` for a working example."

**Why removed:** VideOpen is a standalone repo/plugin and shouldn't point installers at a different, unrelated private repo for a working example. Replaced with a self-contained description of the `SessionStart` hook instead.
