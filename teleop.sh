#!/usr/bin/env bash
# Leader -> follower teleoperation. Stop with Ctrl+C (hold the follower: it goes limp).
set -euo pipefail

# Ports on a Mac come from each board's USB serial number, so they stay the same.
# On Linux/another board, override: LEADER_PORT=/dev/ttyACM0 FOLLOWER_PORT=/dev/ttyACM1 ./teleop.sh
LEADER_PORT="${LEADER_PORT:-/dev/tty.usbmodem5B140299571}"
FOLLOWER_PORT="${FOLLOWER_PORT:-/dev/tty.usbmodem5B141144501}"

for p in "$LEADER_PORT" "$FOLLOWER_PORT"; do
  [ -e "$p" ] || { echo "port $p not found. Connected ports:"; ls /dev/tty.usbmodem* /dev/ttyACM* 2>/dev/null; echo "-> check USB/power, or set LEADER_PORT / FOLLOWER_PORT"; exit 1; }
done

eval "$(conda shell.bash hook)"
conda activate lerobot

lerobot-teleoperate \
  --robot.type=so101_follower --robot.port="$FOLLOWER_PORT" --robot.id=my_so101_follower \
  --teleop.type=so101_leader  --teleop.port="$LEADER_PORT"   --teleop.id=my_so101_leader \
  "$@"
