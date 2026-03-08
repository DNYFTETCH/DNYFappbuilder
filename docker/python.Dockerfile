# DNYFappbuilder — Python Production Dockerfile
# Usage (from repo root): docker build -f docker/python.Dockerfile -t myapp .
FROM python:3.11-slim AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends gcc && \
    rm -rf /var/lib/apt/lists/*

# Support both repo-root builds (CI) and project-level builds
COPY examples/python-api/requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# ── Production stage ──────────────────────────────────────
FROM python:3.11-slim AS production

WORKDIR /app

COPY --from=builder /root/.local /root/.local
COPY examples/python-api/ .

RUN useradd -m -u 1001 appuser && chown -R appuser /app
USER appuser

ENV PATH=/root/.local/bin:$PATH
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
