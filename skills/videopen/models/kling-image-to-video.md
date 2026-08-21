# Kling Image-to-Video (Kuaishou, via kie.ai)

Verified against docs.kie.ai on 2026-08-20.

| Field | Value |
|---|---|
| Model ID | `kling-2.6/image-to-video` (confirmed), or a version-pinned variant like `kling/v3-turbo-image-to-video` (confirmed) — several Kling versions/tiers exist on kie.ai's Market |
| Provider | kie.ai |
| Method | Async (submit, then poll) — uses the shared `jobs/createTask` endpoint, same shape as Seedance/Wan |
| Type | Video (image-to-video) |
| API key | .env -> KIE_API_KEY |
| Docs | https://docs.kie.ai/market/kling/image-to-video (base model), https://docs.kie.ai/market/kling/v3-turbo-image-to-video (turbo variant) |
| Cost | Not published as a flat rate on either docs page. Callback responses include a `creditsConsumed` field, but no per-second/per-clip price table is on the docs pages themselves — check https://kie.ai/pricing before quoting a cost. Do not use third-party estimates. |

## Endpoint

POST `https://api.kie.ai/api/v1/jobs/createTask`

## Auth

Authorization: Bearer {KIE_API_KEY}

## Request body

Confirmed against https://docs.kie.ai/market/kling/image-to-video (base `kling-2.6/image-to-video`).

```json
{
  "model": "kling-2.6/image-to-video",
  "callBackUrl": "",
  "input": {
    "prompt": "short motion prompt",
    "image_urls": ["https://the-hosted-still.png"],
    "sound": false,
    "duration": "5"
  }
}
```

- `model` (string) — required. Exact id confirmed: `kling-2.6/image-to-video`.
- `input` (object) — required.
  - `prompt` (string, max 1000 characters for the base model) — required.
  - `image_urls` (array of URIs, **plural**, snake_case, max 1 item, JPEG/PNG, max 10MB each) — required. This corrects the earlier draft's `image_url` (singular) guess — the confirmed field is `image_urls`, an array with a max of 1 item.
  - `sound` (boolean) — required for the base `kling-2.6/image-to-video` model.
  - `duration` (string) — required. `"5"` or `"10"` seconds for the base model.
- `callBackUrl` (string, URI) — optional, webhook for completion notification.

For the `kling/v3-turbo-image-to-video` variant, the schema differs: `input.duration` (string, required, range 3-15 seconds, default `"5"`) and `input.resolution` (string, required, enum `720p`/`1080p`) replace/extend the base model's fields — confirm the exact `input` shape for whichever variant is used, since it is not identical across Kling tiers on kie.ai.

- `negative_prompt` and `cfg_scale` from the earlier draft were **not found** on either fetched docs page — do not assume they exist; omit them unless confirmed for the specific model variant in use.
- **Aspect ratio**: neither the base model page nor the v3-turbo page documents an `aspect_ratio` request field. This could not be confirmed as supported or unsupported — if a vertical 9:16 output is needed, check the live docs for the specific model variant, or test with a vertical input image (Kling models often infer output aspect ratio from the source image) before assuming 9:16 works.

## Response handling

- Success returns `code: 200` with `data.taskId`.
- Poll `GET https://api.kie.ai/api/v1/jobs/recordInfo?taskId={taskId}` — confirmed as the correct shared polling endpoint for Market models including Kling (cross-checked against https://docs.kie.ai/market/common/get-task-detail, which documents this same endpoint).
- Read `data.state`: `waiting` / `queuing` / `generating` / `success` / `fail`.
- On success, parse `data.resultJson` (string) for the result URL(s).

## Cost gate (required)

Same rule as every other video model in this skill: quote credits/dollars, wait for explicit approval before submitting. Check https://kie.ai/pricing (or the account's kie.ai dashboard) for the current rate, since it isn't published on the model docs pages.

## Notes

- Multiple Kling versions/tiers exist on kie.ai (2.5, 2.6, 3.0, turbo, pro/std) and their `input` schemas are not identical (e.g. base model requires `sound`; v3-turbo requires `resolution` instead). Pick the version explicitly requested, or the cheapest available one if none is specified, confirm that variant's exact `input` fields against its own docs page, and say which was used.
- Aspect-ratio/vertical (9:16) support is unconfirmed for Kling on kie.ai — flag this to the user if a vertical output is required, rather than assuming it works.
