#!/bin/bash

echo "🚀 Starting Ultimate QuoteBot on Render..."

# Set default port if not provided
PORT=${PORT:-10000}
ACTION_PORT=5055

echo "📡 Starting Action Server on port $ACTION_PORT..."
rasa run actions --actions actions --port $ACTION_PORT &
ACTION_PID=$!

# Wait for action server to start
sleep 5

echo "🤖 Starting Rasa Server on port $PORT..."
rasa run --enable-api --cors "*" --port $PORT

# Cleanup
kill $ACTION_PID