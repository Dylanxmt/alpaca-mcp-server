FROM python:3.11-slim

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project

COPY pyproject.toml uv.lock README.md ./
COPY src/ ./src/
COPY .github/core/ ./.github/core/

RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen

ENV PATH="/app/.venv/bin:$PATH"

## Local: CMD ["alpaca-mcp-server", "--transport", "stdio"]

# Cloud deployment — uses $PORT env var (Render sets this automatically)
ENV PORT=8000
CMD sh -c "alpaca-mcp-server --transport streamable-http --host 0.0.0.0 --port ${PORT}"
