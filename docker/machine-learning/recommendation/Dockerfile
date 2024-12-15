# docker/ml/Dockerfile.recommendation
FROM alpine:3.21

RUN apk add --no-cache \
    python3 \
    py3-pip \
    curl \
    bash

WORKDIR /app

COPY ml/requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

COPY ml/models /app/models
COPY ml/src /app/src

EXPOSE 8080

CMD ["python3", "src/recommendation_service.py"]