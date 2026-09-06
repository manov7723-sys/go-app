FROM golang:1.22-bookworm AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=1 go build -o /out/app .

FROM gcr.io/distroless/base-debian12:nonroot
COPY --from=build /out/app /app
# distroless nonroot is uid 65532; using the number so Kubernetes'
# runAsNonRoot check accepts it (a name it cannot verify).
USER 65532
EXPOSE 8080
WORKDIR /data
ENTRYPOINT ["/app"]
