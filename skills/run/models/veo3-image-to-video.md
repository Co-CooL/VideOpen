# Veo 3.1 Image-to-Video (Google, via kie.ai)

Verified against docs.kie.ai on 2026-08-20.

| Field | Value |
|---|---|
| Model ID | `veo3` (Quality — text & image-to-video), `veo3_fast` (Fast — text, image & material-to-video, default), `veo3_lite` (Lite — text, image & material-to-video) |
| Provider | kie.ai |
| Method | Async (submit, then poll) — uses its own Veo-specific endpoints, NOT the shared `jobs/createTask` one |
| Type | Video (image-to-video, via reference images) |
| API key | .env -> KIE_API_KEY |
| Docs | https://docs.kie.ai/veo3-api/generate-veo-3-video |
| Cost | Not published as a flat rate on the docs page. The docs state pricing is "25% of the official Google pricing" and point to https://kie.ai/pricing for the full table; 4K generation costs ~2× the credits of Fast mode. Check the live pricing page before quoting a cost to the user — do not use third-party estimates. |

## Endpoint

POST `https://api.kie.ai/api/v1/veo/generate`

Base URL: `https://api.kie.ai`

## Auth

Authorization: Bearer {KIE_API_KEY}

## Request body

Confirmed against https://docs.kie.ai/veo3-api/generate-veo-3-video.

```json
{
  "prompt": "short motion prompt",
  "imageUrls": ["https://the-hosted-still.png"],
  "model": "veo3_fast",
  "aspect_ratio": "9:16",
  "resolution": "720p",
  "duration": 8,
  "watermark": "",
  "callBackUrl": "",
  "enableTranslation": true
}
```

- `prompt` (string) — required.
- `imageUrls` (array of strings, camelCase, plural) — optional; 1-2 images for image-to-video modes. Confirmed exact field name.
- `model` (string) — optional, defaults to `veo3_fast`. One of `veo3` / `veo3_fast` / `veo3_lite`.
- `generationType` — the docs list this as an optional field ("Auto-determined" by default) rather than a required trigger for image-to-video; passing `imageUrls` is what makes it an image-to-video call. The `REFERENCE_2_VIDEO` value used in earlier drafts of this file was not confirmed on the current docs page — omit `generationType` unless you have a specific reason to set it.
- `aspect_ratio` (string) — optional, default `16:9`. **9:16 vertical is supported**, along with 16:9 and Auto.
- `resolution` (string) — optional, default `720p`.
- `duration` (integer) — optional, default `8`. Accepts `4`, `6`, or `8` seconds.
- `callBackUrl` (string) — optional, webhook for completion notification.
- `enableTranslation` (boolean) — optional, default `false`; auto-translates prompt to English.
- `watermark` (string) — optional text watermark.
- `enableFallback` (boolean) — present in the schema but marked **deprecated** in the docs; avoid setting it.

## Response handling

- Poll `GET https://api.kie.ai/api/v1/veo/record-info?taskId={taskId}` (Veo-specific, confirmed).
- Check `successFlag` in the response: `0` = generating, `1` = success, `2` = failed, `3` = generation failed after task creation.
- On success, read `resultUrls` (array, nullable) under the `response` object. `fullResultUrls` and `originUrls` are also present.
- A separate `GET https://api.kie.ai/api/v1/veo/get-1080p-video` endpoint exists for requesting HD upscaling on 16:9 videos.
- Generation typically takes 2-5 minutes per the docs.

## Cost gate (required)

Same rule as every other video model in this skill: quote credits/dollars, wait for explicit approval before submitting. Since the docs don't publish a flat per-second/per-clip rate, check https://kie.ai/pricing (or the account's kie.ai dashboard) for the current number before quoting the user.

## Notes

- None outstanding — endpoint, request schema, model ids, polling endpoint, and aspect-ratio support are all confirmed against the live docs.
