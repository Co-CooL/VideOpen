# VideOpen

## What is it?

A Claude Code plugin that creates social media videos (Instagram, Reels, Shorts, TikTok) without cameras, actors, or filming.

Using the `/videopen:run` skill, you describe the video you want to Claude*, and it handles the entire creation pipeline for you, from generating the initial image to delivering a publication-ready video via [kie.ai](https://kie.ai). It drafts a still image first, you approve it, and then it animates that still into a video by routing to the video engine best suited to your desired style, quality, and budget. You can use presets and request modifications; the video is regenerated until you are satisfied. You can also assemble longer videos (1 min+) out of several clips.

(* works with Claude Code only)

This repo is both the plugin itself and a self-hosted marketplace, so it installs on any Claude Code account without copying files by hand.

## How it works

1. Describe the video you want, with or without a specific style.
2. Claude builds the actual image prompt from your description — it asks a compact style question (type, mood, lighting, color) plus an optional round for extra detail (composition, effects, camera angle, lens, medium, art movement, material — set what you want, skip the rest), then synthesizes a proper prompt instead of just forwarding your sentence.
3. A still image is generated (the most cost-effective format) and presented for your approval — nothing gets animated until you review it.
4. Check that the image looks right (framing, aspect ratio, no artifacts). If it doesn't fit, it's redrafted at no animation cost.
5. The animation cost is quoted (credits + $), and nothing runs without your explicit go.
6. The approved still is animated into a video with the engine best suited to your request.
7. You get a publication-ready video, with a caption and hashtags prepared if needed.

> ⚠️ Your kie.ai key lives in a local `.env` file next to the skill, gitignored and never committed. On Claude Code web sessions the container is ephemeral, so you'll be asked for it again at the start of every new session.

## Install (from any Claude Code account)

```
/plugin marketplace add Co-CooL/VideOpen
/plugin install videopen@videopen
/reload-plugins
```

Then invoke it with:

```
/videopen:run
```

## How to use it

No complex commands to remember — describe what you want in the chat:

- **"Generate a video where someone wakes up as a Roman senator."**
- **"/videopen:run using the pov preset: you wake up as a Roman senator."** (reuses a predefined style)
- **"Animate this image."** (if you already have an approved still to convert into a video)
- **"Create a listicle video of the top 5 features of my app."**
- **"1-minute video about..."** (for longer runtimes, Claude generates multiple clips in the same style and offers to assemble them into one video)

Claude always pauses before spending credits (shows the still, states the cost, waits for your confirmation) and says which video engine was picked and why whenever it isn't the default.

Ready-to-use presets to keep a consistent style across a whole series: `pov`, `before-after`, `brand-style`, `listicle`, `problem-solution`, `story`, `app-watermark`. You can also skip presets entirely; each video is then generated independently.

## Features

- **Prompt construction.** Your description isn't forwarded to kie.ai as-is — the skill asks a compact style question plus an optional detail round, then builds a proper image prompt from your description and picks. See "How it works" above.
- **Image → video.** A still is generated first (cheap), approved by you, then animated — never the reverse.
- **Multiple video engines** (Seedance, Wan, Veo, Kling), with different durations and price points. Defaults to the most cost-efficient option, but asks when style, quality, or runtime calls for a real choice.
- **Reusable presets** to keep visual branding consistent across a series (character, style, app watermark, etc.) — see the list above.
- **Budget control:** session and monthly spending caps, with a full cost ledger. Cost is always quoted and confirmed before any spend.
- **Automated quality checks** before paying for animation (framing, vertical aspect ratio, resolution, preset consistency) so you never spend credits animating a flawed still.
- **Long-form videos (1 min+)** assembled from separately generated, same-style clips.
- **Publish-ready hand-off**, with optional Blotato MCP integration to schedule across platforms (TikTok, Instagram, YouTube) if you have it connected.

## Requirements

- A [kie.ai](https://kie.ai) API key (get one at [kie.ai/billing](https://kie.ai/billing)). The skill asks for it on first use and stores it locally in a `.env` file next to its own `SKILL.md` — never committed.
- `ffmpeg` available in the environment (used to resize stills and, if you use `stitch.sh`, to assemble multi-clip videos). On Claude Code web sessions, add a `SessionStart` hook to install it automatically.

## Cost

Every image or video uses credits (a few cents each) — see [kie.ai/billing](https://kie.ai/billing) for your balance or to top up (pay as you go). Your confirmation is always required before any credits are spent.

## What's inside

- `skills/run/SKILL.md` — the skill instructions (workflow, prompt construction, budget/QA gates, model routing, presets, publish hand-off).
- `skills/run/image-attributes.md` — the full vocabulary (type/style, mood, lighting, color, and the optional detail categories) used to build image prompts.
- `skills/run/*.sh` — the kie.ai API scripts (draft image, animate, check balance, stitch clips together).
- `skills/run/models/` — per-model request recipes (Seedance 1.0/2.5, Wan, Veo, Kling).
- `skills/run/presets/` — reusable style presets (pov, before-after, brand-style, listicle, problem-solution, story, app-watermark).

## Updating

Push changes to `main`, then on any installed account run:

```
/plugin marketplace update videopen
/reload-plugins
```
