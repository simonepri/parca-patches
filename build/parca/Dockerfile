# Builds the patched Parca server: the web UI with pnpm, then a static Go binary that embeds it, on the same runtime image upstream uses.
ARG NODE_IMAGE=docker.io/library/node:22.22.2-alpine
ARG GO_IMAGE=docker.io/library/golang:1.26.8-alpine
ARG RUNTIME_IMAGE=docker.io/library/alpine:3.24.4@sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf

FROM --platform=${BUILDPLATFORM} ${NODE_IMAGE} AS ui
RUN npm install --global pnpm@11.5.2
WORKDIR /src/ui
COPY ui/ ./
RUN pnpm install --frozen-lockfile && pnpm run build

FROM --platform=${BUILDPLATFORM} ${GO_IMAGE} AS server
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
COPY --from=ui /src/ui/packages/app/web/build ./ui/packages/app/web/build
ARG TARGETOS=linux
ARG TARGETARCH
ARG VERSION=dev
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    go build -trimpath -ldflags="-X main.version=${VERSION}" -o /out/parca ./cmd/parca
RUN mkdir /out/data

FROM ${RUNTIME_IMAGE}
LABEL \
    org.opencontainers.image.source="https://github.com/simonepri/parca-patches" \
    org.opencontainers.image.description="Parca server with upstream fixes applied as patches." \
    org.opencontainers.image.licenses="Apache-2.0"
COPY --chown=65534:0 --from=server /out/data /data
USER nobody
COPY --chown=0:0 --from=server /out/parca /parca
COPY --chown=0:0 parca.yaml /parca.yaml
CMD ["/parca"]
