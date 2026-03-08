@echo off
echo Starting Ultimate QuoteBot on Windows...
echo.

echo Starting Action Server on port 5055...
start /B rasa run actions --actions actions --port 5055

timeout /t 5

echo Starting Rasa Server on port 5005...
rasa run --enable-api --cors "*" --port 5005