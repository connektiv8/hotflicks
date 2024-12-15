# docker/ml/Dockerfile.model-trainer
FROM python:3.12-alpine AS builder

RUN apk add --no-cache \
    gcc \
    musl-dev \
    python3-dev

WORKDIR /app
COPY ml/model-trainer/requirements.txt .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /wheels -r requirements.txt

FROM python:3.11-alpine

WORKDIR /app
COPY --from=builder /wheels /wheels
COPY --from=builder /app/requirements.txt .
RUN pip install --no-cache /wheels/*

COPY docker/machine-learning/model-trainer/src ./src
COPY docker/machine-learning/model-trainer/models ./models
COPY docker/machine-learning/cache/conf/model-trainer.conf ./conf/

CMD ["python", "src/train.py"]