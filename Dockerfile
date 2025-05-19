FROM python:3.10-slim

# Install required packages
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk wget unzip && \
    apt-get clean

# Set working directory
WORKDIR /app

# Copy your app files
COPY . .

# Download and unzip Exomiser
RUN wget https://github.com/exomiser/Exomiser/releases/download/14.0.0/exomiser-cli-14.0.0-distribution.zip && \
    unzip exomiser-cli-14.0.0-distribution.zip && \
    rm exomiser-cli-14.0.0-distribution.zip

# Make sure the JAR is executable
RUN chmod +x exomiser-cli-14.0.0/exomiser-cli-14.0.0.jar

# Set environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt


EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
