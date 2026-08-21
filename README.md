# VideOpen

Claude Code plugin: generate faceless social video via [kie.ai](https://kie.ai) — draft a still, get it approved, animate it (budget-capped, multi-model routing), optionally assemble multiple clips into a 1min+ video, and hand off a publish-ready file (with Blotato integration for scheduling).

This repo is both the plugin itself and a self-hosted marketplace, so it can be installed on any Claude Code account without copying files by hand.

## Install (from any Claude Code account)

```
/plugin marketplace add Co-CooL/VideOpen
/plugin install video-gen@videopen
/reload-plugins
```

Then invoke it with:

```
/video-gen:generate
```

or describe what you want in plain language ("generate a video where...", "animate this image").

## Requirements

- A [kie.ai](https://kie.ai) API key (get one at [kie.ai/billing](https://kie.ai/billing)). The skill asks for it on first use and stores it locally in a `.env` file next to its own `SKILL.md` — never committed.
- `ffmpeg` available in the environment (used to resize stills and, if you use `stitch.sh`, to assemble multi-clip videos). On Claude Code web sessions, add a `SessionStart` hook to install it automatically — see `Loumna/Higgsfield-Open`'s `.claude/hooks/session-start.sh` for a working example.

## What's inside

- `skills/generate/SKILL.md` — the skill instructions (workflow, budget/QA gates, model routing, presets, publish hand-off).
- `skills/generate/*.sh` — the kie.ai API scripts (draft image, animate, check balance, stitch clips together).
- `skills/generate/models/` — per-model request recipes (Seedance 1.0/2.5, Wan, Veo, Kling).
- `skills/generate/presets/` — reusable style presets (pov, before-after, brand-style, listicle, problem-solution, story, app-watermark).

## Updating

Push changes to `main`, then on any installed account run:

```
/plugin marketplace update videopen
/reload-plugins
```
