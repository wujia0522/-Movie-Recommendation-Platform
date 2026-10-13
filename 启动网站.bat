@echo off
cd /d "%~dp0"
title 电影推荐系统 - 本地启动器

rem ============================================================
rem  一键启动：《基于用户画像与矩阵分解的电影推荐平台》
rem  双击本文件即可：
rem    1) 先探测 8000 端口，服务已经在跑就只打开浏览器
rem    2) 没跑就启动 Django 服务，等它就绪后自动打开浏览器
rem  关闭网站：关掉那个标题是“电影推荐系统-服务”的最小化窗口即可
rem ============================================================

if not exist "venv\Scripts\python.exe" goto NOVENV

echo.
echo   电影推荐系统 - 正在检查本地服务...

rem 用 PowerShell 探测 8000 端口（比 curl 可靠，Windows 自带）
powershell -NoProfile -Command "try { (New-Object Net.Sockets.TcpClient).Connect('127.0.0.1', 8000); exit 0 } catch { exit 1 }"
if not errorlevel 1 goto OPEN

echo   没检测到服务，正在启动，请稍等几秒...
echo.
start "电影推荐系统-服务（关掉这个窗口=关闭网站）" /min "venv\Scripts\python.exe" manage.py runserver 127.0.0.1:8000

rem 最多等 40 秒
for /l %%i in (1,1,40) do (
    powershell -NoProfile -Command "try { (New-Object Net.Sockets.TcpClient).Connect('127.0.0.1', 8000); exit 0 } catch { exit 1 }"
    if not errorlevel 1 goto OPEN
    ping -n 2 127.0.0.1 >nul
)

echo.
echo   服务没能在 40 秒内起来。请打开那个最小化的黑窗口看报错信息：
echo     - 如果是缺依赖：按 README.md 第五节装一遍（pip install -r requirements.txt）
echo     - 如果是端口被占用：把占用 8000 的程序关掉再试
echo.
pause
exit /b

:OPEN
start "" http://127.0.0.1:8000/
echo.
echo   浏览器已打开：http://127.0.0.1:8000/
echo   网站服务跑在另一个最小化的窗口里（标题：电影推荐系统-服务），
echo   关掉那个窗口就等于关网站。
echo.
ping -n 6 127.0.0.1 >nul
exit /b

:NOVENV
echo.
echo   没有找到 venv\Scripts\python.exe —— 说明这台机器还没装好运行环境。
echo   第一次使用请按 README.md 第五节做三步（之后就不用再做了）：
echo.
echo     1) D:\anaconda\python.exe -m venv venv
echo     2) venv\Scripts\python.exe -m pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
echo     3) venv\Scripts\python.exe manage.py migrate
echo.
echo   完成后重新双击“启动网站.bat”即可。
echo.
pause
exit /b
