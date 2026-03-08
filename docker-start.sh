#!/bin/bash
echo "Starting Action Server..."
rasa run actions --actions actions --port 5055 &
ACTION_PID=$!

echo "Starting Rasa Server..."
rasa run --enable-api --cors "*" --port 5005

# Cleanup on exit
kill $ACTION_PID