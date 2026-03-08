FROM rasa/rasa:3.5.17-full

USER root

# Copy application files
COPY actions /app/actions
COPY data /app/data
COPY config.yml /app/config.yml
COPY domain.yml /app/domain.yml
COPY credentials.yml /app/credentials.yml
COPY endpoints.yml /app/endpoints.yml

# Install Python dependencies
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy and setup startup script
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

USER 1001

# Train the model
RUN rasa train

EXPOSE 5055 10000

# Use bash to execute the script
CMD ["/bin/bash", "/app/start.sh"]
