# docker/api/Dockerfile
FROM alpine:3.21

RUN apk add --no-cache \
    python3 \
    py3-pip \
    nodejs \
    npm \
    curl \
    bash

WORKDIR /app

COPY src/requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

COPY api/src .

EXPOSE 8000

CMD ["python3", "main.py"]