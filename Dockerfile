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
RUN adduser -D -u 10001 app && mkdir -p /db /blossom /config && chown -R app:app /db /blossom /config
COPY --from=build /out/haven /usr/local/bin/haven
USER app
EXPOSE 3355
