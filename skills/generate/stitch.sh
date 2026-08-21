#!/usr/bin/env bash
# Assemble several already-generated clips into one longer publish-ready video.
# kie.ai has no native 60s+ generation and no server-side merge/concat endpoint
# (checked docs.kie.ai 2026-08-20) — every wired model tops out at ~30s (Seedance
# 2.5) per single call, and per-provider "extend" chains (Runway/Veo3.1/Grok
# Imagine) aren't wired into this skill and Veo3.1's extend refuses 1080p source
# clips anyway, which is this skill's hard resolution floor. So: generate each
# scene as its own approved, paid clip, then stitch client-side with this script.
# Does NOT re-charge credits — it only sums what the constituent clips already
# cost and logs a zero-cost "assembly" ledger line for traceability.
#
# Usage: stitch.sh <output_basename> <clip1.mp4> <clip2.mp4> [clip3.mp4 ...]
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="${GENERATIONS_DIR:-$HOME/faceless/generations}"

BASE="${1:?Usage: stitch.sh <output_basename> <clip1.mp4> <clip2.mp4> [...]}"
shift
CLIPS=("$@")
if [ "${#CLIPS[@]}" -lt 2 ]; then
  echo "STOP: need at least 2 clips to stitch (got ${#CLIPS[@]})."; exit 1
fi

command -v ffmpeg >/dev/null 2>&1 || { echo "STOP: ffmpeg is required and was not found."; exit 1; }
command -v ffprobe >/dev/null 2>&1 || { echo "STOP: ffprobe is required and was not found."; exit 1; }

TS="$(date +%Y%m%d-%H%M%S)"
OUT_MP4="${OUT_DIR}/${BASE}_${TS}.mp4"

# --- QA gate: every input must exist, be vertical, and be 1080p+ on the short side ---
TOTAL_DUR=0
for c in "${CLIPS[@]}"; do
  [ -f "$c" ] || { echo "STOP: clip not found: $c"; exit 1; }
  DIMS=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of default=nw=1:nk=1 "$c" | tr '\n' ' ')
  W=$(echo "$DIMS" | awk '{print $1}'); H=$(echo "$DIMS" | awk '{print $2}')
  SHORT=$((W<H ? W : H))
  if [ "$H" -le "$W" ] || [ "$SHORT" -lt 1080 ]; then
    echo "STOP: $c is ${W}x${H} — must be vertical and >=1080 on the short side. Nothing stitched."
    exit 1
  fi
  D=$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$c")
  TOTAL_DUR=$(python3 -c "print(round(${TOTAL_DUR}+${D},2))")
  echo "QA: $c  ${W}x${H}  ${D}s  OK"
done
echo "Total assembled duration: ${TOTAL_DUR}s across ${#CLIPS[@]} clips."

# --- concat via filter (re-encodes; robust even if clips came from different
#     models/codecs/frame rates, unlike the concat demuxer's stream-copy path) ---
FILTER_INPUTS=(); FILTER_CHAIN=""
i=0
for c in "${CLIPS[@]}"; do
  FILTER_INPUTS+=(-i "$c")
  FILTER_CHAIN+="[${i}:v:0][${i}:a:0]"
  i=$((i+1))
done
FILTER_CHAIN+="concat=n=${#CLIPS[@]}:v=1:a=1[outv][outa]"

echo "Stitching -> $OUT_MP4 ..."
if ! ffmpeg -y -v error "${FILTER_INPUTS[@]}" -filter_complex "$FILTER_CHAIN" \
  -map "[outv]" -map "[outa]" -c:v libx264 -pix_fmt yuv420p -crf 18 -c:a aac "$OUT_MP4"; then
  echo "NOTE: audio-aware concat failed (a clip likely has no audio track) — retrying video-only."
  FILTER_CHAIN=""; i=0
  for c in "${CLIPS[@]}"; do FILTER_CHAIN+="[${i}:v:0]"; i=$((i+1)); done
  FILTER_CHAIN+="concat=n=${#CLIPS[@]}:v=1:a=0[outv]"
  ffmpeg -y -v error "${FILTER_INPUTS[@]}" -filter_complex "$FILTER_CHAIN" \
    -map "[outv]" -c:v libx264 -pix_fmt yuv420p -crf 18 "$OUT_MP4"
fi

# --- sum the cost already paid for each constituent clip (from its sidecar) ---
ISO="$(date -u +%Y-%m-%dT%H:%M:%SZ)"; LEDGER="${OUT_DIR}/ledger.json"
python3 - "$OUT_MP4" "$BASE" "$ISO" "$LEDGER" "$TOTAL_DUR" "${CLIPS[@]}" <<'PY'
import json, sys, pathlib
mp4, base, iso, ledger, total_dur, *clips = sys.argv[1:]
total_dur = float(total_dur)

parts = []
sum_credits = 0
sum_usd = 0.0
for c in clips:
    side = pathlib.Path(c).with_suffix(".json")
    if side.exists():
        d = json.loads(side.read_text())
        sum_credits += d.get("cost_credits", 0)
        sum_usd += d.get("cost_usd", 0.0)
        parts.append({"clip": c, "model": d.get("model"), "cost_credits": d.get("cost_credits"), "cost_usd": d.get("cost_usd")})
    else:
        parts.append({"clip": c, "model": None, "cost_credits": None, "cost_usd": None})

pathlib.Path(mp4).with_suffix(".json").write_text(json.dumps({
    "type": "video_assembly",
    "clips": parts,
    "duration": round(total_dur, 2),
    "cost_credits_total": sum_credits,
    "cost_usd_total": round(sum_usd, 2),
    "created": iso,
}, indent=2))

# Zero-cost ledger line: the clips already billed themselves individually.
# This entry exists only so `ledger.json` shows the assembly happened.
lp = pathlib.Path(ledger)
data = json.loads(lp.read_text()) if lp.exists() and lp.read_text().strip() else []
data.append({
    "timestamp": iso, "model": "ffmpeg-concat", "type": "video_assembly",
    "cost_credits": 0, "cost_usd": 0.0,
    "description": f"{pathlib.Path(mp4).name} ({len(clips)} clips, {round(total_dur,2)}s, already-billed total ${round(sum_usd,2)})",
})
lp.write_text(json.dumps(data, indent=2))
print(f"CONSTITUENT_COST_USD={round(sum_usd,2)}  DURATION={round(total_dur,2)}s")
PY

echo "SAVED=$OUT_MP4"
echo "DONE"
