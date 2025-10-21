# ---- build stage ----
FROM golang:1.24-alpine AS build

# Install build dependencies
RUN apk add --no-cache git build-base lmdb-dev

WORKDIR /haven
COPY . .

# Build the Haven binary (with CGO enabled for LMDB)
RUN CGO_ENABLED=1 go build -o haven

# ---- runtime stage ----
FROM alpine:3.20

# Install runtime dependencies
RUN apk add --no-cache lmdb ca-certificates tzdata

# Set working directory for everything
WORKDIR /haven

# Copy the compiled binary and assets from build stage
COPY --from=build /haven/haven /haven/haven
COPY --from=build /haven/templates /haven/templates
COPY --from=build /haven/relays_blastr.example.json /haven/relays_blastr.json
COPY --from=build /haven/relays_import.example.json /haven/relays_import.json

# Expose Haven port
EXPOSE 3355

# Run as default user (root is fine since no persistent dirs enforced)
ENTRYPOINT ["sh", "-c", "./haven $HAVEN_OPTS"]
