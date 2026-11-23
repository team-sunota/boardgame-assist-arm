# SO-101 팀 키트 (텔레오퍼레이션 바로 시작하기)

이 레포 하나로 팀원 Mac에서 설치 → 텔레오퍼레이션까지 됩니다.
로봇(leader/follower 한 쌍)은 이미 조립·모터 ID 설정·칼리브레이션 완료 상태입니다.

## 1. 최초 1회 설치

준비물: [miniforge](https://conda-forge.org/download/) (conda)

```bash
git clone git@github.com:gwpark0741/so101-chess-supporter.git
cd so101-chess-supporter
./setup.sh
```

- conda 환경 `lerobot` 생성 (Python 3.12, ffmpeg 7.1.1)
- LeRobot 설치 (테스트한 버전으로 고정)
- `calibration/` 의 칼리브레이션 파일을 `~/.cache/huggingface/lerobot/calibration/` 에 복사 (이미 있으면 덮어쓰지 않음)

## 2. 텔레오퍼레이션

1. 두 팔 모두 **전원 어댑터 + USB** 연결
2. 두 팔을 **비슷한 자세**로 맞추기 (차이가 크면 follower가 확 튐)
3. 실행:

```bash
./teleop.sh
```

4. 끝낼 때: **follower를 손으로 받치고 `Ctrl+C`** (토크가 풀려 팔이 처짐) → 그다음 USB/전원 분리
   - 실행 중 USB를 먼저 뽑으면 follower가 힘을 준 채 굳어 있음 → 전원 어댑터를 뽑으면 풀림

## 포트

| 팔 | 포트 (Mac) | id |
|---|---|---|
| Leader | `/dev/tty.usbmodem5B140299571` | `my_so101_leader` |
| Follower | `/dev/tty.usbmodem5B141144501` | `my_so101_follower` |

Mac에서는 컨트롤러 보드 시리얼 번호 기반이라 허브 칸을 바꿔도 같습니다.
Linux 등에서 다르면: `LEADER_PORT=/dev/ttyACM0 FOLLOWER_PORT=/dev/ttyACM1 ./teleop.sh`
어느 쪽이 leader인지 모르겠으면 `lerobot-find-port` (USB 하나 뽑으라고 안내함).

## 문제 해결

- **포트가 안 보임**: 허브의 USB-C 칸이 충전 전용일 수 있음 → USB-A 칸 사용 / 케이블이 충전 전용인지 확인
- **칼리브레이션 하라고 물어봄**: id 철자 확인. 그래도 물으면 **Enter = 기존 파일 사용**, `c` + Enter = 새로 칼리브레이션
- **그리퍼/손목을 분해·재조립했다면**: follower만 다시 칼리브레이션

```bash
conda activate lerobot
lerobot-calibrate --robot.type=so101_follower --robot.port=/dev/tty.usbmodem5B141144501 --robot.id=my_so101_follower
```

  새로 칼리브레이션하면 `~/.cache/huggingface/lerobot/calibration/` 의 파일이 바뀌니, 이 폴더의 `calibration/` 도 갱신해서 다시 공유하세요.

참고: [LeRobot SO-101 공식 문서](https://huggingface.co/docs/lerobot/so101)
