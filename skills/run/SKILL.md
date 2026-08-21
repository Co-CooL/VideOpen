---
name: run
description: Generate faceless video content consistently. Draft a still, run a pre-animate quality check, then animate the approved still through kie.ai, routing to the most cost-efficient model for the request. Enforces a running spend cap with a cost ledger, applies reusable style and character presets so a whole channel stays consistent, and outputs a publish-ready clip that hands off to Blotato for scheduling. Triggers on /videopen:run, generate image, generate video, make a POV clip, animate this.
allowed-tools: Read, Write, Edit, Bash, Glob
---

# /videopen:run

Make faceless video content, keep a channel visually consistent, and never blow the budget. Draft a still, check it before you spend on animation, then animate only the still you approve. Output lands publish-ready.

Built for vertical social video (9:16), with a running budget ceiling, reusable presets, and a quality gate plus a Blotato publish hand-off.

## Welcome & setup (do this first, every session)

`.env` is gitignored and never persists between sessions, so this repeats every time.

1. Check for a real `KIE_API_KEY` in this skill's own `.env` file, next to `SKILL.md` (not missing, not the placeholder `your_kie_key_here`). Create it if it doesn't exist yet.
2. **If missing or a placeholder** — before running anything else:
   - Greet the user with exactly this message:

     > 👋 Welcome! Here's how it works:
     >
     > Through the /videopen:run skill, you describe the video you want to Claude*, and it handles the whole creation pipeline for you, from drawing the still image to a publish-ready video. It first draws an image, you approve it, then it animates it into a video, picking from several video engines depending on the style, quality, and budget you want. You can use a preset and ask for changes, the video gets redone until it works for you. You can also make a longer video (1 min+) out of several clips.
     >
     > (* works with Claude Code only)

   - In that same message, ask, together, in one step:
     1. their kie.ai API key (from kie.ai/billing) — write it to `.env` (`KIE_API_KEY=...`) once given, never commit this file;
     2. which video engine they want (Seedance, Wan, Veo, Kling — or say "automatic" to let the skill pick the default per request);
     3. the total video length they're aiming for.
   - **Stop there and wait for their reply.** Do NOT show the numbered action menu in this same message — only after they've answered:
     1. Generate a new video from a text description
     2. Generate using a preset (pov, before-after, brand-style, listicle, problem-solution, story, app-watermark)
     3. Animate an image you already have and approve
     4. Make a longer video (1 min+) from several clips
     5. Check remaining kie.ai credit balance
3. **If the key is already set** — skip the greeting and options, go straight to the workflow below.

Picking a model is never mandatory beyond the quick question above: "automatic" defaults to Seedance 1.0 Pro, and routing only asks again mid-workflow when a real choice actually matters (see "Video model routing" below).

## Models

| Task | Model | Provider | Recipe |
|---|---|---|---|
| Image (default) | nano-banana-2 | kie.ai | models/nano-banana-2.md |
| Image (text or UI in frame) | gpt-image-2-text-to-image | kie.ai | models/gpt-image-2.md |
| Video (cheapest default) | Seedance 1.0 Pro `bytedance/v1-pro-image-to-video` | kie.ai | models/seedance-1-0-pro-image-to-video.md |
| Video (budget) | Seedance 1.0 Lite `bytedance/v1-lite-image-to-video` | kie.ai | models/seedance-1-0-lite-image-to-video.md |
| Video (newer, other durations) | Seedance 2.5 `bytedance/seedance-2-5` | kie.ai | models/seedance-2-5-image-to-video.md |
| Video (alternate look / fallback) | Wan 2.6 `wan/2-6-image-to-video` | kie.ai | models/wan-2-6-image-to-video.md |
| Video (higher quality, pricier) | Veo 3.1 `veo3`/`veo3_fast`/`veo3_lite` | kie.ai | models/veo3-image-to-video.md — verified against docs.kie.ai |
| Video (another look, several tiers) | Kling `kling-2.6/image-to-video` (or a version-pinned variant) | kie.ai | models/kling-image-to-video.md — verified against docs.kie.ai (9:16 support unconfirmed, see recipe) |

Read the recipe file before every generation. Use gpt-image-2-text-to-image whenever the frame has readable text, a sign, a poster, or an app UI mockup. Use nano-banana-2 for everything else.

**Video model routing — every wired model is open to use, nothing gated behind "ask first." When there's a real choice to make (style, quality tier, cost), ask which one I want rather than picking silently.** Default every standard short vertical clip to **Seedance 1.0 Pro** (cheapest per second at 1080p) unless the request implies otherwise. Switch models when it calls for it:
- Need a duration Seedance 1.0 doesn't offer (anything but 5s/10s) → pick the model whose range actually covers it (see Duration below), don't guess.
- Want a different visual style/motion feel, or Seedance is unavailable → **Wan 2.6**, or **Kling** for another look/tier.
- Want higher perceived quality and are fine paying more → **Veo 3.1** (pricier per clip — quote the cost clearly, it's a bigger jump than the others).
- Explicit budget mode → **Seedance 1.0 Lite**.
- Not sure what fits → ask me, don't guess.

Say which model was picked and why whenever it isn't the default. Other kie.ai video models beyond the six above (Sora, additional Kling tiers, etc.) aren't wired into this skill yet — no verified request recipe exists for them here, so don't guess at their API shape. Ask before spending on one; adding a new recipe file under `models/` first is quick once the exact request schema is confirmed from kie.ai's docs.

**Duration — per-model ranges (confirm the model covers the request before picking it):**
- Seedance 1.0 (Pro/Lite): **5 or 10s only**.
- Veo 3.1: **4, 6, or 8s only**.
- Kling: **5 or 10s** (base model), **3-15s** (turbo variant).
- Wan 2.6: **5, 10, or 15s only** — not free-form despite earlier drafts of this skill saying otherwise.
- **Seedance 2.5: up to 30s (~4-30s range)** — the only model here that reaches 20-30s in a single clip. Use this one whenever the requested duration exceeds 15s.

If the requested duration doesn't fit any single model's range, say so plainly rather than rounding or guessing — don't silently pick the closest model.

**Longer than ~30s (1 min+): no single-call model reaches this.** kie.ai has no native 60s+ generation on any wired model and no server-side merge/concat endpoint (checked docs.kie.ai). Per-provider "extend" chains exist for Runway, Veo3.1, and Grok Imagine, but none of those are wired into this skill, and Veo3.1's extend specifically refuses 1080p source clips — which is this skill's hard resolution floor — so it isn't usable here either way. The only path to a 1 min+ result is client-side assembly: generate multiple short clips (same preset, same character/refs, so the series reads as one continuous piece), get each approved and paid individually as usual, then run `stitch.sh` to concatenate them into one file. See "Assembling longer videos" below.

**Aspect ratio / dimensions.** The clip inherits the input still's exact dimensions. So **the still IS the aspect ratio and the resolution**: generate the still at **1080x1920** (9:16). If the still isn't 1080x1920 the clip won't be either. Seedance 1.0 has no aspect ratio parameter. Do not send one.

**Resolution floor: 1080p. This is hard.** Default vertical output is **1080x1920**. Lower resolutions are not offered — do not quote them or fall back to them to save credits. A sub-1080p clip is unpublishable on TikTok (min 540x960) / Instagram Reels, so it is wasted money, not a saving. If a request cannot be served at 1080p, STOP and say so rather than dropping resolution.

## Provider routing

1. Default to the LOWEST COST provider that runs the model well. kie.ai first.
2. If the cheapest route lacks the model, fails auth, or errors, fall back to fal.ai, then WaveSpeed AI.
3. Never hide a provider swap. Say which route ran and why.

## Presets (channel consistency)

A preset is a saved style so every clip in a series looks like it came from the same channel. Presets live in `presets/`, one markdown file each. A preset holds:
- a locked prompt fragment (the character, the look, the era),
- the aspect ratio and resolution,
- pinned reference images in `generations/refs/` (a character sheet, your app logo, a watermark).

Invoke with a preset: "/videopen:run using the pov preset: you wake up as a Roman senator." Load the preset, merge its locked fragment and its refs into the prompt, and never drift from them across the series.

Ship with these starters (edit them to your channel):
- `presets/pov.md` the POV wake-up format.
- `presets/app-watermark.md` pins your product logo as a reference so it rides on every frame.
- `presets/brand-style.md` your channel look, colours, grade, aspect ratio.

## The workflow

1. Load preset (if named). Merge its locked fragment, aspect ratio, and refs.
2. Draft the still (cheap). nano-banana-2, or gpt-image-2-text-to-image if the frame has text or a UI. Save the file and its prompt. Show me the still. Do not animate yet.
3. Pre-animate QA gate (see below). If any check fails, stop and report. Do not spend on video.
4. Budget gate (see below). Quote the credits, the dollars, and the remaining session budget. Wait for my explicit go.
5. Animate the approved still. Poll, download the mp4, write the log line with the real cost, append to the ledger.
6. Publish-ready hand-off (see below).

## Budget and ledger (never blow the spend)

Keep a running ledger at `generations/ledger.json`. Every generation appends one line: timestamp, model, type, cost_credits, cost_usd, description.

Two caps, editable here:
- SESSION_CAP: $10 per run of work.
- MONTHLY_CAP: $50 per calendar month.

Before ANY paid generation:
1. Sum the ledger for this session and this month.
2. If this run would cross a cap, STOP and tell me how far over, do not generate.
3. Otherwise, quote it like this: "This clip is 140 credits, about $0.70. Spent this session $4.10, remaining $5.90 of the $10 cap. Go?"

One approval equals one run. Never batch paid videos past the cap without a fresh go.

## Pre-animate QA gate (stop wasting video spend)

Video is the expensive lane, so check the still BEFORE animating. These are the real failure modes (wrong ratio gives black bars, drift breaks the illusion):
- Aspect ratio is vertical 9:16.
- Still dimensions are exactly 1080 x 1920 (the clip inherits them).
- No text baked into the image, unless it was made on gpt-image-2-text-to-image on purpose.
- Subject and point of view match the concept and the preset. First person stays first person.
- Requested duration fits the platform (TikTok, Reels, Shorts all take 5 or 10 seconds comfortably).

If any check fails, stop, say which one, and offer to re-draft the still (cheap) rather than animate a broken frame.

## Assembling longer videos (1 min+)

For anything past a single model's max duration, treat it as a series of scenes, not one generation:

1. Split the request into scenes that each fit a wired model's range (e.g. three 20s Seedance 2.5 clips for a 1 min video).
2. Generate and get each scene's still approved and animated one at a time, exactly as in the normal workflow — same budget gate, same QA gate, same preset/refs for every scene so the assembled result looks continuous, not like unrelated clips.
3. Once every clip is downloaded, run: `stitch.sh <output_basename> <clip1.mp4> <clip2.mp4> [clip3.mp4 ...]` (clips in playback order).
4. `stitch.sh` re-QAs every input (vertical, 1080p+ short side), concatenates via ffmpeg, and writes `{basename}.json` summing the already-paid cost of the constituent clips — it does not spend anything itself. It also appends a $0 `video_assembly` line to `generations/ledger.json` so the assembly is traceable without double-billing.
5. Treat the stitched file as the publish-ready output for the hand-off step below (its `duration` field is the sum of the scenes).

This is a client-side workaround, not a kie.ai feature — say so if asked, and don't imply the platform generated one continuous long clip.

## Publish-ready hand-off (close the loop to Blotato)

After the mp4 is saved, write a publish sidecar next to it, `{basename}.publish.json`:

```json
{
  "video": "the mp4 path",
  "hook_overlay": "POV: You Wake Up as a Roman Senator",
  "caption": "",
  "hashtags": ["#pov", "#ai"],
  "platforms": ["tiktok", "instagram", "youtube"],
  "aspect": "9:16",
  "duration": 10
}
```

Then hand off to publishing:
- If the Blotato MCP tools are available in this agent, offer to schedule through Blotato. Confirm the target account is warmed up first (see the warmup playbook). Blotato handles per-platform formatting and scheduling. Blotato is publishing only, it does not generate.
- If Blotato is not connected, tell me the publish-ready file path and the sidecar so I can upload it, and remind me I can add Blotato with `claude mcp add`.

## Rules

- Enforce the budget gate and the QA gate before any paid video. No exceptions.
- Draft on a cheap image model first. Only animate a still I approved.
- Never describe a logo, face, or product UI in words. Pass the real file as a reference (Seedance 1.0 takes image_url as a single string), or via a preset. If it is missing, stop and ask.
- Run generations one at a time. kie.ai allows 20 new requests per 10 seconds, so serialize and poll patiently.
- Save every output FLAT into the generations folder ($GENERATIONS_DIR, default ~/faceless/generations). No subfolders. Refs live in that folder's refs/ subfolder. Presets live in the skill's presets/ folder.
- Naming: {project}_{description}_{timestamp}.{ext}
- After every save, write the sidecar log AND append to the ledger.
- Default video resolution is 1080p vertical, 1080 x 1920.

## Cost reference (verify at run, prices move)

1 credit = half a cent. $5 buys 1,000 credits.

- Still on GPT Image: 10 credits (~$0.05).
- **Seedance 1.0 Pro (DEFAULT), 1080p: 14 credits/sec.** 5s = 70 credits (~$0.35), 10s = 140 credits (~$0.70).
- **Seedance 1.0 Lite (budget), 1080p: 10 credits/sec.** 5s = 50 credits (~$0.25), 10s = 100 credits (~$0.50).
- **Finished 10s 1080p Pro clip = still + video = 10 + 140 = 150 credits (~$0.75).** Lite = 10 + 100 = 110 credits (~$0.55).
- Seedance 2.5 (explicit only): quote Seedance 2.5 from kie's live 1080p rate at request time.
- kie.ai credits do not expire.

## Logging

After every save, write a JSON file next to the media, same basename, .json extension, and append the same cost to `generations/ledger.json`:

```json
{
  "model": "the model id used",
  "prompt": "the full prompt sent",
  "preset": "pov",
  "refs": ["refs/app-logo.png"],
  "params": { "aspect_ratio": "9:16", "resolution": "1080p", "duration": 10 },
  "cost_credits": 140,
  "cost_usd": 0.70,
  "created": "set at runtime"
}
```

## What NOT to do

- Do not animate before the QA gate and the budget gate both pass.
- Do not cross the session or monthly cap without a fresh explicit go.
- Do not animate a still I have not approved.
- Do not drift from the preset. Same character, same look, across the series.
- Do not change the point of view between the still and the clip.
- Do not log success without the output path, the real cost, and the ledger append.
