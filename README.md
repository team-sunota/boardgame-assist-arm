# Boardgame Assist Arm

**손 조작에 어려움이 있는 사용자의 실물 보드게임 참여를 위한 AI 기반 협동 로봇 시스템**

사용자는 게임의 판단과 전략을 직접 내리고, 기물을 집고 옮기는 물리적 행동은 로봇이 대신합니다.
음성 명령(예: "E4의 나이트를 F6으로 옮겨줘") → VLA(Vision-Language-Action) 모델 → SO-101 로봇팔 조작.

> 팀 **手놓다 (수놓다)** · 서강대학교 창의융합 자유연구 프로그램 2026-2

## 시스템 구성

| 구성 | 내용 |
|---|---|
| 로봇 | SO-101 follower + leader arm (LeRobot) |
| 비전 | 상단 카메라 (Intel RealSense D405) + 손목 카메라 (Innomaker U20CAM-1080P) |
| 정책 | 사전학습 VLA 파인튜닝 (SFT) → Isaac Sim / Isaac Lab 강화학습 → Sim-to-Real |
| 인터페이스 | 음성 (STT) → 명령 정규화 / 규칙 검증 → VLA |

## 진행 상황

- [x] SO-101 조립, 모터 설정, 칼리브레이션
- [x] Leader-Follower 텔레오퍼레이션
- [ ] 카메라 장착 (상단 + 손목)
- [ ] 텔레오퍼레이션 데이터 수집
- [ ] VLA 파인튜닝 (SFT)
- [ ] Isaac Sim 환경 구축 및 RL
- [ ] 음성 인터페이스
- [ ] 실물 보드게임 평가

## 레포 구조

```
setup.sh / setup.bat   # 최초 1회 환경 설치 (Mac·Linux / Windows)
teleop.py              # 텔레오퍼레이션 실행 (포트 자동 탐색)
calibration/           # 우리 로봇 한 쌍의 칼리브레이션 파일
```

---

## Getting Started: 텔레오퍼레이션

로봇(leader/follower 한 쌍)은 이미 조립, 모터 ID 설정, 칼리브레이션이 끝난 상태입니다.

### 1. 최초 1회 설치

준비물: [Miniforge](https://conda-forge.org/download/) (conda), git

**Mac / Linux** (터미널)

```bash
git clone https://github.com/team-sunota/boardgame-assist-arm.git
cd boardgame-assist-arm
./setup.sh
```

**Windows** (시작 메뉴 → **Miniforge Prompt**)

```bat
git clone https://github.com/team-sunota/boardgame-assist-arm.git
cd boardgame-assist-arm
setup.bat
```

설치 내용:
- conda 환경 `lerobot` 생성 (Python 3.12, ffmpeg 7.1.1)
- LeRobot 설치 (테스트한 버전으로 고정)
- `calibration/` 의 파일을 `~/.cache/huggingface/lerobot/calibration/` 에 복사 (Windows: `%USERPROFILE%\.cache\...`)

### 2. 텔레오퍼레이션

1. 두 팔 모두 **전원 어댑터 + USB** 연결
2. 두 팔을 **비슷한 자세**로 맞추기 (차이가 크면 follower가 확 튐)
3. 실행 (Windows는 Miniforge Prompt에서):

```bash
conda activate lerobot
python teleop.py
```

4. 끝낼 때: **follower를 손으로 받치고 `Ctrl+C`** (토크가 풀려 팔이 처짐) → 그다음 USB/전원 분리
   - 실행 중 USB를 먼저 뽑으면 follower가 힘을 준 채 굳어 있음 → 전원 어댑터를 뽑으면 풀림

### 포트

`teleop.py` 가 컨트롤러 보드의 USB 시리얼 번호로 leader/follower를 자동으로 찾습니다. Windows의 `COM` 번호가 PC마다 달라도 됩니다.

| 팔 | 보드 시리얼 | id |
|---|---|---|
| Leader | `5B14029957` | `my_so101_leader` |
| Follower | `5B14114450` | `my_so101_follower` |

못 찾으면 연결된 포트 목록을 보여줍니다. 직접 지정: `python teleop.py --leader COM5 --follower COM6`

## 문제 해결

- **포트가 안 보임**: 허브의 USB-C 칸이 충전 전용일 수 있음 → USB-A 칸 사용 / 케이블이 충전 전용인지 확인
- **Windows에서 장치 관리자 → 포트(COM & LPT)에 안 나옴**: WCH [CH343 드라이버](https://www.wch-ic.com/downloads/CH343SER_EXE.html) 설치
- **칼리브레이션 하라고 물어봄**: id 철자 확인. 그래도 물으면 **Enter = 기존 파일 사용**, `c` + Enter = 새로 칼리브레이션
- **그리퍼/손목을 분해·재조립했다면**: follower만 다시 칼리브레이션 (`<follower 포트>` 는 `python teleop.py` 가 출력한 값)

```bash
lerobot-calibrate --robot.type=so101_follower --robot.port=<follower 포트> --robot.id=my_so101_follower
```

  새로 칼리브레이션하면 `~/.cache/huggingface/lerobot/calibration/` 의 파일을 이 레포 `calibration/` 에 복사해서 push 하세요.

## 참고

- [LeRobot SO-101 공식 문서](https://huggingface.co/docs/lerobot/so101)
- [SO-ARM100 하드웨어 (손목 카메라 마운트 포함)](https://github.com/TheRobotStudio/SO-ARM100)
