# ---- build stage ----
FROM golang:1.24-alpine AS build
RUN apk add --no-cache git build-base lmdb-dev
WORKDIR /
COPY . .
# Haven uses LMDB; keep CGO on so it links to liblmdb
RUN CGO_ENABLED=1 go build -o /out/haven

# ---- runtime stage ----
FROM alpine:3.20
RUN apk add --no-cache lmdb ca-certificates tzdata
WORKDIR /
# make persistent dirs
RUN adduser -D -u 10001 app && mkdir -p /db /blossom /config && chown -R app:app /db /blossom /config

# Copy the compiled binary
COPY --from=build /out/haven /usr/local/bin/haven

# Copy the templates folder and json files
COPY --from=build /templates /templates
COPY --from=build /relays_blastr.example.json /relays_blastr.json
COPY --from=build /relays_import.example.json /relays_import.json

USER app
EXPOSE 3355
ENTRYPOINT ["sh", "-c", "haven $HAVEN_OPTS"]
