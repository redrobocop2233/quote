#!/bin/bash
echo "🚀 Starting Ultimate QuoteBot on Render..."
echo "Current directory: $(pwd)"
echo "Python version: $(python --version)"
echo "Rasa version: $(rasa --version)"

# Start Action Server
echo "📡 Starting Action Server on port 5055..."
rasa run actions --actions actions --port 5055 &
ACTION_PID=$!

# Wait for action server to start
echo "⏳ Waiting for action server to start..."
sleep 5

# Check if action server is running
if ! kill -0 $ACTION_PID 2>/dev/null; then
    echo "❌ Action server failed to start!"
    exit 1
fi
echo "✅ Action server running with PID: $ACTION_PID"

# Use Render's PORT (default 10000)
RASA_PORT=${PORT:-10000}
echo "🤖 Starting Rasa Server on port $RASA_PORT..."

# Start Rasa server
rasa run --enable-api --cors "*" --port $RASA_PORT

# Cleanup
kill $ACTION_PID
