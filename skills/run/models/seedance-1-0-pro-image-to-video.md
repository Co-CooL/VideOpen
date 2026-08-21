# Seedance 1.0 Pro Image-to-Video (ByteDance, via kie.ai) — DEFAULT VIDEO MODEL

The default model for a standard short vertical clip. Cheaper than 2.5 and produces publishable 1080p. Verified against docs.kie.ai/market/bytedance/v1-pro-image-to-video (2026-08-15).

| Field | Value |
|---|---|
| Model ID | `bytedance/v1-pro-image-to-video` |
| Provider | kie.ai |
| Method | Async (submit, then poll) |
| Type | Video (image-to-video) |
| API key | .env -> KIE_API_KEY |
| Cost | 1080p: 14 credits/sec. 5s = 70 credits (~$0.35), 10s = 140 credits (~$0.70) |

## Endpoint

POST https://api.kie.ai/api/v1/jobs/createTask  ·  Auth: `Authorization: Bearer {KIE_API_KEY}`

## Request body

```json
{
  "model": "bytedance/v1-pro-image-to-video",
  "input": {
    "prompt": "short motion prompt, subtle steady motion, keep the screen readable, no added text",
    "image_url": "https://durable-host/the-approved-still.jpg",
    "resolution": "1080p",
    "duration": "5",
    "camera_fixed": false
  }
}
```

- **`image_url`** is a single string.
- **NO `aspect_ratio` field.** Orientation derives from the input still. Feed a 9:16 still to get 1080x1920.
- **`resolution`**: This skill sends 1080p only.
- **`duration`**: STRING, and only `"5"` or `"10"`. There is no 8-second option. **Default 10.** If another value is requested, round to 5 or 10 (>=7.5 -> 10, else 5) and say what you did — do not fail.
- Optional: `camera_fixed` (default false), `seed` (-1).

## Hosting the still

The skill currently passes kie's own draft-result URL through as-is — no JPEG conversion or re-host happens automatically. If this returns `400: Input material format is unsupported`, convert the still to JPEG manually (`sips -s format jpeg`) and re-host it (e.g. Blotato's presigned upload — hosting only, not publishing) before passing that URL as `image_url`. This fallback isn't wired into `draft-image.sh`/`animate.sh` yet.

## Response handling

- Success: `code 200` with `data.taskId`. Poll `GET .../jobs/recordInfo?taskId={id}` every 15s.
- `data.state`: waiting/success/fail. On success parse `data.resultJson.resultUrls[0]`. Read `data.creditsConsumed` for the real billed amount.
- kie bills only on success; validation failures (402/422/400) cost 0.
