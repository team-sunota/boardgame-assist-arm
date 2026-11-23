@echo off
rem One-time Windows setup. Run from "Miniforge Prompt" inside this folder: setup.bat
setlocal
set ENV=lerobot
set LEROBOT_REV=0793738cefde81a8354e9730c4dce0d0259280fa

where conda >nul 2>nul || (echo conda not found: install Miniforge and run this from "Miniforge Prompt" & exit /b 1)

conda env list | findstr /b /c:"%ENV% " >nul && (
  echo conda env %ENV% already exists, reusing it
) || (
  call conda create -y -n %ENV% -c conda-forge python=3.12 ffmpeg=7.1.1 || exit /b 1
)
call conda activate %ENV% || exit /b 1
pip install "lerobot[core_scripts,feetech] @ git+https://github.com/huggingface/lerobot@%LEROBOT_REV%" || exit /b 1

rem Calibration belongs to the arms; /D = only copy if newer/missing, keeps your own files otherwise
set DEST=%USERPROFILE%\.cache\huggingface\lerobot\calibration
if defined HF_LEROBOT_CALIBRATION set DEST=%HF_LEROBOT_CALIBRATION%
xcopy /E /I /D /Y calibration "%DEST%" >nul
dir /S /B "%DEST%\*.json"

python -c "import lerobot; print('lerobot', lerobot.__version__, 'OK')" || exit /b 1
echo Done. Next: plug in both arms, then:  python teleop.py
