@echo off
echo Installing dependencies...
call npm install

echo.
echo Starting Angular development server...
call ng serve --open

echo.
echo Server stopped.
pause
