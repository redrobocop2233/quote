# Use official Rasa image with correct Python version
FROM rasa/rasa:3.5.17-full

# Switch to root to install additional dependencies
USER root

# Copy your custom actions and quotes
COPY actions /app/actions
COPY data /app/data
COPY config.yml /app/config.yml
COPY domain.yml /app/domain.yml
COPY credentials.yml /app/credentials.yml
COPY endpoints.yml /app/endpoints.yml
COPY tests /app/tests

# Install any additional Python packages
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Create startup script
RUN echo '#!/bin/bash\n\
echo "Starting Action Server..."\n\
rasa run actions --actions actions --port 5055 &\n\
ACTION_PID=$!\n\
echo "Starting Rasa Server..."\n\
rasa run --enable-api --cors "*" --port 5005\n\
kill $ACTION_PID' > /app/start.sh && chmod +x /app/start.sh

# Ensure proper permissions
USER 1001

# Train the model (this will happen during build)
RUN rasa train

# Expose ports
EXPOSE 5005 5055

# Use the startup script
CMD ["/app/start.sh"]