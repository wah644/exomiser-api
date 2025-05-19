FROM openjdk:17-slim

RUN apt-get update && apt-get install -y python3 python3-pip unzip curl

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . /app
WORKDIR /app

RUN chmod +x /app/exomiser-cli-14.0.0/exomiser-cli-14.0.0.jar

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

CMD ["uvicorn", "app.exomiser_service:app", "--host", "0.0.0.0", "--port", "10000"]

