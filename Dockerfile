# ---- build stage ----
FROM golang:1.24-alpine AS build
RUN apk add --no-cache git build-base lmdb-dev
WORKDIR /src
COPY . .
# Haven uses LMDB; keep CGO on so it links to liblmdb
RUN CGO_ENABLED=1 go build -o /out/haven

# ---- runtime stage ----
FROM alpine:3.20
RUN apk add --no-cache lmdb ca-certificates tzdata
WORKDIR /app
# make persistent dirs
RUN adduser -D -u 10001 app && mkdir -p /data /uploads /templates /config && chown -R app:app /data /uploads /templates /config
COPY --from=build /out/haven /usr/local/bin/haven
USER app
EXPOSE 3355
# Sensible defaults; Haven will still run if you omit these.
ENV HAVEN_DATA_DIR=/data \
    HAVEN_TEMPLATES_DIR=/templates \
    HAVEN_UPLOADS_DIR=/uploads \
    HAVEN_PORT=3355
ENTRYPOINT ["haven"]
