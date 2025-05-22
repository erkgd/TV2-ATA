@echo off
echo Installing dependencies...
call npm install

echo.
echo Building Angular application...
call ng build --configuration production

echo.
echo Application built successfully!
echo The production build is located in the dist/ folder.
echo.
echo To run the development server, use: npm start
echo.
pause
