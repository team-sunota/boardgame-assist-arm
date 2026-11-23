"""Leader -> follower teleoperation on Mac/Windows/Linux.

Finds each arm by its controller board's USB serial number, so COM port numbers
don't matter. Run inside the `lerobot` conda env:  python teleop.py
Override: python teleop.py --leader COM5 --follower COM6   (extra args go to lerobot-teleoperate)
"""
import argparse
import subprocess
import sys

from serial.tools import list_ports

LEADER_SERIAL = "5B14029957"
FOLLOWER_SERIAL = "5B14114450"


def find_port(serial: str) -> str | None:
    for p in list_ports.comports():
        # serial_number on Win/Linux; macOS also bakes it into the device name
        if p.serial_number == serial or serial in p.device:
            return p.device
    return None


def main() -> None:
    ap = argparse.ArgumentParser(add_help=False)  # let --help etc. reach lerobot-teleoperate
    ap.add_argument("--leader")
    ap.add_argument("--follower")
    args, extra = ap.parse_known_args()

    leader = args.leader or find_port(LEADER_SERIAL)
    follower = args.follower or find_port(FOLLOWER_SERIAL)
    if not (leader and follower):
        print(f"leader={leader} follower={follower}: arm not found. Connected serial ports:")
        for p in list_ports.comports():
            print(f"  {p.device}  serial={p.serial_number}  {p.description}")
        sys.exit("Check USB + power (Windows: is the board in Device Manager > Ports?), or pass --leader/--follower.")

    print(f"leader={leader} follower={follower}  (stop: hold the follower, then Ctrl+C)")
    cmd = [
        "lerobot-teleoperate",
        "--robot.type=so101_follower", f"--robot.port={follower}", "--robot.id=my_so101_follower",
        "--teleop.type=so101_leader", f"--teleop.port={leader}", "--teleop.id=my_so101_leader",
        *extra,
    ]
    try:
        sys.exit(subprocess.call(cmd))
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()
