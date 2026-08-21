# Seedance 2.5 Image-to-Video (ByteDance, via kie.ai)

Freely selectable, not gated behind an explicit ask (see SKILL.md routing). The default video model is still Seedance 1.0 Pro (models/seedance-1-0-pro-image-to-video.md) for cost; use Seedance 2.5 when a longer clip or a duration Seedance 1.0 can't do is needed.

**Duration: up to 30 seconds (range ~4-30s)**, per kie.ai's own product pages (kie.ai/seedance-2-5, kie.ai/blog/what-is-seedance-2-5) — this is the model to use for a 20-30s clip in one call, since no other model wired into this skill goes past 15s. These are kie.ai's marketing/blog pages, not a direct read of the API reference's field-level schema (that page couldn't be reached to confirm the exact min/max validation kie.ai enforces server-side) — quote the duration back to the user before submitting, and if the API rejects a value in that range, that's the real limit, not this note.

| Field | Value |
|---|---|
| Model ID | bytedance/seedance-2-5 |
| Provider | kie.ai |
| Method | Async (submit, then poll) |
| Type | Video (image-to-video) |
| API key | .env -> KIE_API_KEY |
| Docs | https://docs.kie.ai (Models Market, ByteDance Seedance) |
| Cost | Quote Seedance 2.5 from kie's live 1080p rate at request time. |

## Endpoint

POST https://api.kie.ai/api/v1/jobs/createTask

## Auth

Authorization: Bearer {KIE_API_KEY}

## Request body (VERIFIED 2026-08-12)

```json
{
  "model": "bytedance/seedance-2-5",
  "input": {
    "prompt": "short motion prompt: slow push in, subtle parallax, no text",
    "first_frame_url": "https://durable-host/the-approved-still.jpg",
    "aspect_ratio": "adaptive",
    "resolution": "1080p",
    "duration": 8
  }
}
```

- **first_frame_url** (NOT `image_urls`): a single public image URL, the approved still. First-frame tasks read the orientation FROM this image.
- **aspect_ratio** MUST be `"adaptive"` for first-frame/first-last-frame tasks. Passing `"9:16"` returns `422: only support adaptive aspect ratio`. A 9:16 still therefore yields a 9:16 clip via adaptive.
- **duration**: seconds, as a NUMBER (`8`), not a string.
- **resolution**: send `"1080p"` (skill floor). The API also accepts 480p and 720p; this skill does not use them.

### Hosting the still (important)

The skill currently passes the temporary `tempfile.aiquickdraw.com` PNG link from the draft step through as-is — no automated re-host happens. If kie.ai returns `400: Input material format is unsupported`, convert the still to JPEG manually (`sips -s format jpeg`), upload it durably (e.g. Blotato's presigned URL — hosting only, not publishing), and pass that `publicUrl` as `first_frame_url`. This fallback isn't wired into `draft-image.sh`/`animate.sh` yet.

## Check remaining credits (no spend)

`GET https://api.kie.ai/api/v1/chat/credit` with the Bearer key returns `{"data": <credits>}`. Use `balance.sh`, or the pre-flight gate in `animate.sh` which refuses to submit if the balance is below the clip cost.

## Cost gate (required)

Before submitting, compute and quote:
- credits = credits_per_second x duration, at kie's live 1080p rate (verify at request time).
- `animate.sh` reads the per-second rate from the `SEEDANCE25_CPS` env var (set it in `.env` from kie's live pricing) — required for this model, there is no built-in default and the script stops without it.
- dollars at $5 per 1,000 credits.
Wait for explicit approval. One approval equals one run.

## Response handling

- Success returns `code: 200` with `data.taskId`.
- Poll `GET https://api.kie.ai/api/v1/jobs/recordInfo?taskId={taskId}` every 15 seconds. Read `data.state` (`waiting`/`success`/`fail`); on success parse `data.resultJson` for `resultUrls[0]`.
- On `state: fail`, read `data.failMsg` (e.g. unsupported material) — the job cost 0 credits, so fix and resubmit.
- Result URLs can expire in hours. Download the mp4 immediately into the generations folder, then write the log.

## Notes

- Keep the point of view identical to the still. Do not let the camera swing to a third person shot.
- If Seedance is unavailable or errors, fall back to models/wan-2-6-image-to-video.md.
