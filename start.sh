#!/bin/bash
echo "🚀 Starting Ultimate QuoteBot on Render..."

# Start Action Server (always on 5055)
echo "📡 Starting Action Server on port 5055..."
rasa run actions --actions actions --port 5055 &
ACTION_PID=$!

# Wait for action server
sleep 5

# Use Render's PORT (default 10000)
RASA_PORT=${PORT:-10000}
echo "🤖 Starting Rasa Server on port $RASA_PORT..."
rasa run --enable-api --cors "*" --port $RASA_PORT

kill $ACTION_PID
