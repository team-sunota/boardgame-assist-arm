#!/usr/bin/env bash
# One-time setup: conda env + LeRobot (pinned) + this robot's calibration files.
set -euo pipefail
cd "$(dirname "$0")"

ENV=lerobot
LEROBOT_REV=0793738cefde81a8354e9730c4dce0d0259280fa  # version we tested with

command -v conda >/dev/null || { echo "conda not found: install miniforge first (https://conda-forge.org/download/)"; exit 1; }
eval "$(conda shell.bash hook)"

if conda env list | grep -qE "^$ENV "; then
  echo "conda env '$ENV' already exists, reusing it"
else
  # ffmpeg 7.1.1 together with python: 9.x lacked libsvtav1, swapping later broke deps
  conda create -y -n "$ENV" -c conda-forge python=3.12 ffmpeg=7.1.1
fi
conda activate "$ENV"
pip install "lerobot[core_scripts,feetech] @ git+https://github.com/huggingface/lerobot@$LEROBOT_REV"

# Calibration belongs to the physical arms, not the PC; keep any existing files.
DEST="${HF_LEROBOT_CALIBRATION:-${HF_LEROBOT_HOME:-$HOME/.cache/huggingface/lerobot}/calibration}"
mkdir -p "$DEST"
cp -Rn calibration/. "$DEST/"
echo "calibration files in $DEST:"; find "$DEST" -name '*.json'

python -c "import lerobot; print('lerobot', lerobot.__version__, 'OK')"
echo "Done. Next: plug in both arms, then ./teleop.sh"
