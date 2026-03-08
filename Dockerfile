FROM python:3.9-slim

WORKDIR /app

# Install Rasa
RUN pip install --no-cache-dir rasa==3.5.17

# Copy your app
COPY . /app

# Install other dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Make script executable
RUN chmod +x /app/start.sh

# Train the model
RUN rasa train

EXPOSE 5055 10000

CMD ["/app/start.sh"]
