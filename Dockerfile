FROM python:3.10-slim

# Install required packages
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk wget unzip && \
    apt-get clean

# Set environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# Set working directory
WORKDIR /app

# Create a persistent data directory for Exomiser
RUN mkdir -p /app/data

# Copy your app files (Python + Exomiser config files)
COPY . .

# Download and unzip Exomiser CLI
RUN wget https://github.com/exomiser/Exomiser/releases/download/14.0.0/exomiser-cli-14.0.0-distribution.zip && \
    unzip exomiser-cli-14.0.0-distribution.zip && \
    rm exomiser-cli-14.0.0-distribution.zip

# Make the JAR executable (not strictly necessary for Java .jar, but fine to keep)
RUN chmod +x exomiser-cli-14.0.0/exomiser-cli-14.0.0.jar

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose the API port
EXPOSE 8000

# Start your FastAPI app
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
